using CSV
using DataFrames
using Printf
using Statistics

include(joinpath(@__DIR__, "..", "..", "source", "plots.jl"))
using .Plotting

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
all_models = ["1", "2", "3", "4", "5"]
results_path = joinpath(project_root, "results", "p1") # Carpeta base de resultados

# --- 1. Generar Tabla Comparativa LaTeX (Ítem 6) ---
println(">>> Generando tabla comparativa para los modelos: ", join(all_models, ", "))

model_results = []

for model_id in all_models
    mc_file = joinpath(results_path, model_id, "item5_montecarlo_results.csv")
    if !isfile(mc_file)
        println("Advertencia: No se encontraron resultados para el modelo $model_id. Se omitirá.")
        continue
    end

    df_mc = CSV.read(mc_file, DataFrame)

    means_df = combine(df_mc, names(df_mc) .=> mean, renamecols=false)
    m_vals = Dict(n => @sprintf("%.2f", means_df[1, n]) for n in names(df_mc))
    push!(model_results, (id=model_id, stats=m_vals))
end

# Estructura de la Tabla LaTeX
latex_table = raw"""
\begin{table}[H]
    \centering
    \caption{Propiedades Cíclicas: Comparación de Modelos vs Datos EE.UU.}
    \label{tab:res_model_comparison}
     \resizebox{\textwidth}{!}{%
    \begin{tabular}{l c c c c c c c}
    \hline\hline
    & \textbf{\% S.D.} & \multicolumn{4}{c}{\textbf{Variable vs. Output}} & \multicolumn{2}{c}{\textbf{Hours vs. Productivity}} \\
    \cline{3-7}
    \textbf{Data/Model} & \textbf{Output} & \textbf{Cons} & \textbf{Inv} & \textbf{Hours} & \textbf{Prod} & \textbf{Rel SD} & \textbf{Corr} \\
    & $\sigma_y$ & $\sigma_c / \sigma_y$ & $\sigma_i / \sigma_y$ & $\sigma_h / \sigma_y$ & $\sigma_{y/h} / \sigma_y$ & $\sigma_h / \sigma_{y/h}$ & $\text{corr}(h, y/h)$ \\
    \hline
    \textbf{U.S. Data (Household)} & 1.92 & 0.45 & 2.78 & 0.78 & 0.57 & 1.37 & 0.07 \\
    \hline"""

for res in model_results
    m_vals = res.stats
    row_str = "\n    \\textbf{Modelo $(res.id)} & " *
              "$(m_vals["sigma_y"]) & $(m_vals["rel_sigma_c"]) & " *
              "$(m_vals["rel_sigma_i"]) & $(m_vals["rel_sigma_h"]) & " *
              "$(m_vals["rel_sigma_p"]) & $(m_vals["rel_sigma_h_p"]) & " *
              "$(m_vals["corr_h_p"]) \\\\"
    global latex_table *= row_str
end

latex_table *= raw"""
    \hline
    \end{tabular}%
    }
    \footnotesize{Nota: Resultados promedio de 10,000 simulaciones de 200 periodos.}
\end{table}
"""

tex_path = joinpath(results_path, "comparison_p1.tex")
open(tex_path, "w") do f
    write(f, latex_table)
end
println("Tabla LaTeX guardada en $tex_path")