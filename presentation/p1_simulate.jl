# 
using Dynare
using DelimitedFiles
using Statistics
using LinearAlgebra
using CSV
using DataFrames
using StatsBase

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
N_ITERATIONS = 10000 
T_PERIODS    = 200     

# --- Cargar Utilidades ---
include(joinpath(source_dir, "utils.jl")) 
include(joinpath(source_dir, "simulation.jl"))

# --- Helper: Simulación de Series de Tiempo ---
# Esta función corrige el error "simulate_time_series not defined"
function simulate_time_series(sol, T)
    # 1. Obtener dimensión de shocks (eps_a)
    n_shocks = size(sol.ghu, 2)
    # 2. Generar shocks N(0,1). Nota: La matriz GHU de Dynare ya incluye 
    #    la desviación estándar (sigma_eps) si se declaró en 'shocks' del .mod.
    shocks = randn(n_shocks, T)
    # 3. Simular usando la función core de simulation.jl
    #    Retorna (desviaciones, niveles). Usamos niveles para filtrar después.
    _, sim_lvl = simulate_model_core(sol, shocks)
    return sim_lvl
end

# --- Helper: Calcular Estadísticas Hansen & Wright (Tabla 3) ---
function calculate_hansen_stats(sim_lvl, vars_map)
    # Mapeo de variables requeridas
    # Ajusta los nombres según tu archivo .mod (invest vs i, productivity vs p, etc.)
    keys_req = ["y", "c", "invest", "h", "productivity"]
    
    # Matriz para guardar ciclos HP
    T = size(sim_lvl, 1)
    cycles = Dict{String, Vector{Float64}}()

    # 1. Aplicar Log y Filtro HP a cada variable de interés
    for v in keys_req
        if !haskey(vars_map, v)
            error("Variable $v no encontrada en el modelo. Verifica nombres en .mod")
        end
        idx = vars_map[v]
        raw_series = sim_lvl[:, idx]
        
        # Logaritmo (protegido contra valores negativos/cero)
        log_series = log.(max.(raw_series, 1e-8))
        
        # Filtro HP (lambda=1600 para trimestral)
        cycles[v] = hp_filter(log_series, 1600.0)
    end

    # 2. Calcular Desviaciones Estándar
    # NO se multiplica por 100 aquí. La tabla final puede formatear si es necesario.
    # El problema de los valores "outlier" venía de aquí.
    sd = Dict(k => std(cycles[k]) for k in keys_req)
    
    # 3. Calcular Correlaciones
    # Hansen Table 3 Columns:
    # Col 1: SD Output
    stat_sy = sd["y"]
    
    # Col 2-5: Relative SD vs Output
    stat_sc_sy = sd["c"] / sd["y"]
    stat_si_sy = sd["invest"] / sd["y"]
    stat_sh_sy = sd["h"] / sd["y"]
    stat_sp_sy = sd["productivity"] / sd["y"]
    
    # Col 6: Relative SD Hours vs Productivity
    stat_sh_sp = sd["h"] / sd["productivity"]
    
    # Col 7: Correlation Hours vs Productivity
    stat_corr_hp = cor(cycles["h"], cycles["productivity"])
    
    return [stat_sy, stat_sc_sy, stat_si_sy, stat_sh_sy, stat_sp_sy, stat_sh_sp, stat_corr_hp]
end

# --- Loop Principal ---
target_models = ["1", "2", "3", "4", "5"]
idx = findfirst(x -> x == "--model" || x == "-m", ARGS)
if idx !== nothing && idx < length(ARGS)
    target_models = [ARGS[idx+1]]
end

for model_id in target_models
    println("\n>>> Procesando Modelo $model_id...")
    mod_file = "$model_id.mod"
    mod_path = joinpath(project_root, "modfiles", "p1", mod_file)
    res_path = joinpath(project_root, "results", "p1", "$model_id")
    mkpath(res_path)
    
    if !isfile(mod_path)
        println("Advertencia: No se encontró $mod_path")
        continue
    end

    # 1. Resolver modelo con Dynare
    println("--- (Ítems 1-3) Solucionando modelo... ---")
    original_dir = pwd()
    cd(dirname(mod_path))
    context = eval(:(@dynare $mod_file)) 
    cd(original_dir)
    
    # Extraer solución y mapa de variables
    sys = extract_solution(context)
    
    # Crear mapa de nombres a índices
    var_names = sys.endo_names
    vars_map = Dict(name => i for (i, name) in enumerate(var_names))
    
    # ---------------------------------------------------------
    # ITEM 4: Simular modelo estocástico para 200 periodos
    # ---------------------------------------------------------
    println("--- (Ítem 4) Guardando simulación única de 200 periodos ---")
    
    # Generar una simulación
    sim_lvl_single = simulate_time_series(sys, T_PERIODS)
    
    # Guardar en CSV para graficar o inspeccionar
    df_sim = DataFrame(sim_lvl_single, var_names)
    single_sim_path = joinpath(res_path, "item4_single_simulation.csv")
    CSV.write(single_sim_path, df_sim)
    println("    -> Guardado en: $single_sim_path")

    # ---------------------------------------------------------
    # ITEM 5: Simular 10,000 series y calcular estadísticas
    # ---------------------------------------------------------
    println("--- (Ítem 5) Ejecutando Monte Carlo ($N_ITERATIONS iters) ---")
    
    mc_stats = zeros(N_ITERATIONS, 7)
    
    # Loop Monte Carlo
    # (Se podría usar Threads.@threads para acelerar)
    for i in 1:N_ITERATIONS
        if i % 1000 == 0; print("."); end
        
        # a. Simular trayectoria
        data_i = simulate_time_series(sys, T_PERIODS)
        
        # b. Calcular estadísticas (HP filter -> SDs -> Corrs)
        mc_stats[i, :] = calculate_hansen_stats(data_i, vars_map)
    end
    println("")
    
    # Guardar resultados
    headers = ["sigma_y", "rel_sigma_c", "rel_sigma_i", "rel_sigma_h", "rel_sigma_p", "rel_sigma_h_p", "corr_h_p"]
    df_mc = DataFrame(mc_stats, headers)
    
    mc_file = joinpath(res_path, "item5_montecarlo_results.csv")
    CSV.write(mc_file, df_mc)
    println("    -> Resultados Monte Carlo guardados en: $mc_file")
    
    println(">>> Modelo $model_id finalizado. Ejecuta p1_get_table.jl")
end