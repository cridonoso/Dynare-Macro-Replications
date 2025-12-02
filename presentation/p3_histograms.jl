# Nombre: p3_plot_histograms.jl
# Tarea:  Genera la figura de comparación de histogramas (1x3) para la Parte III.

using CSV
using DataFrames
using Plots

# Cargar módulo de gráficos
include(joinpath(@__DIR__, "..", "source", "plots.jl"))
using .Plotting

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
target_models = ["gali_current", "gali_forward"]

# Definición de Escenarios (ID Carpeta, Nombre Clave)
# Esto debe coincidir con lo usado en simulate
scenarios_to_plot = [
    ("3", "1_Technology"),
    ("4", "2_Demand"),
    ("5", "3_Both")
]

println(">>> Iniciando generación de gráficos P3 (1x3)...")

# 1. Cargar todos los datos en memoria
# Estructura: all_data[scen_id][model_name] = Vector{Float64}
all_data = Dict{String, Dict{String, Vector{Float64}}}()

for (scen_id, scen_key) in scenarios_to_plot
    results_path = joinpath(project_root, "results", "p3", scen_id)
    all_data[scen_id] = Dict{String, Vector{Float64}}()
    
    for m in target_models
        csv_file = joinpath(results_path, "raw_loss_$(m).csv")
        if isfile(csv_file)
            df = CSV.read(csv_file, DataFrame)
            all_data[scen_id][m] = df.Loss
        else
            println("⚠️  Faltan datos para $m en escenario $scen_key. (Ejecuta simulate primero)")
        end
    end
end

# 2. Generar Gráfico
output_dir = joinpath(project_root, "results", "p3")
mkpath(output_dir)

# Versión Español
Plotting.plot_p3_combined_histograms("ES", all_data, scenarios_to_plot, output_dir)

# Versión Inglés
Plotting.plot_p3_combined_histograms("EN", all_data, scenarios_to_plot, output_dir)

println(">>> ¡Listo! Gráficos guardados en $output_dir")