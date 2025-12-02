# Nombre: p3_gali_table.jl
# Tarea:  Replica la Tabla 4.1 de Galí (2015) usando momentos teóricos exactos.
#         Compara Regla Contemporánea vs. Forward-Looking.

using Dynare
using Printf
using DataFrames
using LinearAlgebra

# --- Configuración ---
project_root = joinpath(@__DIR__, "..")
output_path = joinpath(project_root, "results", "p3", "2")
mkpath(output_path)

# Modelos a comparar
models = ["gali_current", "gali_forward"]

# Parámetros de Bienestar (Deben coincidir con tu calibración en .mod)
# Galí (2015) Cap 4: L = 0.5 * [ (sigma + (varphi+alpha)/(1-alpha))*var(y_gap) + (epsilon/lambda)*var(pi) ]
# Reconstruimos los pesos basados en los parámetros profundos:
siggma = 1.0
varphi = 5.0
alppha = 0.25
epsilon = 9.0
theta = 0.75
beta = 0.99

# Cálculo de paramétros compuestos para la función de pérdida
Omega = (1 - alppha) / (1 - alppha + alppha * epsilon)
lambda_val = (1 - theta) * (1 - beta * theta) / theta * Omega

# Pesos teóricos de la función de pérdida
weight_y = siggma + (varphi + alppha) / (1 - alppha)
weight_pi = epsilon / lambda_val

println(">>> Pesos de Bienestar Calculados:")
println("    Wy (Brecha): $weight_y")
println("    Wpi (Inflación): $weight_pi")

# --- Función de Extracción ---
function get_theoretical_moments(model_name)
    mod_file = joinpath(project_root, "modfiles", "p3", "$model_name.mod")
    
    if !isfile(mod_file)
        error("No se encontró el archivo: $mod_file")
    end

    println("\n>>> Ejecutando Dynare para: $model_name ...")
    # Ejecutamos Dynare en el contexto actual
    context = eval(:(@dynare $mod_file))
    
    # Extraer resultados
    results = context.results.model_results[1]
    
    # Matriz de Covarianza Teórica (Variables x Variables)
    # Nota: Dynare guarda esto en results.linearrationalexpectations.endogenous_variance
    sigma_endo = results.linearrationalexpectations.endogenous_variance
    
    # Mapeo de variables a índices
    vars = context.symboltable
    
    # Buscamos índices de las variables de interés
    # Nota: keys(vars) puede no estar ordenado, usamos el campo orderintype u order_var
    # La forma segura en Dynare.jl es buscar por nombre:
    idx_y = vars["y_gap"].orderintype
    idx_pi = vars["pi"].orderintype
    
    # Extraer Varianzas (Los elementos diagonales)
    var_y_gap = sigma_endo[idx_y, idx_y]
    var_pi    = sigma_endo[idx_pi, idx_pi]
    
    return var_y_gap, var_pi
end

# --- Loop Principal ---
results_db = DataFrame(
    Model = String[], 
    SD_Y_Gap = Float64[], 
    SD_Pi = Float64[], 
    Loss = Float64[]
)

for m in models
    try
        vy, vpi = get_theoretical_moments(m)
        
        # Transformaciones:
        # 1. De Varianza a Desviación Estándar (sqrt)
        # 2. De decimal a Porcentaje ( * 100 )
        sd_y_pct = sqrt(vy) * 100
        sd_pi_pct = sqrt(vpi) * 100
        
        # Cálculo de Pérdida de Bienestar
        # L = 0.5 * (Wy * var(y) + Wpi * var(pi))
        # Importante: Galí suele reportar la pérdida multiplicada por 100 para legibilidad,
        # o basada en varianzas porcentuales. Usaremos varianzas porcentuales ( * 100^2 )
        loss = 0.5 * (weight_y * (vy * 100^2) + weight_pi * (vpi * 100^2))
        
        push!(results_db, (m, sd_y_pct, sd_pi_pct, loss))
    catch e
        println("❌ Error procesando $m: $e")
    end
end

# --- Mostrar Resultados ---
println("\n" * "="^60)
println("REPLICACIÓN TABLA 4.1 (GALÍ 2015)")
println("="^60)
println(results_db)
println("="^60)

# --- Generar LaTeX ---
table_rows = ""
for row in eachrow(results_db)
    clean_name = replace(row.Model, "gali_" => "", "_" => " ")
    clean_name = titlecase(clean_name)
    
    global table_rows *= @sprintf(
        "    %s & %.2f & %.2f & %.4f \\\\\n", 
        clean_name, row.SD_Y_Gap, row.SD_Pi, row.Loss
    )
end

latex_str = raw"""
\begin{table}[H]
    \centering
    \caption{Desviaciones Estándar Teóricas y Bienestar (Simulación)}
    \label{tab:gali_replication}
    \begin{tabular}{l c c c}
    \hline\hline
    \textbf{Regla de Política} & $\sigma(\tilde{y})$ (\%) & $\sigma(\pi)$ (\%) & Pérdida ($L$) \\
    \hline
""" * table_rows * raw"""
    \hline\hline
    \end{tabular}
    \footnotesize{Nota: Resultados basados en momentos teóricos asintóticos. Shocks calibrados al 1\%.}
\end{table}
"""

outfile = joinpath(output_path, "table_4_1_replication.tex")
open(outfile, "w") do f
    write(f, latex_str)
end

println(">>> Tabla LaTeX guardada en: $outfile")