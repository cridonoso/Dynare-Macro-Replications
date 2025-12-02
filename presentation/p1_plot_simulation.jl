# Nombre: p1_plot_simulation.jl
# Tarea:  Genera un gráfico con las series de tiempo de una simulación única.

using CSV
using DataFrames

# Cargar nuestro módulo de gráficos estandarizado
include(joinpath(@__DIR__, "..", "source", "plots.jl"))
using .Plotting

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
target_model = "1" # Modelo por defecto
if !isempty(ARGS)
    target_model = ARGS[1]
end

res_path = joinpath(project_root, "results", "p1", target_model)
sim_file = joinpath(res_path, "item4_single_simulation.csv")

if !isfile(sim_file)
    error("Archivo de simulación no encontrado: $sim_file. Ejecuta p1_simulate.jl primero.")
end

println(">>> Leyendo datos de simulación del modelo $target_model...")
df_sim = CSV.read(sim_file, DataFrame)

# --- Generar Gráficos ---
println(">>> Generando gráficos de series de tiempo...")

# Generar gráfico en español
Plotting.plot_simulation_timeseries("ES", target_model, df_sim, res_path)

# Generar gráfico en inglés
Plotting.plot_simulation_timeseries("EN", target_model, df_sim, res_path)

plot_dir = joinpath(res_path, "plots")
println(">>> Gráficos guardados en: $plot_dir")