using DataFrames
using CSV
using Base.Filesystem

# Incluir y usar el nuevo módulo de replicación
include(joinpath(@__DIR__, "..", "..", "source", "p2", "utils.jl"))
using .ReplicationTools

# =========================================================================================
# 0. CONFIGURACIÓN
# =========================================================================================
project_root = joinpath(@__DIR__, "..", "..")
data_path    = joinpath(project_root, "data", "data_gmm.csv")
mod_base     = joinpath(project_root, "modfiles", "p2", "rbc_divlabor.mod")
results_dir  = joinpath(project_root, "results", "p2")
if !isdir(results_dir) mkpath(results_dir) end

println(">>> INICIANDO GENERACIÓN DE TABLAS (C&E 1992 - Alpha=1)...")

# =========================================================================================
# 1. CARGA DE DATOS Y PARÁMETROS FIJOS
# =========================================================================================
if !isfile(data_path) error("Falta data_gmm.csv. Ejecute 0_get_data.jl primero.") end

# Carga de datos sin encabezado (y, c, g, n)
df_data = CSV.read(data_path, DataFrame; header=false)
y_raw = df_data[:, 1]; c_raw = df_data[:, 2]; g_raw = df_data[:, 3]; n_raw = df_data[:, 4]

# 1. Calcular factor para que g_bar coincida con Lawrence (186)
#    Lawrence g_bar = 186. Nuestro g_raw promedio es ~0.0094.
TARGET_G = 186.0
scale_money = TARGET_G / mean(g_raw) 

println(">>> Factor de Escala Monetario calculado: $(scale_money)")
y_data = y_raw .* scale_money
c_data = c_raw .* scale_money
g_data = g_raw .* scale_money
n_data = n_raw 

# Parámetros Fijos
params_fix = (
    beta_val  = 1.03^(-0.25), 
    delta_val = 0.021,        
    theta_val = 0.339,        
    N_total   = 1369.0        
)

# =========================================================================================
# 2. ESTIMACIÓN DE PARÁMETROS (TABLA 1)
# =========================================================================================
println(">>> [1/4] Estimando Parámetros...")
params_est = ReplicationTools.estimate_parameters(
    y_data, c_data, g_data, n_data, 
    params_fix.N_total, params_fix.theta_val, params_fix.beta_val
)

# Unir parámetros fijos y estimados para uso posterior
params_full = merge(params_est, params_fix)

# =========================================================================================
# 3. CÁLCULO DEL ESTADO ESTACIONARIO (TABLA 2)
# =========================================================================================
println(">>> [2/4] Calculando Estado Estacionario...")
ss_vals = ReplicationTools.solve_steady_state(params_full, delta_val=params_fix.delta_val)

# =========================================================================================
# 4. SIMULACIÓN Y MOMENTOS (TABLA 3)
# =========================================================================================
println(">>> [3/4] Simulando Modelo (Without Govt)...")
sim_moments = ReplicationTools.run_simulation_and_moments(
    mod_base, params_full, ss_vals, results_dir
)

# =========================================================================================
# 5. GENERACIÓN Y GUARDADO DE CÓDIGO LATEX
# =========================================================================================
println(">>> [4/4] Generando Tablas LaTeX...")
latex_output = ReplicationTools.generate_latex_tables(params_full, ss_vals, sim_moments)

# Guardar en archivo
output_file = joinpath(results_dir, "tablas_finales.tex")
open(output_file, "w") do io
    println(io, latex_output)
end
println("\n>>> Archivo guardado en: $(output_file)")