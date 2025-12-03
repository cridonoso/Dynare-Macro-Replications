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

# Parámetros
siggma  = 1.0  
alppha  = 0.25
epsilon = 9.0 
theta   = 0.75
varphi  = 5.0 

MODELS = ["gali_current", "gali_forward"] 

include(joinpath(source_dir, "utils.jl")) 
include(joinpath(source_dir, "simulation.jl"))
include(joinpath(source_dir, "loss.jl")) 

function run_simulations(models, project_root, Wy, Wpi, scenarios)
    println("\n--- Ejecutando Simulaciones (Guardando CSV) ---")

    for (scen_id, scen_name, mask) in scenarios
        println("\n>>> Escenario: $scen_name")
        results_path = joinpath(project_root, "results", "p3", scen_id)
        mkpath(results_path)

        for model_name in models
            mod_path = joinpath(project_root, "modfiles", "p3", model_name * ".mod")
            csv_path = joinpath(results_path, "raw_loss_$(model_name).csv")

            if !isfile(mod_path); continue; end
            
            println("    Simulando $model_name ...")
            context = eval(:(@dynare $mod_path))
            sol = extract_solution(context)
            
            # Aplicar Máscara
            Sigma_masked = copy(sol.Sigma_e)
            if length(mask) >= size(Sigma_masked, 1)
                M = Diagonal(mask[1:size(Sigma_masked,1)])
                Sigma_masked = M * Sigma_masked * M'
            end
            
            sol_masked = ModelSolution(sol.ss, sol.ghx, sol.ghu, Matrix(Sigma_masked), sol.state_indices, sol.order_var, sol.inv_order_var, sol.endo_names)

            losses = Float64[]
            idx_y = findfirst(==("y_gap"), sol.endo_names)
            idx_pi = findfirst(==("pi"), sol.endo_names)

            for i in 1:N_SIMULATIONS
                sim_dev, _ = simulate_model_core(sol_masked, T_PERIODS)
                y_series = sim_dev[:, idx_y]
                pi_series = sim_dev[:, idx_pi]
                # Pérdida escalada
                L_i = 0.5 * (Wy * var(y_series) + Wpi * var(pi_series)) * (100^2)
                push!(losses, L_i)
            end
            
            CSV.write(csv_path, DataFrame(Loss=losses))
            println("    -> Guardado: $csv_path")
        end
    end
end

function main()
    Wy, Wpi = get_weights(alppha, epsilon, theta, varphi)
    scenarios = [
        ("3", "1_Technology", [1.0, 0.0]),
        ("4", "2_Demand",     [0.0, 1.0]),
        ("5", "3_Both",       [1.0, 1.0])
    ]
    run_simulations(MODELS, project_root, Wy, Wpi, scenarios)
    println("\n>>> Simulaciones listas. Ejecuta p3_plot_histograms.jl")
end

main()