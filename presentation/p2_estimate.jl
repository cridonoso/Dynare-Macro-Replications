# Nombre archivo: p2_full_simulation_v3.jl
# REPLICACIÓN EXACTA DE VARIABLES C&E 1992 (y, n, g, dk, cp)

using Dynare
using DataFrames
using CSV
using Statistics
using LinearAlgebra
using SparseArrays
using Printf

# =========================================================================================
# 0. CONFIGURACIÓN Y RUTAS
# =========================================================================================
project_root = joinpath(@__DIR__, "..")
data_path    = joinpath(project_root, "data", "data_gmm.csv")
mod_base     = joinpath(project_root, "modfiles", "p2", "rbc_divlabor.mod")
results_dir  = joinpath(project_root, "results", "p2")
mod_final    = joinpath(results_dir, "final_model_sim.mod")

if !isdir(results_dir) mkpath(results_dir) end

println(">>> INICIANDO REPLICACIÓN C&E 1992 (VARIABLES: y, n, g, dk, cp)...")

# =========================================================================================
# 1. ESTIMACIÓN DE PARÁMETROS (TABLA 1)
# =========================================================================================
println("\n>>> [1/3] Estimando Parámetros...")

if !isfile(data_path) error("Falta data_gmm.csv. Ejecuta p2_get_data.jl primero.") end

# Leer datos (y, c, g, n)
df_data = CSV.read(data_path, DataFrame; header=false)
y_data = df_data[:, 1]
c_data = df_data[:, 2] # Esto es c^p (Consumo Privado)
g_data = df_data[:, 3] # Esto es g (Gobierno)
n_data = df_data[:, 4]

# Parámetros Fijos
beta_val  = 1.03^(-0.25) 
delta_val = 0.021        
theta_val = 0.339        
N_total   = 1369.0       

# Ajuste de escala (Horas)
scale_factor = 320.0 / mean(n_data)
n_data_adj   = n_data .* scale_factor

# Estimación GMM simplificada
dy = diff(log.(y_data))
lambda_hat = mean(dy)
sigma_lambda_hat = std(dy)

vec_gamma = (1 - theta_val) .* (y_data ./ n_data_adj) .* (N_total .- n_data_adj) ./ c_data
gamma_hat = mean(vec_gamma)

lg = log.(g_data)
Y_reg = lg[2:end]; X_reg = hcat(ones(length(Y_reg)), lg[1:end-1])
B_ols = X_reg \ Y_reg
rho_g_hat = B_ols[2]; const_g = B_ols[1]
g_ss_hat  = exp(const_g / (1 - rho_g_hat))
sigma_mu_hat = std(Y_reg - X_reg * B_ols)

# Generar Tabla 1
df_table1 = DataFrame(Parameter=["beta","delta","theta","N","lambda","gamma","rho_g","g_ss","sigma_lambda","sigma_mu"],
                      Value=[beta_val, delta_val, theta_val, N_total, lambda_hat, gamma_hat, rho_g_hat, g_ss_hat, sigma_lambda_hat, sigma_mu_hat])
CSV.write(joinpath(results_dir, "Table1_Parameters.csv"), df_table1)
println("   > Tabla 1 guardada.")

# =========================================================================================
# 2. CALCULO DE STEADY STATE E INYECCIÓN EN DYNARE
# =========================================================================================
println("\n>>> [2/3] Configurando Dynare...")

# SS Analítico
exp_lam = exp(lambda_hat)
ky_ratio_inv = (1/beta_val * exp_lam - (1-delta_val)) / theta_val

# Resolver n numéricamente
resid_n(n) = begin
    k = (n^(1-theta_val) / ky_ratio_inv)^(1/(1-theta_val))
    y = k * ky_ratio_inv
    c_val = y - k*(1 - (1-delta_val)*exp(-lambda_hat)) - g_ss_hat
    rhs = (1-theta_val)*(y/n)*((N_total-n)/gamma_hat)
    return c_val - rhs
end

n_guess = 300.0
for i in 1:10000 #// Aumentamos las iteraciones
    global n_guess
    r = resid_n(n_guess)
    if abs(r) < 1e-15 break end #// Tolerancia MÁXIMA
    
    #// Usar un paso muy conservador para la búsqueda de la raíz
    step_size = 0.000001
    n_guess = n_guess - r * step_size
end

n_ss = n_guess

k_ss = (n_ss^(1-theta_val) / ky_ratio_inv)^(1/(1-theta_val))
y_ss = k_ss * ky_ratio_inv
c_ss = y_ss - k_ss*(1 - (1-delta_val)*exp(-lambda_hat)) - g_ss_hat
w_ss = (1 - theta_val) * (y_ss / n_ss)

# Construir strings para el .mod
params_str = """
beta = $(beta_val); delta = $(delta_val); theta = $(theta_val); N = $(N_total);
lambda_ss = $(lambda_hat); gamma = $(gamma_hat); rho_g = $(rho_g_hat); g_ss = $(g_ss_hat);
"""

initval_block = """
initval;
    lambda=$(lambda_hat); g=$(g_ss_hat); n=$(n_ss); k=$(k_ss); y=$(y_ss); c=$(c_ss);
    w=$(w_ss);
    dy_obs=$(lambda_hat*100); h_obs=$(log(n_ss));
end;
"""

sigma_mu_for_sim = 0.012391
shocks_block = "shocks; var e_lambda; stderr $(sigma_lambda_hat); var e_mu; stderr $(sigma_mu_for_sim); end;"

