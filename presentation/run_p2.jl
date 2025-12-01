using DataFrames, CSV, Statistics, Dynare, Printf, Dates

# ==========================================
# 1. CARGA Y PROCESAMIENTO DE DATOS
# ==========================================
project_root = joinpath(@__DIR__, "..")
data_path    = joinpath(project_root, "data", "data_usa.csv")
mod_dir = joinpath(project_root, "modfiles", "p2")
mkpath(mod_dir) 

# Importamos hp_filter desde source/utils.jl
include(joinpath(project_root, "source", "utils.jl"))

if !isfile(data_path)
    error("No se encontró el archivo de datos en: $data_path")
end

df = CSV.read(data_path, DataFrame)
println(">>> Datos cargados exitosamente.")

# ==========================================
# 2. CALIBRACIÓN (REPLICA TABLA 1)
# ==========================================
# Convertimos logs a niveles para obtener ratios de estado estacionario
Y_raw = exp.(df.y_lvl)
C_raw = exp.(df.c_lvl)
I_raw = exp.(df.i_lvl)
G_raw = exp.(df.g_lvl)

# Promedios
ratio_i_y = mean(I_raw ./ Y_raw)
ratio_c_y = mean(C_raw ./ Y_raw)
n_ss      = mean(df.H_raw)  # Horas promedio (Target)
g_bar_val = mean(G_raw)     # Gasto gobierno medio

# Parámetros Estructurales (Christiano & Eichenbaum 1992)
beta_val  = 1.03^(-0.25)
delta_val = 0.021
# Ecuación Euler SS: 1 = beta * (1 - delta + theta * (Y/K))
# Inversión SS: I/K = exp(lambda) - (1-delta) approx delta
# Combinando:
theta_val = (1/beta_val - 1 + delta_val) * (ratio_i_y / delta_val)

N_total   = 1369.0 # Dotación total de tiempo trimestral
# Calibración de Gamma para asegurar que el n del modelo sea n_ss
# FOC: gamma/(N-n) = (1/c) * (1-theta)*y/n
gamma_val = (1 - theta_val) * (1/ratio_c_y) * (N_total - n_ss)/n_ss

# Parámetros Exógenos
lambda_val = 0.004
rho_g_val  = 0.96
sigma_z    = 0.018
sigma_g    = 0.020

println("\n--- Calibración ---")
println("Theta (Capital): ", round(theta_val, digits=4))
println("Gamma (Ocio):    ", round(gamma_val, digits=4))
println("N_ss (Target):   ", round(n_ss, digits=2))

# ==========================================
# 3. DEFINICIÓN DEL MODELO DYNARE (PLANTILLA)
# ==========================================
# Definimos el modelo como string dentro de Julia para evitar errores de lectura
rbc_template = """
var y c k i n g A;
varexo e_a e_g;

parameters beta delta theta gamma N_bar rho_g g_bar lambda;

// Asignación de valores calibrados desde Julia
beta  = CALIB_BETA;
delta = CALIB_DELTA;
theta = CALIB_THETA;
gamma = CALIB_GAMMA;
N_bar = CALIB_NBAR;
rho_g = CALIB_RHOG;
g_bar = CALIB_GBAR;
lambda = CALIB_LAMBDA;

model;
    // 1. Producción (y = Y/Z)
    y = k(-1)^theta * (n)^(1-theta);
    
    // 2. Acumulación Capital (ajustada por crecimiento tec. exp(lambda))
    k * exp(lambda + e_a) = (1-delta)*k(-1) + i;
    
    // 3. Recursos
    y = c + i + g;
    
    // 4. Euler
    1/c = beta * (1/c(+1)) * exp(-(lambda + e_a(+1))) * (theta * y(+1)/k + 1 - delta);
    
    // 5. Oferta Laboral (Divisible)
    gamma / (N_bar - n) = (1/c) * (1-theta) * y/n;
    
    // 6. Choque Tecnología
    A = e_a;
    
    // 7. Gasto Gobierno
    log(g) = (1-rho_g)*log(g_bar) + rho_g*log(g(-1)) + e_g; 
end;

steady_state_model;
    A = 0;
    g = g_bar;

    // --- Solución Analítica del Estado Estacionario ---
    // Usamos variables locales (sin declarar var) para pasos intermedios
    
    // 1. Retorno requerido por Euler
    R_eff = 1 / (beta * exp(-lambda));
    
    // 2. Ratio Capital/Producto
    yk_ratio = theta / (R_eff - (1-delta));
    
    // 3. Ratio Inversión/Producto (i/k * k/y)
    ik_ratio = exp(lambda) - (1-delta);
    iy_ratio = ik_ratio * yk_ratio;
    
    // 4. Productividad Media (y/n) depende solo de k/y
    y_per_n = yk_ratio^(theta/(1-theta));
    
    // 5. Despeje de Horas (n) usando FOC Trabajo y Recursos
    // Algebra: gamma*(1 - iy_ratio - g/y)*n = (N_bar - n)*(1-theta)
    // n * [gamma*(1 - iy_ratio - g/y) + (1-theta)] = N_bar * (1-theta)
    gy_ratio = g_bar / (y_per_n * n); // g/y = g_bar / (y_per_n * n)
    cy_ratio = 1 - iy_ratio - gy_ratio;
    n = ( (1-theta)*N_bar ) / ( gamma*cy_ratio + (1-theta) );
    
    // 6. Recuperar niveles
    y = y_per_n * n;
    k = y * yk_ratio;
    i = y * iy_ratio;
    c = y - i - g;
end;

shocks;
    var e_a; stderr CALIB_SIGMA_Z;
    var e_g; stderr CALIB_SIGMA_G;
end;

steady;
check;
stoch_simul(order=1, periods=200, irf=0);
"""

