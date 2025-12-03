# Script: 1_run_simulations.jl
# Propósito: Ejecuta simulaciones Monte Carlo y guarda las pérdidas en CSV.
#            Usa cálculo de pesos consistente con script teórico.

using Dynare
using CSV
using DataFrames
using Statistics
using LinearAlgebra

# --- 1. Configuración ---
project_root  = joinpath(@__DIR__, "..", "..")
source_dir    = joinpath(project_root, "source")
N_SIMULATIONS = 10000
T_PERIODS     = 200

include(joinpath(source_dir, "utils.jl")) 
include(joinpath(source_dir, "simulation.jl"))

# --- 2. Cálculo de Pesos (Consistente con script 0) ---
sigma_c = 1.0; varphi = 5.0; alpha = 0.25; epsilon = 9.0; theta = 0.75; beta = 0.99
Omega   = (1 - alpha) / (1 - alpha + alpha * epsilon)
lambda  = (1 - theta) * (1 - beta * theta) / theta * Omega

Wy  = sigma_c + (varphi + alpha) / (1 - alpha)
Wpi = epsilon / lambda

println(">>> Usando pesos: Wy = $(round(Wy, digits=2)), Wpi = $(round(Wpi, digits=2))")

models_list = ["gali_current", "gali_forward"]

# Escenarios (ID Carpeta, Nombre, Máscara [e_a, e_z])
scenarios = [
    ("3", "1_Technology", [1.0, 0.0]), 
    ("4", "2_Demand",     [0.0, 1.0]), 
    ("5", "3_Both",       [1.0, 1.0])  
]

println(">>> INICIANDO SIMULACIONES MONTE CARLO (N=$N_SIMULATIONS)")

for (scen_id, scen_name, shock_mask) in scenarios
    println("\n" * "="^60)
    println(">>> Procesando: $scen_name (ID: $scen_id)")
    
    out_dir = joinpath(project_root, "results", "p3", scen_id)
    mkpath(out_dir)
    
    for m in models_list
        mod_path = joinpath(project_root, "modfiles", "p3", "$m.mod")
        csv_path = joinpath(out_dir, "loss_dist_$m.csv")
        
        println("   -> Modelo: $m")
        
        # A. Resolver
        context = eval(:(@dynare $mod_path))
        sol = extract_solution(context)
        
        # B. Aplicar Máscara
        Sigma_masked = copy(sol.Sigma_e)
        Mask_matrix  = Diagonal(shock_mask[1:size(Sigma_masked, 1)])
        Sigma_masked = Mask_matrix * Sigma_masked * Mask_matrix'
        
        sol_active = ModelSolution(
            sol.ss, sol.ghx, sol.ghu, Matrix(Sigma_masked), 
            sol.state_indices, sol.order_var, sol.inv_order_var, sol.endo_names
        )

        # C. Simular
        losses = Float64[]
        idx_y  = findfirst(==("y_gap"), sol.endo_names)
        idx_pi = findfirst(==("pi"), sol.endo_names)

        for i in 1:N_SIMULATIONS
            sim_data, _ = simulate_model_core(sol_active, T_PERIODS)
            y_gap_t = sim_data[:, idx_y]
            pi_t    = sim_data[:, idx_pi]
            
            # Pérdida SIN escalar (unidades crudas)
            l_i = 0.5 * (Wy * var(y_gap_t) + Wpi * var(pi_t))
            push!(losses, l_i)
        end
        
        CSV.write(csv_path, DataFrame(Loss=losses))
        println("      ✅ Guardado en: $csv_path")
    end
end

println("\n>>> Simulaciones completadas.")