using Dynare
using LinearAlgebra
using Random
using Statistics

# =========================================================================================
# ESTRUCTURAS DE DATOS
# =========================================================================================

# Contenedor para la solución del modelo DSGE (Estado Estacionario y Reglas de Decisión)
struct ModelSolution
    ss::Vector{Float64}         # Estado Estacionario
    ghx::Matrix{Float64}        # Matriz de transición (estados)
    ghu::Matrix{Float64}        # Matriz de impacto (shocks)
    Sigma_e::Matrix{Float64}    # Covarianza de los shocks
    state_indices::Vector{Int}  # Índices de variables de estado
    order_var::Vector{Int}      # Orden original de variables
    inv_order_var::Vector{Int}  # Orden inverso
    endo_names::Vector{String}  # Nombres de variables endógenas
end

# =========================================================================================
# LÓGICA DE EXTRACCIÓN
# =========================================================================================

# Extrae la solución y metadatos desde el contexto de salida de Dynare
function extract_solution(context)
    res = context.results.model_results[1]
    model = context.models[1]
    
    # 1. Recuperar Estado Estacionario (busca en múltiples ubicaciones posibles)
    ys = nothing
    if hasfield(typeof(res), :trends) && hasfield(typeof(res.trends), :endogenous_steady_state)
        ys = res.trends.endogenous_steady_state
    end
    if ys === nothing; try ys = getproperty(res, :endogenous_steady_state) catch end; end
    if ys === nothing && hasfield(typeof(res), :ss); ys = res.ss; end
    if ys === nothing; error("Steady State not found."); end
    
    # 2. Extraer Reglas de Decisión (Política y Transición)
    lre = res.linearrationalexpectations
    ghx = real.(lre.g1_1)
    ghu = real.(lre.g1_2)
    
    # 3. Configurar Matriz de Covarianza (Sigma_e)
    # Si no existe explícitamente, asume matriz identidad con advertencia
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

    # 4. Mapeo de Nombres de Variables Endógenas
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
    
    # 5. Identificar Variables de Estado (Predeterminadas)
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

# =========================================================================================
# MOTOR DE SIMULACIÓN
# =========================================================================================

# Ejecuta una simulación estocástica del modelo linealizado
function simulate_model_core(sol::ModelSolution, T::Int)
    n_vars = length(sol.ss)
    n_states = length(sol.state_indices)
    n_shocks = size(sol.ghu, 2)
    
    # 1. Generar Shocks Correlacionados
    # Usa descomposición de Cholesky para aplicar la estructura de covarianza
    Sigma = sol.Sigma_e
    L = try
        cholesky(Hermitian(Sigma)).L
    catch
        sqrt.(abs.(Sigma)) # Fallback si la matriz no es definida positiva
    end
    
    white_noise = randn(n_shocks, T)
    shocks = L * white_noise
    
    # 2. Iteración Temporal (Modelo en desviaciones)
    sim_dev = zeros(n_vars, T)
    states = zeros(n_states)
    
    for t in 1:T
        # Ecuación de transición: y_t = A * estados_{t-1} + B * shocks_t
        y_dev = sol.ghx * states + sol.ghu * shocks[:, t]
        
        sim_dev[:, t] = y_dev
        states = y_dev[sol.state_indices] # Actualizar estados para siguiente periodo
    end
    
    # 3. Recuperar Niveles (Agregar SS)
    sim_lvl = zeros(T, n_vars)
    for t in 1:T
        sim_lvl[t, :] = sol.ss + sim_dev[:, t]
    end
    
    # Retorna: Desviaciones (transpuesta), Niveles (transpuesta)
    return sim_dev', sim_lvl
end