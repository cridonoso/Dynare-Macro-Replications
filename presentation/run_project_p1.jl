# -------------------------------------------------------------------------
# MAIN SCRIPT: Hansen & Wright (1992) Replication
# -------------------------------------------------------------------------
using Dynare
using DelimitedFiles
using Statistics
using Plots

project_root = joinpath(@__DIR__, "..") 
source_dir   = joinpath(project_root, "source")

# Cargar librerías locales
include(joinpath(source_dir, "utils.jl"))      
include(joinpath(source_dir, "simulation.jl"))

# Configuración
N_ITERATIONS = 10000
T_PERIODS    = 200

# Seleccionar modelo por argumento (default: todos o uno especifico)
target_models = ["1", "2", "3", "4", "5"]
# Si pasas argumento, usa ese. Ej: julia run.jl --model 2
idx_arg = findfirst(x -> x == "--model" || x == "-m", ARGS)
if idx_arg !== nothing && idx_arg < length(ARGS)
    target_models = [ARGS[idx_arg + 1]]
end

println(">>> Starting Replication for Models: ", target_models)

for model_id in target_models
    println("\n==================================================")
    println(" PROCESSING MODEL $model_id")
    println("==================================================")
    
    model_path = joinpath(project_root, "modfiles", "p1", "$model_id.mod")
    results_path = joinpath(project_root, "results", "p1", "$model_id")
    
    if !isfile(model_path)
        println("Skipping Model $model_id (File not found)")
        continue
    end

    # 1. Ejecutar Dynare y Limpiar
    context = eval(:(@dynare $model_path))
    organize_model_output(model_path, results_path)
    
    # 2. Extraer Solución
    sol = extract_solution(context)
    println(">>> Steady State found.")
    
    # 3. Monte Carlo Simulation
    println(">>> Starting Monte Carlo ($N_ITERATIONS iterations)...")
    d_std, d_rel_std, d_corr = run_monte_carlo(sol, N_ITERATIONS, T_PERIODS)
    
    # 4. Guardar Resultados (CSV)
    # Guardamos las medias de las estadísticas para comparar con Tabla 3 del paper
    mean_std = mean(d_std, dims=1)[:]
    mean_rel = mean(d_rel_std, dims=1)[:]
    mean_corr = mean(d_corr, dims=1)[:]
    
    header = sol.endo_names
    
    output_csv = joinpath(results_path, "moments_summary.csv")
    open(output_csv, "w") do io
        println(io, "Statistic," * join(header, ","))
        println(io, "StdDev," * join(mean_std, ","))
        println(io, "RelStdDev," * join(mean_rel, ","))
        println(io, "CorrWithY," * join(mean_corr, ","))
    end
    println(">>> Summary saved to: $output_csv")
    
    # 5. Generar Histogramas (Inciso 6)
    # Generamos histogramas para variables clave: y, c, i, h
    println(">>> Generating Histograms...")
    vars_to_plot = ["y", "c", "i", "h"] # Ajustar según disponibilidad en el modelo
    
    for var_name in vars_to_plot
        idx = findfirst(x -> x == var_name, sol.endo_names)
        if idx !== nothing
            p = histogram(d_rel_std[:, idx], label="Rel. Std Dev ($var_name)", bins=50, alpha=0.6)
            title!("Model $model_id: Volatility of $var_name relative to Y")
            savefig(p, joinpath(results_path, "hist_rel_std_$(var_name).png"))
            
            p2 = histogram(d_corr[:, idx], label="Corr ($var_name, Y)", bins=50, color=:red, alpha=0.6)
            title!("Model $model_id: Correlation of $var_name with Y")
            savefig(p2, joinpath(results_path, "hist_corr_$(var_name).png"))
        end
    end
    println(">>> Histograms saved.")
end

println("\n>>> All tasks completed successfully.")