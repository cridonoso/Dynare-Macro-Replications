using Dynare
using DataFrames
using CSV
using Statistics
using LinearAlgebra
using Optim
using Random

# --- 1. CONFIGURACIÓN ---
project_root = joinpath(@__DIR__, "..")
include(joinpath(project_root, "source", "utils.jl"))

data_path = joinpath(project_root, "data", "data_usa.csv")
df_data   = CSV.read(data_path, DataFrame)

# Momentos objetivo (4 momentos)
target_moments = [
    mean(skipmissing(df_data.dy_obs)),
    std(skipmissing(df_data.dy_obs)),
    std(skipmissing(df_data.h_obs)),
    cor(collect(skipmissing(df_data.dy_obs)), collect(skipmissing(df_data.h_obs)))
]

println(">>> Momentos Objetivo: ", round.(target_moments, digits=4))

mod_path = joinpath(project_root, "modfiles", "p2", "rbc_divlabor.mod")
if !isfile(mod_path)
    error("No se encontró el archivo: $mod_path")
end

# --- 2. OPTIMIZACIÓN ---
# Usamos la función robusta de utils.jl
objective_function = params -> rbc_gmm_loss_robust(params, mod_path, target_moments)

println(">>> Iniciando Estimación...")

# [theta, rho_g, sigma_lam, sigma_mu]
x0    = [0.33, 0.96, 0.01, 0.01]
lower = [0.01, 0.01, 0.0001, 0.0001]
upper = [0.99, 0.99, 0.10, 0.10] 

# Optimizador
res_optim = optimize(objective_function, lower, upper, x0, Fminbox(NelderMead()), 
                     Optim.Options(iterations=200, show_trace=true, time_limit=300.0))

params_final = Optim.minimizer(res_optim)

println("\n>>> Resultados Estimados:")
println("Theta: ", round(params_final[1], digits=4))
println("Rho_g: ", round(params_final[2], digits=4))

# --- 3. GENERACIÓN DE TABLAS (Vía Dynare stoch_simul) ---
println("\n>>> Generando simulación final...")

# BLINDAJE: Forzamos rho <= 0.98 para garantizar que la simulación no explote
final_theta = params_final[1]
final_rho   = min(params_final[2], 0.98) 
final_sig_l = params_final[3]
final_sig_m = params_final[4]

println(">>> Parámetros usados para simular: Rho_g = $final_rho")

# Escribir .mod temporal para la simulación final
final_mod_path = joinpath(dirname(mod_path), "rbc_final_run_sim.mod")
mod_content = read(mod_path, String)

# Inyectamos el bloque de simulación
# periods=113000 equivale a 1000 réplicas de 113 periodos
shocks_block = """
theta = $final_theta;
rho_g = $final_rho;
shocks;
    var eps_lambda; stderr $final_sig_l;
    var eps_mu;     stderr $final_sig_m;
end;
initval;
    lambda = 0.0045; g_bar = 186.0; n = 300; k_bar = 10000; y_bar = 1000; c_bar = 800; dy_obs = 0.45; h_obs = 0;
end;
steady;
check;
stoch_simul(order=1, irf=0, periods=113000, nograph, noprint);
"""

# Limpiamos comandos previos
content_clean = replace(mod_content, "stoch_simul(order=1, irf=0, periods=0, nograph, noprint);" => "")
content_clean = replace(content_clean, "stoch_simul(order=1, irf=0, nograph, noprint);" => "")

write(final_mod_path, content_clean * "\n" * shocks_block)

# Ejecutamos Dynare
context = eval(:(@dynare $final_mod_path))

# --- 4. PROCESAMIENTO DE RESULTADOS ---
# En Dynare.jl, las simulaciones están en context.results.model_results[1].simulations
if isempty(context.results.model_results[1].simulations)
    error("CRÍTICO: Dynare no generó simulaciones (Vector vacío). El modelo es inestable.")
