using CSV
using DataFrames
using Statistics
using Plots

# Cargar módulos del proyecto
include(joinpath(@__DIR__,  "..", "..", "source", "plots.jl"))
using .Plotting
include(joinpath(@__DIR__, "..",  "..", "source", "simulation.jl"))

# --- 1. Configuración ---
project_root = joinpath(@__DIR__, "..","..")
output_dir   = joinpath(project_root, "results", "p1")
target_models = ["1", "2", "3", "4", "5"]

println(">>> Iniciando Scatter Plot combinado (1x5)...")

# Contenedores para gráficos
plots_list_ES = []
plots_list_EN = []

# --- 2. Procesamiento por Modelo ---
for model_id in target_models
    res_path = joinpath(project_root, "results", "p1", model_id)
    sim_file = joinpath(res_path, "item4_single_simulation.csv")

    # Manejo de datos faltantes (Gráfico vacío para mantener layout)
    if !isfile(sim_file)
        println("  ⚠️ Sin datos para Modelo $model_id. Usando placeholder.")
        empty_p = plot(framestyle=:none, title="Model $model_id (N/A)")
        push!(plots_list_ES, empty_p)
        push!(plots_list_EN, empty_p)
        continue
    end

    println("    -> Procesando Modelo $model_id...")
    df_sim = CSV.read(sim_file, DataFrame)

    # Validación de columnas
    if !("h" in names(df_sim)) || !("productivity" in names(df_sim))
        println(" Error: Columnas insuficientes en Modelo $model_id.")
        empty_p = plot(framestyle=:none, title="Model $model_id (Error)")
        push!(plots_list_ES, empty_p)
        push!(plots_list_EN, empty_p)
        continue
    end

    # Filtrado HP y Creación del Subplot
    try
        # Aplicar logaritmos y filtro HP (lambda=1600)
        h_cycle = hp_filter(log.(max.(df_sim.h, 1e-8)), 1600.0) .* 100
        p_cycle = hp_filter(log.(max.(df_sim.productivity, 1e-8)), 1600.0) .* 100

        # Crear Subplot Español
        p_es = scatter(
            h_cycle, p_cycle,
            title = "Modelo $model_id",
            xlabel = "Horas (%)", 
            ylabel = model_id == "1" ? "Productividad (%)" : "", # Eje Y solo en el 1ro
            legend = false, color = :black, markersize = 2, markerstrokewidth = 0, alpha = 0.6,
            titlefontsize = 10, guidefontsize = 8
        )
        hline!(p_es, [0], color=:grey, linestyle=:dash, alpha=0.5)
        vline!(p_es, [0], color=:grey, linestyle=:dash, alpha=0.5)
        push!(plots_list_ES, p_es)

        # Crear Subplot Inglés
        p_en = scatter(
            h_cycle, p_cycle,
            title = "Model $model_id",
            xlabel = "Hours (%)", 
            ylabel = model_id == "1" ? "Productivity (%)" : "",
            legend = false, color = :black, markersize = 2, markerstrokewidth = 0, alpha = 0.6,
            titlefontsize = 10, guidefontsize = 8
        )
        hline!(p_en, [0], color=:grey, linestyle=:dash, alpha=0.5)
        vline!(p_en, [0], color=:grey, linestyle=:dash, alpha=0.5)
        push!(plots_list_EN, p_en)

    catch e
        println("❌ Error en filtro HP (Modelo $model_id): $e")
        push!(plots_list_ES, plot(framestyle=:none))
        push!(plots_list_EN, plot(framestyle=:none))
    end
end

# --- 3. Ensamblaje y Guardado ---
println(">>> Combinando y guardando gráficos...")
mkpath(output_dir)

# Layout 1 fila, 5 columnas
layout_dims = (1, 5)
plot_size   = (1300, 350)

# Guardar versión Español
plot_ES = plot(plots_list_ES..., layout=layout_dims, size=plot_size, margin=3Plots.mm)
savefig(plot_ES, joinpath(output_dir, "scatter_sim_ES.pdf"))

# Guardar versión Inglés
plot_EN = plot(plots_list_EN..., layout=layout_dims, size=plot_size, margin=3Plots.mm)
savefig(plot_EN, joinpath(output_dir, "scatter_sim_EN.pdf"))

println("✅ Proceso finalizado.")