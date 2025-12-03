# Script: 2_gen_reports.jl
# Propósito: Genera gráficos y tabla resumen.

using CSV
using DataFrames
using Plots
using Statistics
using Printf

include(joinpath(@__DIR__, "..", "..", "source", "plots.jl"))
using .Plotting

# --- 1. Configuración ---
project_root = joinpath(@__DIR__, "..", "..")
models_list  = ["gali_current", "gali_forward"]

# Claves coinciden con las carpetas generadas por script 1
scenarios = [
    ("3", "1_Technology"),
    ("4", "2_Demand"),
    ("5", "3_Both")
]

summary_dir = joinpath(project_root, "results", "p3", "6_summary")
mkpath(summary_dir)

println(">>> Iniciando reportes...")

data_store = Dict{String, Dict{String, Vector{Float64}}}()

# --- 2. Carga y Gráficos Individuales ---
for (sid, sname) in scenarios
    res_path = joinpath(project_root, "results", "p3", sid)
    data_store[sid] = Dict()
    
    println(" -> Cargando: $sname")
    
    for m in models_list
        file = joinpath(res_path, "loss_dist_$m.csv")
        if isfile(file)
            df = CSV.read(file, DataFrame)
            data_store[sid][m] = df.Loss
        end
    end
    
    # Graficar
    if length(data_store[sid]) == 2
        Plotting.plot_loss_comparison(
            "ES", sname, 
            data_store[sid]["gali_current"], 
            data_store[sid]["gali_forward"], 
            res_path
        )
    end
end

# --- 3. Panel Combinado ---
println(" -> Generando panel combinado...")
Plotting.plot_p3_combined_histograms("ES", data_store, scenarios, summary_dir)

# --- 4. Tabla Resumen ---
println(" -> Generando tabla resumen...")

latex_str = raw"""
\begin{table}[H]
    \centering
    \caption{Pérdida de Bienestar Promedio (Simulación Monte Carlo)}
    \label{tab:p3_sim_summary}
    \begin{tabular}{l c c}
    \hline\hline
    \textbf{Escenario} & \textbf{Regla Contemporánea} & \textbf{Regla Forward-Looking} \\
    \hline
"""

for (sid, sname) in scenarios
    if haskey(data_store, sid) && !isempty(data_store[sid])
        l_curr = mean(data_store[sid]["gali_current"])
        l_fwd  = mean(data_store[sid]["gali_forward"])
        
        name_pretty = replace(sname, "1_Technology" => "Choque Tecnológico", 
                                     "2_Demand" => "Choque de Demanda", 
                                     "3_Both" => "Modelo Completo")
        
        global latex_str *= @sprintf("    %s & %.5f & %.5f \\\\\n", name_pretty, l_curr, l_fwd)
    end
end

global latex_str *= raw"""    \hline\hline
    \end{tabular}
    \footnotesize{Nota: Promedio de 10,000 simulaciones. Unidades de utilidad.}
\end{table}
"""

open(joinpath(summary_dir, "summary_loss_table.tex"), "w") do f write(f, latex_str) end
println("✅ Reportes finalizados en: $summary_dir")