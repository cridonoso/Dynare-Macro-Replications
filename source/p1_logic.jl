module HansenReplication

using DataFrames
using Statistics
using LinearAlgebra
using StatsBase
using Printf
using Dynare
using SparseArrays

function hp_filter(y, lam=1600.0)
    n = length(y)
    D = spzeros(n-2, n)
    for i in 1:n-2 
        D[i,i]=1; D[i,i+1]=-2; D[i,i+2]=1 
    end
    F = sparse(I,n,n) + lam*(D'*D)
    return y - (F \ y)
end

# =========================================================================================
# 1. CÁLCULO DE ESTADÍSTICAS (Hansen Table 3)
# =========================================================================================
function calculate_hansen_stats(sim_lvl, vars_map)
    # Mapeo de variables requeridas (Ajustar según .mod)
    keys_req = ["y", "c", "invest", "h", "productivity"]
    
    cycles = Dict{String, Vector{Float64}}()

    # Log + HP Filter
    for v in keys_req
        if !haskey(vars_map, v)
            error("Variable $v no encontrada en el mapa de variables.")
        end
        idx = vars_map[v]
        # Protección contra log(<=0)
        raw_series = sim_lvl[:, idx]
        log_series = log.(max.(raw_series, 1e-8))
        cycles[v] = hp_filter(log_series, 1600.0)
    end

    # Desviaciones Estándar (en porcentaje)
    sd = Dict(k => std(cycles[k]) * 100 for k in keys_req)
    
    # Construcción de estadísticas específicas
    stats = [
        sd["y"],                        # Sigma Output
        sd["c"] / sd["y"],              # Rel Sigma Cons
        sd["invest"] / sd["y"],         # Rel Sigma Inv
        sd["h"] / sd["y"],              # Rel Sigma Hours
        sd["productivity"] / sd["y"],   # Rel Sigma Prod
        sd["h"] / sd["productivity"],   # Rel Hours/Prod
        cor(cycles["h"], cycles["productivity"]) # Corr(h, p)
    ]
    
    return stats
end

# =========================================================================================
# 2. MOTOR DE SIMULACIÓN MONTE CARLO
# =========================================================================================
function run_monte_carlo(sys, vars_map, T_periods, N_iterations; sim_func=nothing)
    if sim_func === nothing
        error("Debes pasar la función de simulación (simulate_time_series) como argumento.")
    end

    # Pre-allocating matrix for results
    # Cols: sigma_y, rel_c, rel_i, rel_h, rel_p, rel_h_p, corr_h_p
    mc_stats = zeros(N_iterations, 7)
    
    # Loop Monte Carlo
    # Tip: Threads.@threads puede usarse aquí si simulate_func es thread-safe
    for i in 1:N_iterations
        # 1. Simular trayectoria (Niveles)
        data_i = sim_func(sys, T_periods)
        
        # 2. Calcular estadísticas
        mc_stats[i, :] = calculate_hansen_stats(data_i, vars_map)
    end
    
    headers = ["sigma_y", "rel_sigma_c", "rel_sigma_i", "rel_sigma_h", 
               "rel_sigma_p", "rel_sigma_h_p", "corr_h_p"]
    
    return DataFrame(mc_stats, headers)
end

# =========================================================================================
# 3. GENERACIÓN DE TABLA LATEX
# =========================================================================================
function generate_comparison_table(models_data_dict)
    
    # Encabezado
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

    # Filas Dinámicas
    # Ordenar modelos por nombre/número
    sorted_keys = sort(collect(keys(models_data_dict)))
    
    for model_id in sorted_keys
        df = models_data_dict[model_id]
        
        # Calcular medias de las simulaciones
        means = combine(df, names(df) .=> mean, renamecols=false)
        
        # Formatear valores
        s_y   = @sprintf("%.2f", means[1, "sigma_y"])
        s_c   = @sprintf("%.2f", means[1, "rel_sigma_c"])
        s_i   = @sprintf("%.2f", means[1, "rel_sigma_i"])
        s_h   = @sprintf("%.2f", means[1, "rel_sigma_h"])
        s_p   = @sprintf("%.2f", means[1, "rel_sigma_p"])
        s_hp  = @sprintf("%.2f", means[1, "rel_sigma_h_p"])
        c_hp  = @sprintf("%.2f", means[1, "corr_h_p"])

        row_str = "\n        \\textbf{Modelo $model_id} & $s_y & $s_c & $s_i & $s_h & $s_p & $s_hp & $c_hp \\\\"
        latex_table *= row_str
    end

    # Cierre
    latex_table *= raw"""
        \hline
        \end{tabular}%
        }
        \footnotesize{Nota: Resultados promedio de simulaciones de Monte Carlo.}
    \end{table}
    """
    
    return latex_table
end

end # module