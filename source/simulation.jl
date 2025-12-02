using Dynare
using LinearAlgebra
using Random
using Statistics

# --- Structures ---
struct ModelSolution
    ss::Vector{Float64}
    ghx::Matrix{Float64}
    ghu::Matrix{Float64}
    Sigma_e::Matrix{Float64}
    state_indices::Vector{Int}
    order_var::Vector{Int}
    inv_order_var::Vector{Int}
    endo_names::Vector{String}
end

# --- Extract Solution ---
function extract_solution(context)
    res = context.results.model_results[1]
    model = context.models[1]
    
    # 1. Steady State setup
    ys = nothing
    if hasfield(typeof(res), :trends) && hasfield(typeof(res.trends), :endogenous_steady_state)
        ys = res.trends.endogenous_steady_state
    end
    if ys === nothing; try ys = getproperty(res, :endogenous_steady_state) catch end; end
    if ys === nothing && hasfield(typeof(res), :ss); ys = res.ss; end
    if ys === nothing; error("Steady State not found."); end
    
    # 2. Matrices setup (Decision Rules)
    lre = res.linearrationalexpectations
    ghx = real.(lre.g1_1)
    ghu = real.(lre.g1_2)
    
    # 3. Covariance Matrix of Shocks (Sigma_e)
    Sigma_e = nothing
    if hasfield(typeof(model), :Sigma_e)
        Sigma_e = model.Sigma_e
    elseif hasfield(typeof(context), :symboltable)
        n_exo = size(ghu, 2)
        Sigma_e = Matrix{Float64}(I, n_exo, n_exo) 
        println("⚠️ Advertencia: No se encontró Sigma_e explícita. Usando Identidad.")
    end

    if Sigma_e === nothing
         n_exo = size(ghu, 2)
         Sigma_e = Matrix{Float64}(I, n_exo, n_exo)
    end

    # 4. Variable Names setup
    endo_names = String[]
    if hasfield(typeof(context), :symboltable)
        sym_pairs = []
        for (k, s) in context.symboltable
            is_endo = false
            if hasfield(typeof(s), :symboltype)
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
    
    # 5. State Indices setup
    lli = hasfield(typeof(model), :lead_lag_incidence) ? model.lead_lag_incidence : model.model_info.lead_lag_incidence
    state_indices = []
    for (i, val) in enumerate(lli[1, :])
        if val > 0; push!(state_indices, (i, val)); end
    end
    sort!(state_indices, by = x -> x[2])
    final_state_indices = [x[1] for x in state_indices]
    
    n = length(endo_names)
    
    return ModelSolution(ys, ghx, ghu, Sigma_e, final_state_indices, collect(1:n), collect(1:n), endo_names)
end

# --- Core Simulation Logic ---
function simulate_model_core(sol::ModelSolution, T::Int)
    n_vars = length(sol.ss)
    n_states = length(sol.state_indices)
    n_shocks = size(sol.ghu, 2)
    
    # 1. Generar Shocks Correlacionados y Escalados
    Sigma = sol.Sigma_e
    
    L = try
        cholesky(Hermitian(Sigma)).L
    catch
        # Si falla Cholesky (ej: varianza 0), usamos sqrt diagonal
        sqrt.(abs.(Sigma))
    end
    
    # Generar ruido blanco unitario
    white_noise = randn(n_shocks, T)
    
    # Transformar a shocks del modelo (escalados y correlacionados)
    shocks = L * white_noise
    
    # 2. Simular Trayectorias
    sim_dev = zeros(n_vars, T)
    states = zeros(n_states)
    
    for t in 1:T
        # y_t = A * y_{t-1} + B * u_t
        y_dev = sol.ghx * states + sol.ghu * shocks[:, t]
        
        sim_dev[:, t] = y_dev
        states = y_dev[sol.state_indices]
    end
    
    # 3. Convertir a Niveles
    sim_lvl = zeros(T, n_vars)
    for t in 1:T
        sim_lvl[t, :] = sol.ss + sim_dev[:, t]
    end
    
    # Retornamos data transpuesta (T x vars)
    return sim_dev', sim_lvl
end

# --- HP Filter ---
function hp_filter(y::Vector{Float64}, lambda::Float64=1600.0)
    n = length(y)
    if n < 3 return zeros(n) end
    D = zeros(n-2, n)
    for i in 1:n-2
        D[i, i] = 1.0; D[i, i+1] = -2.0; D[i, i+2] = 1.0
    end
    A = I + lambda * (D' * D)
    return y - (A \ y)
end