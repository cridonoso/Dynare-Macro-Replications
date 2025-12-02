# Nombre: p3_simulate.jl
# Tarea:  SOLO SIMULACIÓN. Ejecuta Monte Carlo y guarda los datos en CSV.

using Dynare
using Printf
using CSV
using DataFrames
using Statistics
using LinearAlgebra

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
N_SIMULATIONS = 10000
T_PERIODS     = 200

# Parámetros (Galí 2015)
siggma  = 1.0  
alppha  = 0.25
epsilon = 9.0 
theta   = 0.75
varphi  = 5.0 

MODELS = ["gali_current", "gali_forward"] 

# Cargar utilidades
include(joinpath(source_dir, "utils.jl")) 
include(joinpath(source_dir, "simulation.jl"))
include(joinpath(source_dir, "loss.jl")) 
# Nota: Ya no necesitamos "plots.jl" aquí obligatoriamente, pero no hace daño dejarlo.

# ... (Mantén la función generate_table_4_1 igual que antes) ...
function generate_table_4_1(models, project_root, Wy, Wpi)
    # ... (CÓDIGO DE TABLA 4.1 NO CAMBIA) ...
    # (Pégalo de tu versión anterior, solo calcula momentos teóricos)
    println("\n--- [Ítem 2] Generando Tabla 4.1 ---")
    # ... (lógica de tabla) ...
end

function run_loss_simulations_only(models, project_root, Wy, Wpi, scenarios)
    println("\n--- [Ítems 3-5] Ejecutando Simulaciones (Guardando CSV) ---")

    for (scen_id, scen_name, mask) in scenarios
        println("\n>>> Escenario: $scen_name")
        results_path = joinpath(project_root, "results", "p3", scen_id)
        mkpath(results_path)

        for model_name in models
            mod_path = joinpath(project_root, "modfiles", "p3", model_name * ".mod")
            csv_path = joinpath(results_path, "raw_loss_$(model_name).csv")

            if !isfile(mod_path); continue; end
            
            # Si el archivo ya existe, podríamos saltarlo, pero aquí forzamos recálculo 
            # o puedes agregar un chequeo if isfile(csv_path) ...
            
            println("    Simulando $model_name ...")
            context = eval(:(@dynare $mod_path))
            sol = extract_solution(context)
            
            # Aplicar Máscara a Sigma
            Sigma_masked = copy(sol.Sigma_e)
            if length(mask) >= size(Sigma_masked, 1)
                M = Diagonal(mask[1:size(Sigma_masked,1)])
                Sigma_masked = M * Sigma_masked * M'
            end
            
            sol_masked = ModelSolution(
                sol.ss, sol.ghx, sol.ghu, Matrix(Sigma_masked),
                sol.state_indices, sol.order_var, sol.inv_order_var, sol.endo_names
            )

            # Monte Carlo
            losses = Float64[]
            idx_y = findfirst(==("y_gap"), sol.endo_names)
            idx_pi = findfirst(==("pi"), sol.endo_names)

            for i in 1:N_SIMULATIONS
                sim_dev, _ = simulate_model_core(sol_masked, T_PERIODS)
                y_series = sim_dev[:, idx_y]
                pi_series = sim_dev[:, idx_pi]
                
                # Pérdida (escalada a %)
                L_i = 0.5 * (Wy * var(y_series) + Wpi * var(pi_series)) * (100^2)
                push!(losses, L_i)
            end
            
            # GUARDAR CSV
            CSV.write(csv_path, DataFrame(Loss=losses))
            println("    -> Guardado: $csv_path")
        end
        # ¡AQUÍ QUITAMOS LA LLAMADA A PLOTTING!
    end
end

# ... (generate_summary_table igual) ...

function main()
    println(">>> Calculando pesos...")
    Wy, Wpi = get_weights(alppha, epsilon, theta, varphi)

    scenarios = [
        ("3", "1_Technology", [1.0, 0.0]),
        ("4", "2_Demand",     [0.0, 1.0]),
        ("5", "3_Both",       [1.0, 1.0])
    ]

    # 1. Tabla Teórica
    generate_table_4_1(MODELS, project_root, Wy, Wpi)
    
    # 2. Simulaciones (Solo genera CSV)
    run_loss_simulations_only(MODELS, project_root, Wy, Wpi, scenarios)
    
    # 3. Tabla Resumen (Lee CSVs)
    # generate_summary_table(...) # Puedes incluirla o separarla también
    
    println("\n>>> Simulaciones listas. Ahora ejecuta p3_plot_histograms.jl")
end

main()