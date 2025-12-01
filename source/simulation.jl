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

# --- Extract Solution (Sin cambios) ---
function extract_solution(context)
    res = context.results.model_results[1]
    
    # Steady State setup
    ys = nothing
    if hasfield(typeof(res), :trends) && hasfield(typeof(res.trends), :endogenous_steady_state)
        ys = res.trends.endogenous_steady_state
    end
    if ys === nothing; try ys = getproperty(res, :endogenous_steady_state) catch end; end
    if ys === nothing && hasfield(typeof(res), :ss); ys = res.ss; end
    if ys === nothing; error("Steady State not found."); end
    
    # Matrices setup
    lre = res.linearrationalexpectations
    ghx = real.(lre.g1_1)
    ghu = real.(lre.g1_2)
    
    # Variable Names setup
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
    
    # State Indices setup
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

# --- Core Simulation Logic ---
# Ahora acepta 'shocks' como argumento explícito (n_shocks x T)
function simulate_model_core(sol::ModelSolution, shocks::Matrix{Float64})
    n_vars = length(sol.ss)
    T = size(shocks, 2)
    n_states = length(sol.state_indices)
    
    sim_dev = zeros(n_vars, T)
    states = zeros(n_states)
    
    for t in 1:T
        # y_t = A * y_{t-1} + B * u_t
        y_dev = sol.ghx * states + sol.ghu * shocks[:, t]
        sim_dev[:, t] = y_dev
        states = y_dev[sol.state_indices]
    end
    
    # Retornamos desviaciones y niveles
    sim_lvl = zeros(T, n_vars)
    for t in 1:T
        sim_lvl[t, :] = sol.ss + sim_dev[:, t]
    end
    
    # Retornamos data transpuesta (T x vars) para facilitar uso
    return sim_dev', sim_lvl
end

# --- Generic Monte Carlo ---
# Esta función sirve para P1 y P3
function monte_carlo_generic(sol::ModelSolution, 
                             process_func::Function; 
                             N::Int=1000, 
                             T::Int=200,
                             shock_mask::Union{Vector{Float64}, Nothing}=nothing,
                             sigma_eps::Float64=1.0)
    
    n_shocks = size(sol.ghu, 2)
    
    # Pre-allocate storage based on the first simulation result
    # to handle different return types (scalar for P3, tuple/matrix for P1)
    results = [] 

    for i in 1:N
        # 1. Generar Shocks
        shocks = randn(n_shocks, T) .* sigma_eps
        
        # 2. Aplicar Máscara (Para P3: apagar demanda o tecnología)
        if !isnothing(shock_mask)
            # shock_mask debe ser vector de tamaño n_shocks (ej: [1.0, 0.0])
            shocks .*= shock_mask
        end

        # 3. Simular
        # Usamos sim_dev (desviaciones) que es lo que usa Gali, 
        # pero también tenemos sim_lvl si lo necesitamos para P1
        sim_dev, sim_lvl = simulate_model_core(sol, shocks)

        # 4. Procesar (Calcular Loss o Momentos)
        # Pasamos ambas series para flexibilidad
        output = process_func(sim_dev, sim_lvl)
        push!(results, output)
    end

    return results
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

# --- Función de Procesamiento Específica para P1 ---
function procesar_momentos_rbc(sim_dev, sim_lvl, var_names)
    T, n_vars = size(sim_lvl)
    cycles = zeros(T, n_vars)
    
    # 1. Identificar la variable de producto ('y' o 'yM')
    idx_y = findfirst(x -> lowercase(x) == "y", var_names)
    if idx_y === nothing
        idx_y = findfirst(x -> x == "yM", var_names)
    end
    
    if idx_y === nothing
        # Fallback de seguridad si no encuentra y/yM
        return zeros(n_vars), zeros(n_vars), zeros(n_vars)
    end

    # 2. Tomar Logaritmos y aplicar Filtro HP
    for i in 1:n_vars
        val_col = abs.(sim_lvl[:, i])
        series_log = [v > 1e-9 ? log(v) : -10.0 for v in val_col]
        cycles[:, i] = hp_filter(series_log, 1600.0)
    end
    
    # 3. Calcular Estadísticas
    std_devs = std(cycles, dims=1)[:]
    
    # Desviación Relativa (Std Var / Std Output)
    std_y = std_devs[idx_y]
    rel_std = (std_y > 1e-10) ? (std_devs ./ std_y) : zeros(n_vars)
    
    # Correlación con el Producto
    corrs = zeros(n_vars)
    cycle_y = cycles[:, idx_y]
    for i in 1:n_vars
        if std(cycles[:, i]) > 1e-10
            corrs[i] = cor(cycles[:, i], cycle_y)
        end
    end
    # Retornamos una tupla con los 3 vectores
    return (std_devs, rel_std, corrs)
end