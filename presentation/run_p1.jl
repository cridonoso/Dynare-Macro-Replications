using Dynare
using DelimitedFiles
using Statistics
using Plots

# --- Setup Paths ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "simulation.jl"))

# --- Params ---
N_ITERATIONS = 10000
T_PERIODS    = 200

# Parse Args: --model 1
target_models = ["1", "2", "3", "4", "5"]
idx = findfirst(x -> x == "--model" || x == "-m", ARGS)
if idx !== nothing && idx < length(ARGS)
    target_models = [ARGS[idx+1]]
end

println(">>> Running Models: ", target_models)

for model_id in target_models
    println("\n" * "="^40)
    println(" PROCESSING MODEL $model_id")
    println("="^40)
    
    mod_file = "$model_id.mod"
    mod_path = joinpath(project_root, "modfiles", "p1", mod_file)
    res_path = joinpath(project_root, "results", "p1", "$model_id")
    
    if !isfile(mod_path)
        println("Skipping $model_id (File not found)")
        continue
    end

    # 1. Run Dynare & Clean
    original_dir = pwd()
    cd(dirname(mod_path))
    
    # Important: eval() needs interpolated string to work in local scope
    ctx = eval(:(@dynare $mod_file)) 
    
    cd(original_dir)
    organize_model_output(mod_path, res_path)
    
    # 2. Solve & Simulate
    sol = extract_solution(ctx)
    println(">>> Steady State found.")
    
    d_std, d_rel, d_corr = run_monte_carlo(sol, N_ITERATIONS, T_PERIODS)
    
    # 3. Save Data
    m_std  = mean(d_std, dims=1)[:]
    m_rel  = mean(d_rel, dims=1)[:]
    m_corr = mean(d_corr, dims=1)[:]
    
    csv_out = joinpath(res_path, "moments_summary.csv")
    open(csv_out, "w") do io
        println(io, "Statistic," * join(sol.endo_names, ","))
        println(io, "StdDev," * join(m_std, ","))
        println(io, "RelStdDev," * join(m_rel, ","))
        println(io, "CorrWithY," * join(m_corr, ","))
    end
    println(">>> CSV saved: $csv_out")
    
    # 4. Plots
    vars = ["y", "c", "i", "h", "yM", "hM", "productivity"]
    for v in vars
        idx = findfirst(x -> x == v, sol.endo_names)
        if idx !== nothing
            p1 = histogram(d_rel[:, idx], label="Rel Std ($v)", bins=50, alpha=0.6)
            savefig(p1, joinpath(res_path, "hist_rel_std_$v.png"))
            
            p2 = histogram(d_corr[:, idx], label="Corr ($v, Y)", bins=50, color=:red, alpha=0.6)
            savefig(p2, joinpath(res_path, "hist_corr_$v.png"))
        end
    end
    println(">>> Histograms saved.")
end