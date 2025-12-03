using Dynare
using CSV
using DataFrames
using Statistics
using LinearAlgebra
using SparseArrays

# --- 1. Configuración de Entorno ---
project_root = joinpath(@__DIR__, "..", "..")
source_dir   = joinpath(project_root, "source")

# Cargar librerías y módulos locales
include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "simulation.jl"))
include(joinpath(source_dir, "p1_logic.jl"))
using .HansenReplication

# --- 2. Parámetros Globales ---
N_ITERATIONS  = 10000 
T_PERIODS     = 200     
target_models = ["1", "2", "3", "4", "5"]

# Wrapper para conectar la lógica de simulación con el módulo de replicación
function my_sim_wrapper(sys, T)
    _, sim_lvl = simulate_model_core(sys, T)
    return sim_lvl
end

println(">>> INICIANDO ANÁLISIS PROBLEMA 1 (Modelos: $target_models)")

# --- 3. Bucle Principal de Procesamiento ---
for model_id in target_models
    println("\n" * "="^60)
    println(">>> Procesando Modelo $model_id...")
    println("="^60)

    # Definición de rutas
    mod_file = "$model_id.mod"
    mod_path = joinpath(project_root, "modfiles", "p1", mod_file)
    res_path = joinpath(project_root, "results", "p1", model_id)
    
    if !isdir(res_path) mkpath(res_path) end
    
    if !isfile(mod_path)
        println("⚠️ Advertencia: No se encontró $mod_path. Saltando.")
        continue
    end

    # A. Resolver modelo con Dynare
    println("   -> Solucionando modelo...")
    original_dir = pwd()
    cd(dirname(mod_path))
    context = eval(:(@dynare $mod_file)) 
    cd(original_dir)
    
    # Extraer sistema de ecuaciones y mapeo de variables
    sys = extract_solution(context)
    var_names = sys.endo_names
    vars_map = Dict(name => i for (i, name) in enumerate(var_names))
    
    # B. Simulación Única (Series de Tiempo)
    println("   -> Generando simulación de muestra ($T_PERIODS periodos)...")
    sim_single = my_sim_wrapper(sys, T_PERIODS)
    df_sim = DataFrame(sim_single, var_names)
    CSV.write(joinpath(res_path, "item4_single_simulation.csv"), df_sim)

    # C. Simulación Monte Carlo (Momentos)
    println("   -> Ejecutando Monte Carlo ($N_ITERATIONS iteraciones)...")
    df_mc = HansenReplication.run_monte_carlo(
        sys, vars_map, T_PERIODS, N_ITERATIONS; 
        sim_func=my_sim_wrapper
    )
    
    # D. Guardar Resultados Agregados
    out_file = joinpath(res_path, "item5_montecarlo_results.csv")
    CSV.write(out_file, df_mc)
    println("   ✅ Guardado: $out_file")
end

println("\n>>> Análisis y Simulaciones Completadas.")