end

sims = context.results.model_results[1].simulations[1] 
data_sim = sims.data # Matriz [Variables x Periodos]

# Recuperar índices de forma robusta (sin usar dr)
sym = context.symboltable
get_idx(name) = sym[name].orderintype

idx_y = get_idx("y_bar")
idx_c = get_idx("c_bar")
idx_n = get_idx("n")
idx_k = get_idx("k_bar")

vec_y = data_sim[idx_y, :]
vec_c = data_sim[idx_c, :]
vec_n = data_sim[idx_n, :]
vec_k = data_sim[idx_k, :]

# Procesar en bloques (Chunks) para replicar la estructura de 1000 simulaciones
T_chunk = 113
n_chunks = floor(Int, length(vec_y) / T_chunk)

println(">>> Procesando $n_chunks réplicas de $T_chunk periodos...")

means_y, means_n, means_cy, means_ky = Float64[], Float64[], Float64[], Float64[]
stds_y, stds_n, corrs_ny = Float64[], Float64[], Float64[]

# Filtro HP local
function simple_hp_filter(y, lambda=1600.0)
    n = length(y)
    if n < 3 return zeros(n) end
    D = zeros(n-2, n)
    for i in 1:n-2
        D[i, i] = 1.0; D[i, i+1] = -2.0; D[i, i+2] = 1.0
    end
    A = Matrix{Float64}(I, n, n) + lambda * (D' * D)
    return y - (A \ y)
end

for i in 1:n_chunks
    range = (i-1)*T_chunk + 1 : i*T_chunk
    
    # Datos del chunk
    y_s = vec_y[range]
    n_s = vec_n[range]
    c_s = vec_c[range]
    k_s = vec_k[range]
    
    # Tabla 2 (Medias)
    push!(means_y, mean(y_s))
    push!(means_n, mean(n_s))
    push!(means_cy, mean(c_s ./ y_s))
    push!(means_ky, mean(k_s ./ y_s))
    
    # Tabla 3 (Ciclos HP)
    # Protegemos contra log(0) o negativos si la simulación se volvió loca momentáneamente
    ly = log.(abs.(y_s) .+ 1e-6)
    ln = log.(abs.(n_s) .+ 1e-6)
    
    y_cyc = simple_hp_filter(ly, 1600.0)
    n_cyc = simple_hp_filter(ln, 1600.0)
    prod_cyc = y_cyc .- n_cyc 
    
    push!(stds_y, std(y_cyc))
    push!(stds_n, std(n_cyc))
    push!(corrs_ny, cor(n_cyc, prod_cyc))
end

# --- 5. GUARDAR CSVs ---
results_path = joinpath(project_root, "results", "p2")
mkpath(results_path)

df_t1 = DataFrame(Parameter = ["theta", "rho_g", "sigma_lambda", "sigma_mu"], 
                  Estimate = [final_theta, final_rho, final_sig_l, final_sig_m])
CSV.write(joinpath(results_path, "Table1_Parameters.csv"), df_t1)

df_t2 = DataFrame(
    Variable = ["y", "n", "c/y", "k/y"],
    Mean = [mean(means_y), mean(means_n), mean(means_cy), mean(means_ky)],
    Std_Sims = [std(means_y), std(means_n), std(means_cy), std(means_ky)]
)
CSV.write(joinpath(results_path, "Table2_FirstMoments.csv"), df_t2)

df_t3 = DataFrame(
    Stat = ["sigma_y", "sigma_n/sigma_y", "corr(n, y/n)"],
    Value = [mean(stds_y), mean(stds_n ./ stds_y), mean(corrs_ny)],
    Std_Sims = [std(stds_y), std(stds_n ./ stds_y), std(corrs_ny)]
)
CSV.write(joinpath(results_path, "Table3_SecondMoments.csv"), df_t3)

println("\n>>> ¡Éxito Total! Tablas guardadas en: $results_path")