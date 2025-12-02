# Nombre: p1_plot_histograms.jl
# Tarea:  Genera una figura con subplots de histogramas para cada estadística
#         calculada en las simulaciones de Monte Carlo.

using CSV
using DataFrames
using StatsBase
using Plots

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
target_model = "1" # Modelo por defecto
if !isempty(ARGS)
    # Permite especificar el modelo desde la línea de comandos, ej: julia script.jl 3
    target_model = ARGS[1]
end

results_path = joinpath(project_root, "results", "p1", target_model)
mc_file = joinpath(results_path, "item5_montecarlo_results.csv")

if !isfile(mc_file)
    error("Archivo de resultados Monte Carlo no encontrado: $mc_file. Ejecuta p1_simulate.jl para el modelo $target_model primero.")
end

println(">>> Leyendo datos de Monte Carlo del modelo $target_model...")
df_mc = CSV.read(mc_file, DataFrame)

# --- Generar Gráfico con Subplots ---
println(">>> Generando figura de histogramas con cuadrícula 2x4...")

# Nombres de las columnas para los títulos de los subplots
stat_names = names(df_mc)
N_stats = length(stat_names)

# Crear un layout de 2 filas y 4 columnas
plot_layout = (2, 4) # 4 columnas arriba, 3 abajo (para 7 stats)
main_plot = plot(
    layout = plot_layout, 
    size = (1200, 700), # Ajustado para 2 filas y 4 columnas
    legend = false,
    bottom_margin = 15Plots.Measures.mm # Expandir margen inferior para etiquetas del eje x
)

# Mapeo de nombres de columna a títulos más legibles para los gráficos
title_map = Dict(
    "sigma_y" => "σ(y)", "rel_sigma_c" => "σ(c)/σ(y)", "rel_sigma_i" => "σ(i)/σ(y)",
    "rel_sigma_h" => "σ(h)/σ(y)", "rel_sigma_p" => "σ(p)/σ(y)", "rel_sigma_h_p" => "σ(h)/σ(p)",
    "corr_h_p" => "corr(h,p)"
)

# Iterar sobre cada estadística y añadir un histograma como subplot
for (i, stat) in enumerate(stat_names)
    data = df_mc[!, stat]
    
    # Calcular el percentil 99 para establecer un límite superior razonable en el eje x
    # Esto evita que los outliers extremos "aplasten" el histograma.
    p99 = percentile(data, 99)
    # Asegurarse de que el límite no sea idéntico al mínimo si no hay varianza
    # También, asegurar que el mínimo no sea mayor que el máximo si los datos son constantes
    data_min = minimum(data)
    data_max = maximum(data)
    xlim_upper = p99 > data_min ? p99 : data_max
    xlim_lower = data_min

    if i == 1 # Solo el primer subplot tiene etiquetas y ticks en el eje Y
        histogram!(main_plot[i], data, 
            title = get(title_map, stat, stat), 
            bins=50,
            # normalize=:pdf, # Eliminado: ahora muestra conteos
            xlims=(xlim_lower, xlim_upper), # Aplica el límite del eje x
            yaxis = "Counts", # Etiqueta para el eje Y
            yticks = :auto,
            left_margin = 5Plots.Measures.mm # Margen para la etiqueta del eje Y
        )
    else # Los demás subplots no tienen etiquetas ni ticks en el eje Y
        histogram!(main_plot[i], data, 
            title = get(title_map, stat, stat), bins=50,
            xlims=(xlim_lower, xlim_upper), yaxis = nothing, yticks = nothing)
    end
end

output_file = joinpath(results_path, "item5_histograms_subplots.png")
savefig(main_plot, output_file)
println(">>> Gráfico con subplots guardado en: $output_file")