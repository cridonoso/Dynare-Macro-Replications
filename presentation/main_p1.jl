# -------------------------------------------------------------------------
# MAIN SCRIPT: RBC Stochastic Simulation
# -------------------------------------------------------------------------
using Dynare

project_root = joinpath(@__DIR__, "..") 
source_dir   = joinpath(project_root, "source")

# -------------------------------------------------------------------------
# Parse Command Line Arguments
# -------------------------------------------------------------------------
model_id = "1"  # default

idx = findfirst(x -> x == "--problem" || x == "-p", ARGS)
if idx !== nothing && idx < length(ARGS)
    model_id = ARGS[idx + 1]
end

println(">>> Configuration selected: Model $model_id")
model_path   = joinpath(project_root, "modfiles", "p1", "$(model_id).mod")
results_path = joinpath(project_root, "results", "p1", "$(model_id)")

if !isfile(model_path)
    error("El archivo de modelo no existe: $model_path")
end

include(joinpath(source_dir, "utils.jl"))      
include(joinpath(source_dir, "simulation.jl"))

# -------------------------------------------------------------------------
# Run Dynare
# -------------------------------------------------------------------------
println("\n>>> Processing Model: ", basename(model_path))
model_filename = basename(model_path)
context = eval(:(@dynare $model_path))
organize_model_output(model_path, results_path)

# -------------------------------------------------------------------------
# Simulation
# -------------------------------------------------------------------------
sol = extract_solution(context)

println("\n>>> Generating 200-period simulation...")
T_sim = 200
sigma = 0.007 
sim_data, var_names = simulate_model(sol, T_sim; sigma_eps=sigma)

# -------------------------------------------------------------------------
# Results
# -------------------------------------------------------------------------
println(">>> Simulation Complete.")
println(">>> Data Dimensions: ", size(sim_data))
println("\nLast 5 periods of variable $(var_names[1]):")
println(sim_data[end-4:end, 1])