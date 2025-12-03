# Nombre: p3_plot_histograms.jl
# Tarea:  Genera Gráficos Individuales, Combinados y Tabla de Resumen.

using CSV
using DataFrames
using Plots
using Statistics
using Printf

include(joinpath(@__DIR__, "..", "source", "plots.jl"))
using .Plotting

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
target_models = ["gali_current", "gali_forward"]

# Escenarios: ID, Nombre
scenarios_to_plot = [
    ("3", "1_Technology"),
    ("4", "2_Demand"),
    ("5", "3_Both")
]

println(">>> Iniciando generación de reportes P3...")

# 1. Cargar Datos y Generar Gráficos Individuales
all_data = Dict{String, Dict{String, Vector{Float64}}}()

for (scen_id, scen_key) in scenarios_to_plot
    results_path = joinpath(project_root, "results", "p3", scen_id)
    all_data[scen_id] = Dict{String, Vector{Float64}}()
    
    # Cargar datos de cada modelo
    for m in target_models
        csv_file = joinpath(results_path, "raw_loss_$(m).csv")
        if isfile(csv_file)
            df = CSV.read(csv_file, DataFrame)
            all_data[scen_id][m] = df.Loss
        end
    end
    
    # --- Generar Gráfico INDIVIDUAL en su carpeta respectiva ---
    if haskey(all_data[scen_id], "gali_current") && haskey(all_data[scen_id], "gali_forward")
        println("  Generando gráfico individual para: $scen_key ...")
        Plotting.plot_loss_comparison("ES", scen_key, 
            all_data[scen_id]["gali_current"], 
            all_data[scen_id]["gali_forward"], 
            results_path) # Se guarda en p3/3, p3/4 o p3/5
    end
end

# 2. Generar Carpeta p6 (Resumen)
summary_dir = joinpath(project_root, "results", "p3", "6")
mkpath(summary_dir)
println("\n>>> Generando reportes de resumen en: $summary_dir")

# 3. Generar Gráfico COMBINADO (1x3)
Plotting.plot_p3_combined_histograms("ES", all_data, scenarios_to_plot, summary_dir)

# 4. Generar Tabla Comparativa
println("  Generando tabla comparativa LaTeX...")
latex_str = raw"""
\begin{table}[H]
\centering
\caption{Comparación de Pérdida de Bienestar (Promedio de 10,000 Simulaciones)}
\label{tab:p3_summary_loss}
\begin{tabular}{l c c}
\hline\hline
\textbf{Escenario de Shock} & \textbf{Regla Contemporánea} & \textbf{Regla Forward-Looking} \\
\hline
"""

for (scen_id, scen_key) in scenarios_to_plot
    loss_current = mean(all_data[scen_id]["gali_current"])
    loss_forward = mean(all_data[scen_id]["gali_forward"])
    
    # Nombres bonitos
    pretty_name = replace(scen_key, "_" => " ")
    pretty_name = replace(pretty_name, "Technology" => "Tecnológico", "Demand" => "Demanda", "Both" => "Ambos")
    
    global latex_str *= @sprintf("    %s & %.4f & %.4f \\\\\n", pretty_name, loss_current, loss_forward)
end

latex_str *= raw"""
\hline\hline
\end{tabular}
\end{table}
"""

open(joinpath(summary_dir, "summary_table.tex"), "w") do f; write(f, latex_str); end
println("  ✅ Tabla guardada.")

println("\n>>> Proceso P3 Finalizado.")