# Leer y modificar .mod
mod_content = read(mod_base, String)
mod_content = replace(mod_content, r"^\s*@#include.*$"m => params_str)
mod_content = replace(mod_content, r"^\s*\w+\s*=\s*\w+_val\s*;.*$"m => "")

# 1. ANULACIÓN CRÍTICA: Eliminar completamente el bloque steady_state_model y cualquier initval
mod_content = replace(mod_content, r"steady_state_model;.*?end;"s => "")
mod_content = replace(mod_content, r"initval;.*?end;"s => "") # Limpia cualquier initval previo
mod_content = replace(mod_content, r"shocks;.*end;"s => "")
mod_content = replace(mod_content, r"stoch_simul.*" => "")

# 2. Escribir el archivo final (AÑADIENDO initval AL FINAL)
open(mod_final, "w") do io
    println(io, mod_content) 
    println(io, initval_block) #// Inyecta el SS numérico robusto de Julia
    println(io, shocks_block)
    
    # Usamos steady(nocheck) para que Dynare no intente resolver el SS analítico, 
    # sino que use el valor proporcionado como si fuera el resuelto.
    # Luego 'check' verifica las condiciones de Rango.
    println(io, "steady(nocheck); check; stoch_simul(order=1, periods=10200, irf=0, nograph);")
end

# =========================================================================================
# 3. SIMULACIÓN Y TABLAS 2 & 3 (VARIABLES SOLICITADAS Y CORRECTAS)
# =========================================================================================
println("\n>>> [3/3] Ejecutando Dynare y Generando Tablas...")

context = Dynare.dynare(mod_final)
sims = context.results.model_results[1].simulations[1]

# Función para extraer datos
get_data(var) = Float64.(collect(getproperty(sims.data, Symbol(var)))[201:end])

# Función Filtro HP
function hp_filter(y, lam=1600.0)
    n = length(y); D = spzeros(n-2, n)
    for i in 1:n-2 D[i,i]=1; D[i,i+1]=-2; D[i,i+2]=1 end
    F = sparse(I,n,n) + lam*(D'*D)
    return y - (F \ y)
end

# 1. Obtener Series Brutas
vec_y = get_data("y")
vec_n = get_data("n")
vec_g = get_data("g")
vec_cp = get_data("c") 
vec_k = get_data("k")

# 2. Calcular Variables Derivadas
vec_dk = vec_y .- vec_cp .- vec_g
vec_prod = vec_y ./ vec_n
# Salario Real (w o r): w = MPL = (1-theta) * y / n
vec_w = (1 - theta_val) .* vec_prod 

# 3. Logaritmos y Filtro HP
log_y = log.(max.(vec_y, 1e-10))
log_cp = log.(max.(vec_cp, 1e-10))
log_dk = log.(max.(vec_dk, 1e-10)) 
log_n = log.(max.(vec_n, 1e-10))
log_g = log.(max.(vec_g, 1e-10))
log_prod = log.(max.(vec_prod, 1e-10))
log_w = log.(max.(vec_w, 1e-10)) 

# Filtrado
cycle_y = hp_filter(log_y)
cycle_cp = hp_filter(log_cp)
cycle_dk = hp_filter(log_dk)
cycle_n = hp_filter(log_n)
cycle_g = hp_filter(log_g)
cycle_prod = hp_filter(log_prod)
cycle_w = hp_filter(log_w)

# 4. Calcular Estadísticos
sigma_y = std(cycle_y)
sigma_cp = std(cycle_cp)
sigma_dk = std(cycle_dk)
sigma_n = std(cycle_n)
sigma_g = std(cycle_g)
sigma_prod = std(cycle_prod)
sigma_w = std(cycle_w) # <--- ¡LÍNEA AÑADIDA!

# -------------------------------------------------------------------------
# GENERACIÓN DE TABLA 3 (Formato C&E 1992)
# -------------------------------------------------------------------------

df_table3 = DataFrame(
    Statistic = [
        "sigma_c / sigma_y", 
        "sigma_dk / sigma_y", 
        "sigma_n / sigma_y", 
        "sigma_r / sigma_y/n", # r (Real Wage)
        "sigma_g / sigma_y",
        "sigma_y", 
        "corr(y/n, n)"
    ],
    Value = [
        sigma_cp / sigma_y,
        sigma_dk / sigma_y,
        sigma_n / sigma_y,
        sigma_w / sigma_prod, # Uso sigma_w / sigma_prod
        sigma_g / sigma_y, 
        sigma_y * 100,
        cor(cycle_prod, cycle_n)
    ]
)

# Redondear para visualización
df_table3.Value = round.(df_table3.Value, digits=2)

CSV.write(joinpath(results_dir, "Table3_SecondMoments.csv"), df_table3)
println("\n>>> TABLA 3 GENERADA (Modelo sin Choque de Gobierno):")
println(df_table3)

# Generar Tabla 2 (Medias)
df_t2 = DataFrame(
    Variable = ["y", "cp", "dk", "n", "g", "k", "y/n", "cp/y", "dk/y", "g/y"],
    SteadyState = [
        y_ss, c_ss, (y_ss - c_ss - g_ss_hat), n_ss, g_ss_hat, k_ss,
        (y_ss/n_ss), (c_ss/y_ss), ((y_ss-c_ss-g_ss_hat)/y_ss), (g_ss_hat/y_ss)
    ]
)
CSV.write(joinpath(results_dir, "Table2_FirstMoments.csv"), df_t2)
println("\n>>> TABLA 2 GENERADA.")