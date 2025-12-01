# Runs Monte Carlo simulations for Part I (RBC Models).
using Dynare
using DelimitedFiles
using Statistics
using Plots
using LinearAlgebra
using CSV
using DataFrames

# --- Configuration ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
N_ITERATIONS = 10000
T_PERIODS    = 200
LANGUAGE     = "ES" # Options: "EN" or "ES"

# --- Load Utilities ---
include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "simulation.jl"))
include(joinpath(source_dir, "plots.jl"))

# --- Model Selection ---
target_models = ["1", "2", "3", "4", "5"]

# Check for command-line flags
idx = findfirst(x -> x == "--model" || x == "-m", ARGS)
if idx !== nothing && idx < length(ARGS)
    target_models = [ARGS[idx+1]]
end
plot_only_mode = "--plot-only" in ARGS

if plot_only_mode
    println("--- Running in PLOT-ONLY mode. Simulations will be skipped. ---")
end

# --- Main Loop ---
for model_id in target_models
    mod_file = "$model_id.mod"
    mod_path = joinpath(project_root, "modfiles", "p1", mod_file)
    res_path = joinpath(project_root, "results", "p1", "$model_id")
    
    if !isfile(mod_path)
        continue
    end
    
    # Define path for raw simulation data
    raw_data_path = joinpath(res_path, "raw_simulation_results.csv")
    
    # --- Data Generation or Loading ---
    if !plot_only_mode
        println("--- Running full simulation for Model $model_id ---")
        # 1. Solve model with Dynare
        original_dir = pwd()
        cd(dirname(mod_path))
        ctx = eval(:(@dynare $mod_file)) 
        cd(original_dir)
        organize_model_output(mod_path, res_path)
        
        # 2. Extract solution matrices
        sol = extract_solution(ctx)
        
        # 3. Define a processor function for the Monte Carlo simulation
        my_processor(d, l) = procesar_momentos_rbc(d, l, sol.endo_names)

        # 4. Run Monte Carlo simulation
        raw_results = monte_carlo_generic(sol, my_processor; N=N_ITERATIONS, T=T_PERIODS)
        
        # 5. Unpack and aggregate results into matrices
        n_vars = length(sol.endo_names)
        mat_std  = zeros(N_ITERATIONS, n_vars)
        mat_rel  = zeros(N_ITERATIONS, n_vars)
        mat_corr = zeros(N_ITERATIONS, n_vars)
        
        for i in 1:N_ITERATIONS
            mat_std[i, :], mat_rel[i, :], mat_corr[i, :] = raw_results[i]
        end
        
        # 6. Save raw simulation data for faster re-plotting
        df_raw = DataFrame()
        for (i, var_name) in enumerate(sol.endo_names)
            df_raw[!, "rel_std_$(var_name)"] = mat_rel[:, i]
            df_raw[!, "corr_$(var_name)"] = mat_corr[:, i]
        end
        CSV.write(raw_data_path, df_raw)
        println(">>> Raw simulation data saved to: $raw_data_path")

        # 7. Calculate and save summary statistics
        m_std  = mean(mat_std, dims=1)[:]
        m_rel  = mean(mat_rel, dims=1)[:]
        m_corr = mean(mat_corr, dims=1)[:]
        
        csv_out = joinpath(res_path, "moments_summary.csv")
        open(csv_out, "w") do io
            println(io, "Statistic," * join(sol.endo_names, ","))
            println(io, "StdDev," * join(m_std, ","))
            println(io, "RelStdDev," * join(m_rel, ","))
            println(io, "CorrWithY," * join(m_corr, ","))
        end
    end

    # 8. Generate and save histograms for key variables
    println("--- Generating plots for Model $model_id ---")
    if !isfile(raw_data_path)
        println("ERROR: Raw data file not found. Run simulation without --plot-only first.")
        continue
    end
    df_raw = CSV.read(raw_data_path, DataFrame)

    vars = ["y", "c", "i", "h", "yM", "hM", "productivity"]
    for v in vars
        rel_std_col = "rel_std_$(v)"
        corr_col = "corr_$(v)"
        if rel_std_col in names(df_raw) && corr_col in names(df_raw)
            Plotting.plot_moments_histograms(LANGUAGE, model_id, v, df_raw[!, rel_std_col], df_raw[!, corr_col], res_path)
        end
    end
end