using Dynare
using LinearAlgebra
using Random
using Statistics

# --- Structures ---
struct ModelSolution
    ss::Vector{Float64}
    ghx::Matrix{Float64}
    ghu::Matrix{Float64}
    state_indices::Vector{Int}
    order_var::Vector{Int}
    inv_order_var::Vector{Int}
    endo_names::Vector{String}
end

# --- Compute Statistics ---
function compute_moments(sim_data::Matrix{Float64}, var_names::Vector{String})
    T, n_vars = size(sim_data)
    cycles = zeros(T, n_vars)
    
    # Identify output var (y or yM)
    idx_y = findfirst(x -> lowercase(x) == "y", var_names)
    if idx_y === nothing; idx_y = findfirst(x -> x == "yM", var_names); end
    if idx_y === nothing; error("Output 'y' or 'yM' not found. Vars: " * join(var_names, ", ")); end
    
    # Filter and compute
    for i in 1:n_vars
        val_col = abs.(sim_data[:, i])
        series = [v > 1e-9 ? log(v) : -20.0 for v in val_col]
        cycles[:, i] = hp_filter(series)
    end
    
    std_devs = std(cycles, dims=1)[:]
    std_y = std_devs[idx_y]
    rel_std = (std_y > 1e-10) ? (std_devs ./ std_y) : zeros(n_vars)
    
    corrs = zeros(n_vars)
    cycle_y = cycles[:, idx_y]
    for i in 1:n_vars
        if std(cycles[:, i]) > 1e-10
            corrs[i] = cor(cycles[:, i], cycle_y)
        end
    end
    
    return std_devs, rel_std, corrs
end

# --- Monte Carlo Loop ---
function run_monte_carlo(sol::ModelSolution, N::Int=10000, T::Int=200)
    n_vars = length(sol.endo_names)
    d_std = zeros(N, n_vars)
    d_rel = zeros(N, n_vars)
    d_corr = zeros(N, n_vars)
    
    println("   Running $N simulations...")
    for i in 1:N
        sim_data, _ = simulate_model(sol, T)
        s, r, c = compute_moments(sim_data, sol.endo_names)
        d_std[i, :] = s; d_rel[i, :] = r; d_corr[i, :] = c
    end
    println("   Done.")
    return d_std, d_rel, d_corr
end

# --- Extract Solution ---
function extract_solution(context)
    res = context.results.model_results[1]
    
    # Steady State
    ys = nothing
    if hasfield(typeof(res), :trends) && hasfield(typeof(res.trends), :endogenous_steady_state)
        ys = res.trends.endogenous_steady_state
    end
    if ys === nothing; try ys = getproperty(res, :endogenous_steady_state) catch end; end
    if ys === nothing && hasfield(typeof(res), :ss); ys = res.ss; end
    if ys === nothing; error("Steady State not found."); end
    
    # Matrices
    lre = res.linearrationalexpectations
    ghx = real.(lre.g1_1)
    ghu = real.(lre.g1_2)
    
    # Variable Names
    endo_names = String[]
    if hasfield(typeof(context), :symboltable)
        sym_pairs = []
        for (k, s) in context.symboltable
            is_endo = false
            if hasfield(typeof(s), :symboltype)
                # Check type safely
                if string(s.symboltype) == "Endogenous"; is_endo = true; end
            end
            if is_endo
                idx = hasfield(typeof(s), :orderintype) ? s.orderintype : s.order_var[1]
                push!(sym_pairs, (string(k), idx))
            end
        end
        if !isempty(sym_pairs)
            sort!(sym_pairs, by = x -> x[2])
            endo_names = [x[1] for x in sym_pairs]
        end
    end
    
    if isempty(endo_names) && hasfield(typeof(res), :irfs) && !isempty(res.irfs)
        try endo_names = string.(collect(propertynames(first(values(res.irfs))))) catch end
    end
    if isempty(endo_names); error("Endogenous variables not found."); end
    
    # State Indices
    model = context.models[1]
    lli = hasfield(typeof(model), :lead_lag_incidence) ? model.lead_lag_incidence : model.model_info.lead_lag_incidence
    state_indices = []
    for (i, val) in enumerate(lli[1, :])
        if val > 0; push!(state_indices, (i, val)); end
    end
    sort!(state_indices, by = x -> x[2])
    final_state_indices = [x[1] for x in state_indices]
    
    n = length(endo_names)
    return ModelSolution(ys, ghx, ghu, final_state_indices, collect(1:n), collect(1:n), endo_names)
end

# --- Simulation ---
function simulate_model(sol::ModelSolution, T::Int; sigma_eps=0.007)
    n_vars = length(sol.ss)
    n_states = length(sol.state_indices)
    n_shocks = size(sol.ghu, 2)
    
    e = randn(n_shocks, T) * sigma_eps
    sim_dev = zeros(n_vars, T)
    states = zeros(n_states)
    
    for t in 1:T
        y_dev = sol.ghx * states + sol.ghu * e[:, t]
        sim_dev[:, t] = y_dev
        states = y_dev[sol.state_indices]
    end
    
    sim_lvl = zeros(T, n_vars)
    for t in 1:T
        sim_lvl[t, :] = sol.ss + sim_dev[:, t]
    end
    return sim_lvl, sol.endo_names
end