# Nombre archivo: p2_gen_tables.jl
# Generación de Tablas LaTeX para replicación C&E 1992 (Divisible Labor)

using Dynare
using DataFrames
using CSV
using Statistics
using LinearAlgebra
using SparseArrays
using Printf

# =========================================================================================
# 0. CONFIGURACIÓN
# =========================================================================================
project_root = joinpath(@__DIR__, "..")
data_path    = joinpath(project_root, "data", "data_gmm.csv")
mod_base     = joinpath(project_root, "modfiles", "p2", "rbc_divlabor.mod")
results_dir  = joinpath(project_root, "results", "p2")
if !isdir(results_dir) mkpath(results_dir) end

println(">>> INICIANDO GENERACIÓN DE TABLAS (C&E 1992 - Alpha=1)...")

# =========================================================================================
# 1. ESTIMACIÓN DE PARÁMETROS (TABLA 1)
# =========================================================================================
println(">>> [1/3] Estimando Parámetros...")

if !isfile(data_path) error("Falta data_gmm.csv") end
df_data = CSV.read(data_path, DataFrame; header=false)
y_data = df_data[:, 1]; c_data = df_data[:, 2]; g_data = df_data[:, 3]; n_data = df_data[:, 4]

# Parámetros Fijos
beta_val  = 1.03^(-0.25)
delta_val = 0.021
theta_val = 0.339
N_total   = 1369.0

# Ajuste de escala (Horas)
scale_factor = 320.0 / mean(n_data)
n_data_adj   = n_data .* scale_factor

# Estimación GMM / Momentos
dy = diff(log.(y_data))
lambda_hat = mean(dy)
sigma_lambda_hat = std(dy)

vec_gamma = (1 - theta_val) .* (y_data ./ n_data_adj) .* (N_total .- n_data_adj) ./ c_data
gamma_hat = mean(vec_gamma)

lg = log.(g_data)
Y_reg = lg[2:end]; X_reg = hcat(ones(length(Y_reg)), lg[1:end-1])
B_ols = X_reg \ Y_reg
rho_g_hat = B_ols[2]; const_g = B_ols[1]
g_ss_hat  = exp(const_g / (1 - rho_g_hat)) # Nivel (o log-nivel dependiendo de tus datos)
sigma_mu_hat = std(Y_reg - X_reg * B_ols)

# =========================================================================================
# 2. ESTADO ESTACIONARIO (TABLA 2)
# =========================================================================================
println(">>> [2/3] Calculando Estado Estacionario...")

exp_lam = exp(lambda_hat)
ky_ratio_inv = (1/beta_val * exp_lam - (1-delta_val)) / theta_val

resid_n(n) = begin
    k = (n^(1-theta_val) / ky_ratio_inv)^(1/(1-theta_val))
    y = k * ky_ratio_inv
    c_val = y - k*(1 - (1-delta_val)*exp(-lambda_hat)) - g_ss_hat
    rhs = (1-theta_val)*(y/n)*((N_total-n)/gamma_hat)
    return c_val - rhs
end

n_guess = 300.0
for i in 1:10000 
    global n_guess
    r = resid_n(n_guess)
    if abs(r) < 1e-15 break end 
    n_guess = n_guess - r * 0.000001
end
n_ss = n_guess
k_ss = (n_ss^(1-theta_val) / ky_ratio_inv)^(1/(1-theta_val))
y_ss = k_ss * ky_ratio_inv
c_ss = y_ss - k_ss*(1 - (1-delta_val)*exp(-lambda_hat)) - g_ss_hat

# Ratios para Tabla 2
cy_ratio = c_ss / y_ss
gy_ratio = g_ss_hat / y_ss
dky_ratio = (y_ss - c_ss - g_ss_hat) / y_ss # Inversion/Y
ky_ratio = k_ss / y_ss

# =========================================================================================
# 3. SIMULACIÓN (TABLA 3) - CASO WITHOUT GOVERNMENT (Alpha=1, sigma_mu ~ 0)
# =========================================================================================
println(">>> [3/3] Simulando Modelo (Without Govt)...")

