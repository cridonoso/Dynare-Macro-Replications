using CSV
using DataFrames
using Plots

# Cargar módulo de gráficos
include(joinpath(@__DIR__, "..", "..", "source", "plots.jl"))
using .Plotting

# --- 1. Configuración ---
project_root  = joinpath(@__DIR__, "..", "..")
target_models = ["1", "2", "3", "4", "5"]
output_dir    = joinpath(project_root, "results", "p1")

println(">>> Iniciando generación de gráficos de densidad comparativos...")

# --- 2. Recolección de Datos ---
data_dict = Dict{String, DataFrame}()

for m in target_models
    mc_file = joinpath(project_root, "results", "p1", m, "item5_montecarlo_results.csv")
    
    if isfile(mc_file)
        println("    -> Cargando datos Modelo $m...")
        data_dict[m] = CSV.read(mc_file, DataFrame)
    else
        println("⚠️  Advertencia: Resultados no encontrados para Modelo $m. Saltando.")
    end
end

if isempty(data_dict)
    error("No hay datos para graficar. Ejecuta primero 0_run_analysis.jl")
end

# --- 3. Generación de Gráficos ---
mkpath(output_dir)

# Generar versiones en Español e Inglés
Plotting.plot_combined_histograms("ES", data_dict, output_dir)
Plotting.plot_combined_histograms("EN", data_dict, output_dir)

println(">>> Proceso finalizado. PDF guardados en: $output_dir")