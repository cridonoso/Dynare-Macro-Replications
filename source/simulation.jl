using Dynare
using LinearAlgebra
using Random
using Statistics

# -------------------------------------------------------------------------
# STRUCT DEFINITION
# -------------------------------------------------------------------------
struct ModelSolution
    ss::Vector{Float64}         # Steady State values
    ghx::Matrix{Float64}        # Transition Matrix
    ghu::Matrix{Float64}        # Shock Matrix
    state_indices::Vector{Int}  # Indices of state variables
    order_var::Vector{Int}      # Variable ordering
    inv_order_var::Vector{Int}  # Inverse ordering
    endo_names::Vector{String}  # Names of endogenous variables
end

# -------------------------------------------------------------------------
# HP Filter Implementation (Lambda = 1600 for Quarterly data)
# -------------------------------------------------------------------------
function hp_filter(y::Vector{Float64}, lambda::Float64=1600.0)
    n = length(y)
    if n < 3
        return zeros(n)
    end
    
    D = zeros(n-2, n)
    for i in 1:n-2
        D[i, i] = 1.0
        D[i, i+1] = -2.0
        D[i, i+2] = 1.0
    end
    
    A = I + lambda * (D' * D)
    trend = A \ y
    cycle = y - trend
    return cycle
end

# -------------------------------------------------------------------------
# FUNCTION: compute_moments
# Calculates Std Dev (relative to Y) and Correlation with Y
# -------------------------------------------------------------------------
function compute_moments(sim_data::Matrix{Float64}, var_names::Vector{String})
    T, n_vars = size(sim_data)
    cycles = zeros(T, n_vars)
    
    # 1. Identify Output variable index
    # Priority: 'y' (standard RBC), then 'yM' (Household Production)
    idx_y = findfirst(x -> lowercase(x) == "y", var_names)
    
    if idx_y === nothing
        idx_y = findfirst(x -> x == "yM", var_names)
    end

    if idx_y === nothing
        # ERROR DIAGNOSTIC
        error("Reference Output variable ('y' or 'yM') not found.\nAvailable variables: " * join(var_names, ", "))
    end
    
    # 2. HP Filter
    for i in 1:n_vars
        # Log-levels (handle zeros gracefully)
        val_col = abs.(sim_data[:, i])
        # Avoid log(0). Replace < 1e-9 with 1e-9 effectively 0 in log diffs context usually
        series = [v > 1e-9 ? log(v) : -20.0 for v in val_col] 
        cycles[:, i] = hp_filter(series, 1600.0)
    end
    
    # 3. Compute Statistics
    std_devs = std(cycles, dims=1)[:]
    std_y = std_devs[idx_y]
    
    # Relative Std Dev (sigma_x / sigma_y)
    rel_std = (std_y > 1e-10) ? (std_devs ./ std_y) : zeros(n_vars)
    
    # Correlation with Output
    corrs = zeros(n_vars)
    cycle_y = cycles[:, idx_y]
    for i in 1:n_vars
        if std(cycles[:, i]) > 1e-10
            corrs[i] = cor(cycles[:, i], cycle_y)
        else
            corrs[i] = 0.0
        end
    end
    
    return std_devs, rel_std, corrs
end

# -------------------------------------------------------------------------
# FUNCTION: run_monte_carlo
# -------------------------------------------------------------------------
function run_monte_carlo(sol::ModelSolution, N::Int=10000, T::Int=200)
    n_vars = length(sol.endo_names)
    
    dist_std = zeros(N, n_vars)
    dist_rel_std = zeros(N, n_vars)
    dist_corr = zeros(N, n_vars)
    
    println("   Running $N simulations...")
    
    for i in 1:N
        sim_data, _ = simulate_model(sol, T)
        s, rs, c = compute_moments(sim_data, sol.endo_names)
        dist_std[i, :] = s
        dist_rel_std[i, :] = rs
        dist_corr[i, :] = c
        
        if i % 2000 == 0
            print(".")
        end
    end
    println(" Done.")
    
    return dist_std, dist_rel_std, dist_corr
end

# -------------------------------------------------------------------------
# FUNCTION: extract_solution
# -------------------------------------------------------------------------
function extract_solution(context)
    model_result = context.results.model_results[1]
    
    # Extract Steady State
    ys = nothing
    if hasfield(typeof(model_result), :trends) && hasfield(typeof(model_result.trends), :endogenous_steady_state)
         ys = model_result.trends.endogenous_steady_state
    end
    if ys === nothing
        try ys = getproperty(model_result, :endogenous_steady_state) catch end
    end
    if ys === nothing && hasfield(typeof(model_result), :ss)
        ys = model_result.ss
    end
    if ys === nothing
        error("FATAL: Could not find Steady State in results.")
    end
    
    # Extract Policy Functions
    lre = model_result.linearrationalexpectations
    ghx = real.(lre.g1_1)
    ghu = real.(lre.g1_2)
    
    # Extract Variable Names
    endo_names = String[]
    if hasfield(typeof(context), :symboltable)
        sym_pairs = []
        for (key, sym) in context.symboltable
            is_endo = false
            if hasfield(typeof(sym), :symboltype)
                if string(sym.symboltype) == "Endogenous"
                    is_endo = true
                end
            end
            if is_endo
                idx = 0
                if hasfield(typeof(sym), :orderintype)
                    idx = sym.orderintype
                elseif hasfield(typeof(sym), :order_var)
                    idx = sym.order_var[1]
                end
                push!(sym_pairs, (string(key), idx))
            end
        end
        if !isempty(sym_pairs)
            sort!(sym_pairs, by = x -> x[2])
            endo_names = [x[1] for x in sym_pairs]
        end
    end

    # Fallback to IRF names
    if isempty(endo_names) && hasfield(typeof(model_result), :irfs) && !isempty(model_result.irfs)
        try
            first_table = first(values(model_result.irfs))
            endo_names = string.(collect(propertynames(first_table)))
        catch
        end
    end

    if isempty(endo_names)
        error("Could not determine endogenous variable names.")
    end
    
    # Identify State Variables
    model = context.models[1]
    lli = hasfield(typeof(model), :lead_lag_incidence) ? model.lead_lag_incidence : model.model_info.lead_lag_incidence
    state_vars_with_indices = []
    for (i, val) in enumerate(lli[1, :]) 
        if val > 0
            push!(state_vars_with_indices, (i, val))
        end
    end
    sort!(state_vars_with_indices, by = x -> x[2])
    state_indices = [x[1] for x in state_vars_with_indices]
    
    n_vars = length(endo_names)
    order_var = collect(1:n_vars)
    inv_order_var = collect(1:n_vars)
    
    return ModelSolution(ys, ghx, ghu, state_indices, order_var, inv_order_var, endo_names)
end

# -------------------------------------------------------------------------
# FUNCTION: simulate_model
# -------------------------------------------------------------------------
function simulate_model(sol::ModelSolution, T::Int; sigma_eps=0.007)
    n_vars = length(sol.ss)
    n_states = length(sol.state_indices)
    n_shocks = size(sol.ghu, 2)
    
    e = randn(n_shocks, T) * sigma_eps
    
    sim_dev = zeros(n_vars, T) 
    current_states_dev = zeros(n_states)
    
    for t in 1:T
        y_t_dev = sol.ghx * current_states_dev + sol.ghu * e[:, t]
        sim_dev[:, t] = y_t_dev
        current_states_dev = y_t_dev[sol.state_indices]
    end
    
    sim_levels = zeros(T, n_vars)
    for t in 1:T
        sim_levels[t, :] = sol.ss + sim_dev[:, t]
    end

    return sim_levels, sol.endo_names
end