# Runs simulations for Part III (New-Keynesian Model).
using Dynare
using Statistics
using Plots
using LinearAlgebra
using Printf
using CSV
using DataFrames

# --- Configuration ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
N_SIMULATIONS = 10000
T_PERIODS     = 200
siggma = 1.0  
varphi = 5.0
alppha = 0.25
epsilon = 9.0 
theta = 0.75
betta = 0.99
LANGUAGE = "ES" # Options: "EN" or "ES"
modelos = ["gali_current", "gali_forward"] 

# --- Load Utilities ---
include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "simulation.jl"))
include(joinpath(source_dir, "loss.jl"))
include(joinpath(source_dir, "plots.jl"))

# Check for plot-only mode
plot_only_mode = "--plot-only" in ARGS
if plot_only_mode
    println("--- Running in PLOT-ONLY mode. Simulations will be skipped. ---")
end

# --- Setup ---
Wy, Wpi = get_weights(alppha, epsilon, theta, varphi)

scenarios = Dict(
    "1_Technology" => [1.0, 0.0], # Shock on eps_a
    "2_Demand"     => [0.0, 1.0], # Shock on eps_z
    "3_Both"       => [1.0, 1.0]
)

# --- Main Loop ---
for model_name in modelos
    mod_file = model_name * ".mod"
    mod_path = joinpath(project_root, "modfiles", "p3", mod_file)
    res_path = joinpath(project_root, "results", "p3", model_name)
    
    if !isfile(mod_path)
        continue
    end

    # --- Loop over scenarios ---
    for (scen_name, mask) in scenarios
        raw_data_path = joinpath(res_path, "raw_loss_$(scen_name).csv")
        
        if !plot_only_mode
            println("--- Running full simulation for Model '$model_name', Scenario '$scen_name' ---")
            # 1. Solve model (only needs to be done once per model)
            if scen_name == "1_Technology" # Run only on first scenario
                original_dir = pwd()
                cd(dirname(mod_path))
                global context = eval(:(@dynare $mod_file)) 
                cd(original_dir)
                organize_model_output(mod_path, res_path)
            end
            sol = extract_solution(context)
            
            # 2. Identify variable indices
            idx_ygap = findfirst(x -> x == "y_gap", sol.endo_names)
            idx_pi   = findfirst(x -> x == "pi", sol.endo_names)

            # 3. Define a processor function (closure) to calculate welfare loss
            function calculate_loss(sim_dev, sim_lvl)
                series_y = sim_dev[:, idx_ygap]
                series_pi = sim_dev[:, idx_pi]
                return 0.5 * (Wy * var(series_y) + Wpi * var(series_pi))
            end

            # 4. Execute simulation for the scenario
            loss_results = monte_carlo_generic(sol, calculate_loss; 
                                                  N=N_SIMULATIONS, 
                                                  T=T_PERIODS, 
                                                  shock_mask=mask)
            
            # 5. Save raw loss data
            losses = Float64.(loss_results)
            CSV.write(raw_data_path, DataFrame(Loss=losses))
            println(">>> Raw loss data saved to: $raw_data_path")
        end

        # 6. Generate plots
        println("--- Generating plot for Model '$model_name', Scenario '$scen_name' ---")
        if !isfile(raw_data_path)
            println("ERROR: Raw data file not found. Run simulation without --plot-only first.")
            continue
        end
        df_raw = CSV.read(raw_data_path, DataFrame)
        Plotting.plot_loss_histogram(LANGUAGE, model_name, scen_name, df_raw.Loss, res_path)
    end
end