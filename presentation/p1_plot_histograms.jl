# Nombre: p1_plot_histograms.jl
# Tarea:  Carga los resultados Monte Carlo de todos los modelos y genera
#         gráficos de densidad comparativos.

using CSV
using DataFrames
using Plots

# Cargar nuestro módulo de gráficos estandarizado
include(joinpath(@__DIR__, "..", "source", "plots.jl"))
using .Plotting

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
target_models = ["1", "2", "3", "4", "5"] # Modelos a incluir en la comparación

println(">>> Iniciando generación de gráficos de densidad comparativos...")

# 1. Cargar datos de todos los modelos
data_dict = Dict{String, DataFrame}()

for m in target_models
    mc_file = joinpath(project_root, "results", "p1", m, "item5_montecarlo_results.csv")
    
    if isfile(mc_file)
        println("    -> Cargando datos Modelo $m...")
        data_dict[m] = CSV.read(mc_file, DataFrame)
    else
        println("⚠️  Advertencia: No se encontraron resultados para el Modelo $m en '$mc_file'. Saltando.")
    end
end

if isempty(data_dict)
    error("No se encontraron datos para graficar. Asegúrate de haber ejecutado p1_simulate.jl para al menos un modelo.")
end

# 2. Generar los gráficos comparativos
output_dir = joinpath(project_root, "results", "p1")
mkpath(output_dir)

# Generar gráfico en español
Plotting.plot_combined_histograms("ES", data_dict, output_dir)

# Generar gráfico en inglés
Plotting.plot_combined_histograms("EN", data_dict, output_dir)

println(">>> Proceso finalizado. Revisa la carpeta 'results/p1/' para los archivos PDF.")