# Filtro HP
function hp_filter(y, lam=1600.0)
    n = length(y); D = spzeros(n-2, n)
    for i in 1:n-2 D[i,i]=1; D[i,i+1]=-2; D[i,i+2]=1 end
    F = sparse(I,n,n) + lam*(D'*D)
    return y - (F \ y)
end

mod_scen = joinpath(results_dir, "model_gen_tables.mod")

params_str = """
beta = $(beta_val); delta = $(delta_val); theta = $(theta_val); N = $(N_total);
lambda_ss = $(lambda_hat); gamma = $(gamma_hat); rho_g = $(rho_g_hat); g_ss = $(g_ss_hat);
"""

initval_block = """
initval;
    lambda=$(lambda_hat); g=$(g_ss_hat); n=$(n_ss); k=$(k_ss); y=$(y_ss); c=$(c_ss);
    dy_obs=$(lambda_hat*100); h_obs=$(log(n_ss));
end;
"""

# IMPORTANTE: sigma_mu muy pequeño pero NO cero para evitar PosDefException
sigma_mu_sim = 1e-8 
shocks_block = "shocks; var e_lambda; stderr $(sigma_lambda_hat); var e_mu; stderr $(sigma_mu_sim); end;"

mod_content = read(mod_base, String)
mod_content = replace(mod_content, r"^\s*@#include.*$"m => params_str)
mod_content = replace(mod_content, r"^\s*\w+\s*=\s*\w+_val\s*;.*$"m => "")
mod_content = replace(mod_content, r"steady_state_model;.*?end;"s => "")
mod_content = replace(mod_content, r"initval;.*?end;"s => "") 
mod_content = replace(mod_content, r"shocks;.*end;"s => "")
mod_content = replace(mod_content, r"stoch_simul.*" => "")

open(mod_scen, "w") do io
    println(io, mod_content) 
    println(io, initval_block) 
    println(io, shocks_block)
    println(io, "steady(nocheck); check; stoch_simul(order=1, periods=10200, irf=0, nograph);")
end

context = Dynare.dynare(mod_scen)
sims = context.results.model_results[1].simulations[1]
get_d(var) = Float64.(collect(getproperty(sims.data, Symbol(var)))[201:end])

vec_y = get_d("y"); vec_c = get_d("c"); vec_g = get_d("g"); vec_n = get_d("n")
vec_dk = vec_y .- vec_c .- vec_g
vec_prod = vec_y ./ vec_n
# Salario real (PMgL)
vec_w = (1 - theta_val) .* vec_prod

cycle_y = hp_filter(log.(max.(vec_y, 1e-10)))
cycle_c = hp_filter(log.(max.(vec_c, 1e-10)))
cycle_dk = hp_filter(log.(max.(vec_dk, 1e-10)))
cycle_n = hp_filter(log.(max.(vec_n, 1e-10)))
cycle_g = hp_filter(log.(max.(vec_g, 1e-10)))
cycle_prod = hp_filter(log.(max.(vec_prod, 1e-10)))
cycle_w = hp_filter(log.(max.(vec_w, 1e-10)))

sig_y = std(cycle_y)
sig_c_y = std(cycle_c)/sig_y
sig_dk_y = std(cycle_dk)/sig_y
sig_n_y = std(cycle_n)/sig_y
sig_g_y = std(cycle_g)/sig_y
sig_w_prod = std(cycle_w)/std(cycle_prod) # Aproximación para sigma_r / sigma_y/n
corr_prod_n = cor(cycle_prod, cycle_n)

# =========================================================================================
# 4. GENERACIÓN DE CÓDIGO LATEX
# =========================================================================================

latex_output = """
\\begin{table}[H]
    \\centering
    \\caption{Estimaciones de Parámetros del Modelo: Comparación de Resultados Propios con el Modelo Divisible Labor without Government (\$\\alpha = 1\$)}
    \\label{tab:comparacion_parametros_update}
    \\begin{tabular}{lcc}
    \\toprule
    \\textbf{Parámetro} & \\textbf{Este Trabajo} & \\textbf{Lawrence et.al., 1992} \\\\
    \\midrule
    \$\\beta\$ & $(@sprintf("%.4f", beta_val)) & 0.9926 \\\\
    \$\\delta\$ & $(@sprintf("%.4f", delta_val)) & 0.0210 \\\\
    \$\\theta\$ & $(@sprintf("%.4f", theta_val)) & 0.3390 \\\\
    \$N\$ & $(@sprintf("%d", Int(N_total))) & 1369 \\\\
    \$\\gamma\$ & $(@sprintf("%.4f", gamma_hat)) & 2.9900 \\\\
    \$\\lambda\$ & $(@sprintf("%.4f", lambda_hat)) & 0.0040 \\\\
    \$\\sigma_{\\varepsilon}\$ & $(@sprintf("%.4f", sigma_lambda_hat)) & 0.0180 \\\\
    \$\\bar{g}\$ & $(@sprintf("%.4f", g_ss_hat)) & 186.0000 \\\\
    \$\\rho\$ & $(@sprintf("%.4f", rho_g_hat)) & 0.9600 \\\\
    \$\\sigma_{\\mu}\$ & $(@sprintf("%.4f", sigma_mu_hat)) & 0.0200 \\\\
    \\bottomrule
    \\end{tabular}
\\end{table}

\\begin{table}[H]
    \\centering
    \\caption{Propiedades de Primer Momento: Comparación de Resultados Propios con el Modelo Divisible Labor without Government (\$\\alpha = 1\$)}
    \\label{tab:comparacion_primer_momentos_update}
    \\begin{tabular}{lcc}
    \\toprule
    \\textbf{Variable} & \\textbf{Este Trabajo (SS)} & \\textbf{Lawrence et.al., 1992} \\\\
    \\midrule
    \$c_t / y_t\$ & $(@sprintf("%.4f", cy_ratio)) & 0.5600 \\\\
    \$g_t / y_t\$ & $(@sprintf("%.4f", gy_ratio)) & 0.1770 \\\\
    \$dk_t / y_t\$ & $(@sprintf("%.4f", dky_ratio)) & 0.2600 \\\\
    \$k_{t+1} / y_t\$ & $(@sprintf("%.2f", ky_ratio)) & 10.54 \\\\
    \$n_t\$ & $(@sprintf("%.2f", n_ss)) & 315.60 \\\\
    \\bottomrule
    \\end{tabular}
\\end{table}

\\begin{table}[H]
    \\centering
    \\caption{Momentos de Segundo Orden: Comparación de Resultados Propios con el Modelo Divisible Labor without Government (\$\\alpha = 1\$)}
    \\label{tab:comparacion_momentos_corregida_update}
    \\begin{tabular}{lcc}
    \\toprule
    \\textbf{Estadístico} & \\textbf{Este Trabajo} & \\textbf{Lawrence et.al., 1992} \\\\
    \\midrule
    \$\\sigma_c / \\sigma_y\$ & $(@sprintf("%.4f", sig_c_y)) & 0.5700 \\\\
    \$\\sigma_{dk} / \\sigma_y\$ & $(@sprintf("%.4f", sig_dk_y)) & 2.3300 \\\\
    \$\\sigma_n / \\sigma_y\$ & $(@sprintf("%.4f", sig_n_y)) & 0.3600 \\\\
    \$\\sigma_{r} / \\sigma_{y/n}\$ & $(@sprintf("%.4f", sig_w_prod)) & 0.5400 \\\\
    \$\\sigma_g / \\sigma_y\$ & $(@sprintf("%.4f", sig_g_y)) & 1.7600 \\\\
    \$\\sigma_y\$ & $(@sprintf("%.4f", sig_y * 100)) & 0.0200 \\\\
    \\text{corr}(y/n, n) & $(@sprintf("%.4f", corr_prod_n)) & 0.9500 \\\\
    \\bottomrule
    \\end{tabular}
\\end{table}
"""

println("\n" * "="^80)
println("CÓDIGO LATEX FINAL PARA COPIAR:")
println("="^80)
println(latex_output)

# Guardar en archivo
open(joinpath(results_dir, "tablas_finales.tex"), "w") do io
    println(io, latex_output)
end
println("\n>>> Archivo guardado en: $(joinpath(results_dir, "tablas_finales.tex"))")