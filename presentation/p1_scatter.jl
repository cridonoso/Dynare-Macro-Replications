# Nombre: p1_scatter.jl
# Tarea: Genera UN gráfico combinado con los scatter plots de los 5 modelos (1x5).

using CSV
using DataFrames
using Statistics
using Plots

# Cargar módulos del proyecto
include(joinpath(@__DIR__, "..", "source", "plots.jl"))
using .Plotting
include(joinpath(@__DIR__, "..", "source", "simulation.jl"))

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")

# Definimos los modelos explícitamente para asegurar el orden 1 al 5 en el gráfico
target_models = ["1", "2", "3", "4", "5"]

println(">>> Iniciando generación de Scatter Plot combinado (1x5) para modelos: $target_models")

# Listas para almacenar los objetos de gráficos individuales
plots_list_ES = []
plots_list_EN = []

# --- Loop de Recolección de Datos y Generación de Gráficos ---
for model_id in target_models
    res_path = joinpath(project_root, "results", "p1", model_id)
    sim_file = joinpath(res_path, "item4_single_simulation.csv")

    # Manejo de archivos faltantes: crear gráfico vacío para mantener la grilla
    if !isfile(sim_file)
        println("⚠️  Advertencia: No se encontró simulación para el Modelo $model_id. Usando gráfico vacío.")
        empty_p = plot(framestyle=:none, title="Model $model_id (No Data)")
        push!(plots_list_ES, empty_p)
        push!(plots_list_EN, empty_p)
        continue
    end

    println("    -> Procesando datos del Modelo $model_id...")
    df_sim = CSV.read(sim_file, DataFrame)

    if !("h" in names(df_sim)) || !("productivity" in names(df_sim))
        println("❌ Error: Columnas faltantes en Modelo $model_id.")
        empty_p = plot(framestyle=:none, title="Model $model_id (Error)")
        push!(plots_list_ES, empty_p)
        push!(plots_list_EN, empty_p)
        continue
    end

    # Procesar Datos (Log + HP Filter)
    try
        h_cycle = hp_filter(log.(max.(df_sim.h, 1e-8)), 1600.0) .* 100
        p_cycle = hp_filter(log.(max.(df_sim.productivity, 1e-8)), 1600.0) .* 100

        p_es = scatter(
            h_cycle, p_cycle,
            title = "Modelo $model_id",
            xlabel = "Horas (%)", 
            ylabel = model_id == "1" ? "Productividad (%)" : "", # Solo etiqueta Y en el primero
            legend = false,
            color = :black,
            markersize = 2, markerstrokewidth = 0, alpha = 0.6,
            titlefontsize = 10, guidefontsize = 8
        )
        # Líneas de referencia (0,0)
        hline!(p_es, [0], color=:grey, linestyle=:dash, alpha=0.5)
        vline!(p_es, [0], color=:grey, linestyle=:dash, alpha=0.5)
        push!(plots_list_ES, p_es)

        p_en = scatter(
            h_cycle, p_cycle,
            title = "Model $model_id",
            xlabel = "Hours (%)", 
            ylabel = model_id == "1" ? "Productivity (%)" : "",
            legend = false,
            color = :black,
            markersize = 2, markerstrokewidth = 0, alpha = 0.6,
            titlefontsize = 10, guidefontsize = 8
        )
        hline!(p_en, [0], color=:grey, linestyle=:dash, alpha=0.5)
        vline!(p_en, [0], color=:grey, linestyle=:dash, alpha=0.5)
        push!(plots_list_EN, p_en)

    catch e
        println("❌ Error calculando filtro HP para Modelo $model_id: $e")
        push!(plots_list_ES, plot(framestyle=:none))
        push!(plots_list_EN, plot(framestyle=:none))
    end
end

# --- Combinar y Guardar ---
println(">>> Combinando gráficos...")

# Directorio de salida general (en results/p1)
output_dir = joinpath(project_root, "results", "p1")
mkpath(output_dir)

# 1. Versión Español
combined_plot_ES = plot(plots_list_ES..., layout=(1, 5), size=(1300, 350), margin=3Plots.mm)
path_ES = joinpath(output_dir, "scatter_sim_ES.pdf")
savefig(combined_plot_ES, path_ES)
println("    ✅ Guardado: $path_ES")

# 2. Versión Inglés
combined_plot_EN = plot(plots_list_EN..., layout=(1, 5), size=(1300, 350), margin=3Plots.mm)
path_EN = joinpath(output_dir, "scatter_sim_EN.pdf")
savefig(combined_plot_EN, path_EN)
println("    ✅ Guardado: $path_EN")

println(">>> Proceso finalizado.")