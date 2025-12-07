using Dynare
using Printf
using DataFrames
using LinearAlgebra

# --- 1. Configuración del Entorno ---
project_root = joinpath(@__DIR__, "..", "..")
output_path  = joinpath(project_root, "results", "p3", "2_theoretical")
mkpath(output_path)

models_list = ["gali_current", "gali_forward"]

# --- 2. Definición de Pesos de Bienestar ---
# Parámetros calibración (Galí Cap 4)
sigma_c = 1.0
varphi  = 5.0
alpha   = 0.25
epsilon = 9.0
theta   = 0.75
beta    = 0.99

# Parámetros compuestos
Omega   = (1 - alpha) / (1 - alpha + alpha * epsilon)
lambda  = (1 - theta) * (1 - beta * theta) / theta * Omega

# Pesos de la función de pérdida: L = 0.5 * (Wy * var(y_gap) + Wpi * var(pi))
weight_y  = sigma_c + (varphi + alpha) / (1 - alpha)
weight_pi = epsilon / lambda

println(">>> Pesos de Bienestar Calculados:")
println("    Wy (Brecha): $(round(weight_y, digits=4))")
println("    Wpi (Inflación): $(round(weight_pi, digits=4))")

# --- 3. Extracción de Momentos ---
function get_moments(model_name, root)
    mod_path = joinpath(root, "modfiles", "p3", "$model_name.mod")
    if !isfile(mod_path) error("Modelo no encontrado: $mod_path") end

    println(" -> Resolviendo: $model_name...")
    
    context = eval(:(@dynare $mod_path))
    results = context.results.model_results[1]
    vars    = context.symboltable

    sigma_endo = results.linearrationalexpectations.endogenous_variance
    
    idx_y  = vars["y_gap"].orderintype
    idx_pi = vars["pi"].orderintype

    return sigma_endo[idx_y, idx_y], sigma_endo[idx_pi, idx_pi]
end

# --- 4. Generación de Tabla ---
df_results = DataFrame(Model=String[], SD_Y=Float64[], SD_Pi=Float64[], Loss=Float64[])

println("\n>>> Calculando Momentos Asintóticos...")
for m in models_list
    var_y, var_pi = get_moments(m, project_root)
    
    sd_y_pct  = sqrt(var_y) * 100
    sd_pi_pct = sqrt(var_pi) * 100

    loss = 0.5 * (weight_y * var_y + weight_pi * var_pi)
    
    push!(df_results, (m, sd_y_pct, sd_pi_pct, loss))
end

# --- 5. Exportación a LaTeX ---
println("\n>>> Generando Tabla 4.1...")
outfile = joinpath(output_path, "table_4_1_replication.tex")

latex_str = raw"""
\begin{table}[H]
    \centering
    \caption{Desviaciones Estándar Teóricas y Bienestar (Replicación Galí 2015)}
    \label{tab:gali_rep}
    \begin{tabular}{l c c c}
    \hline\hline
    \textbf{Regla de Política} & $\sigma(\tilde{y})$ (\%) & $\sigma(\pi)$ (\%) & Pérdida ($L$) \\
    \hline
"""

for row in eachrow(df_results)
    name_clean = replace(row.Model, "gali_" => "", "_" => "-")
    name_clean = titlecase(name_clean)
    
    global latex_str *= @sprintf("    %s & %.2f & %.2f & %.5f \\\\\n", 
                          name_clean, row.SD_Y, row.SD_Pi, row.Loss)
end

global latex_str *= raw"""    \hline\hline
    \end{tabular}
    \footnotesize{Nota: Pérdida en unidades de utilidad (no porcentuales).}
\end{table}
"""

open(outfile, "w") do f write(f, latex_str) end
println("✅ Tabla guardada en: $outfile")