# ==========================================
# 4. EJECUCIÓN DYNARE (CORREGIDO)
# ==========================================

# --- 4.1. Sustituir valores y crear el archivo .mod ---
model_string = replace(rbc_template,
    "CALIB_BETA"      => string(beta_val),
    "CALIB_DELTA"     => string(delta_val),
    "CALIB_THETA"     => string(theta_val),
    "CALIB_GAMMA"     => string(gamma_val),
    "CALIB_NBAR"      => string(N_total),
    "CALIB_RHOG"      => string(rho_g_val),
    "CALIB_GBAR"      => string(g_bar_val),
    "CALIB_LAMBDA"    => string(lambda_val),
    "CALIB_SIGMA_Z"   => string(sigma_z),
    "CALIB_SIGMA_G"   => string(sigma_g)
)

mod_filepath = joinpath(mod_dir, "rbc_run.mod")
write(mod_filepath, model_string)

# --- 4.2. Ejecutar Dynare ---
original_dir = pwd()
cd(mod_dir)
println(">>> Ejecutando Dynare...")
dynare_output = @dynare "rbc_run.mod"
cd(original_dir)

# ==========================================
# 5. RECUPERACIÓN DE RESULTADOS
# ==========================================

# Estrategia de búsqueda de 'oo_' (Output Object)
res = nothing

# Intento 1: Buscar en el Scope Global (Main.oo_)
if isdefined(Main, :oo_)
    println(">>> Resultados encontrados en Main.oo_")
    res = Main.oo_

# Intento 2: Buscar dentro de un Módulo generado (Main.rbc_run.oo_)
# Dynare a veces crea un módulo con el nombre del archivo .mod
elseif isdefined(Main, :rbc_run) && isdefined(Main.rbc_run, :oo_)
    println(">>> Resultados encontrados en el módulo rbc_run.oo_")
    res = Main.rbc_run.oo_

# Intento 3: Carga Manual del script .jl generado
# Si todo falla, incluimos manualmente el archivo Julia que Dynare generó
else
    println(">>> Variable oo_ no detectada. Intentando cargar manualmente el script generado...")
    generated_jl = "rbc_run.jl" 
    if isfile(generated_jl)
        include(generated_jl) # Esto fuerza la creación de variables en el scope actual
        if isdefined(Main, :oo_)
            res = Main.oo_
            println(">>> Carga manual exitosa.")
        end
    end
end

# Volvemos al directorio original antes de cualquier error
cd(original_dir)

# Verificación Final
if isnothing(res)
    println("\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    println("ERROR FATAL: No se pudo recuperar 'oo_' de ninguna forma.")
    println("Intenta revisar la carpeta 'modfiles/p2' para ver si se generó 'rbc_run.jl'.")
    println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    exit()
end

# ==========================================
# 6. TABLAS Y RESULTADOS
# ==========================================

# Extracción de series (Orden declarado: y c k i n g A)
idx_y = 1; idx_c = 2; idx_i = 4; idx_n = 5
sim_len = 200

# Verificamos longitud
if size(res.endo_simul, 2) < sim_len
    error("Simulación muy corta.")
end

sim_y = res.endo_simul[idx_y, end-sim_len+1:end]
sim_c = res.endo_simul[idx_c, end-sim_len+1:end]
sim_i = res.endo_simul[idx_i, end-sim_len+1:end]
sim_n = res.endo_simul[idx_n, end-sim_len+1:end]

# Filtro HP (Logs) - Tal como C&E 1992
sim_y_hp = hp_filter(log.(sim_y))
sim_c_hp = hp_filter(log.(sim_c))
sim_i_hp = hp_filter(log.(sim_i))
sim_n_hp = hp_filter(log.(sim_n))

# Estadísticas
std_y = std(sim_y_hp)
std_c = std(sim_c_hp)
std_i = std(sim_i_hp)
std_n = std(sim_n_hp)
prod_hp = sim_y_hp .- sim_n_hp # Productividad

println("\n=======================================================")
println(" TABLA 3: REPLICACIÓN (Modelo Divisible Labor - α=1)")
println("=======================================================")
@printf("%-12s %-12s %-12s\n", "Variable", "Std Dev", "Relativo a Y")
@printf("%-12s %.4f       %.4f\n", "Output (Y)", std_y, 1.0)
@printf("%-12s %.4f       %.4f\n", "Consumo (C)", std_c, std_c/std_y)
@printf("%-12s %.4f       %.4f\n", "Inversión (I)", std_i, std_i/std_y)
@printf("%-12s %.4f       %.4f\n", "Horas (N)", std_n, std_n/std_y)

println("\n-------------------------------------------------------")
println(" Test Dunlop-Tarshis (Correlación Y/N, N)")
println("-------------------------------------------------------")
corr_val = cor(prod_hp, sim_n_hp)
println("Modelo RBC : ", round(corr_val, digits=4))
println("Datos Reales: ~0 (Cercano a cero)")

println("\n>>> Ejecución completada.")