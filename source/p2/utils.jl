module ReplicationTools

using DataFrames
using CSV
using Statistics
using LinearAlgebra
using SparseArrays
using Printf
using Dynare


function hp_filter(y, lam=1600.0)
    n = length(y); D = spzeros(n-2, n)
    for i in 1:n-2 
        D[i,i]=1; D[i,i+1]=-2; D[i,i+2]=1 
    end
    F = sparse(I,n,n) + lam*(D'*D)
    return y - (F \ y)
end

# =========================================================================================
# 1. ESTIMACIÓN DE PARÁMETROS (TABLA 1)
# =========================================================================================
function estimate_parameters(y_data, c_data, g_data, n_data, N_total, theta_val, beta_val)
    
    # 1. Estimación GMM / Momentos
    dy = diff(log.(y_data))
    lambda_hat = mean(dy)
    sigma_lambda_hat = std(dy)

    # Ajuste de escala (Horas)
    scale_factor = 320.0 / mean(n_data)
    n_data_adj   = n_data .* scale_factor

    vec_gamma = (1 - theta_val) .* (y_data ./ n_data_adj) .* (N_total .- n_data_adj) ./ c_data
    gamma_hat = mean(vec_gamma)

    # 2. Estimación OLS para G (AR(1) process)
    lg = log.(g_data)

    # Excluye la primera observación (la serie de datos tiene que ser y_t y x_t-1)
    Y_reg = lg[2:end]; X_reg = hcat(ones(length(Y_reg)), lg[1:end-1]) 
    B_ols = X_reg \ Y_reg
    rho_g_hat = B_ols[2]; const_g = B_ols[1]
    g_ss_hat  = exp(const_g / (1 - rho_g_hat))
    sigma_mu_hat = std(Y_reg - X_reg * B_ols)
    
    # Devuelve los parámetros estimados en un NamedTuple
    return (; lambda_hat, sigma_lambda_hat, gamma_hat, rho_g_hat, g_ss_hat, sigma_mu_hat, N_total, theta_val, beta_val)
end

# =========================================================================================
# 2. CÁLCULO DEL ESTADO ESTACIONARIO (TABLA 2)
# =========================================================================================
function solve_steady_state(params_est; delta_val=0.021, max_iter=10000, tol=1e-15)
    
    # Desempaquetar parámetros
    (; lambda_hat, beta_val, theta_val, gamma_hat, g_ss_hat, N_total) = params_est
    
    exp_lam = exp(lambda_hat)
    ky_ratio_inv = (1/beta_val * exp_lam - (1-delta_val)) / theta_val

    # Función residual para la solución de punto fijo (n)
    resid_n(n) = begin
        k = (n^(1-theta_val) / ky_ratio_inv)^(1/(1-theta_val))
        y = k * ky_ratio_inv
        c_val = y - k*(1 - (1-delta_val)*exp(-lambda_hat)) - g_ss_hat
        rhs = (1-theta_val)*(y/n)*((N_total-n)/gamma_hat)
        return c_val - rhs
    end

    n_guess = 300.0 # Guess inicial
    step_size = 0.000001
    
    for i in 1:max_iter 
        r = resid_n(n_guess)
        if abs(r) < tol 
            break 
        end 
        n_guess = n_guess - r * step_size
    end
    
    # Calcular valores SS finales
    n_ss = n_guess
    k_ss = (n_ss^(1-theta_val) / ky_ratio_inv)^(1/(1-theta_val))
    y_ss = k_ss * ky_ratio_inv
    c_ss = y_ss - k_ss*(1 - (1-delta_val)*exp(-lambda_hat)) - g_ss_hat

    # Ratios para Tabla 2
    cy_ratio = c_ss / y_ss
    gy_ratio = g_ss_hat / y_ss
    dky_ratio = (y_ss - c_ss - g_ss_hat) / y_ss # Investment/Y
    ky_ratio = k_ss / y_ss
    
    return (; n_ss, k_ss, y_ss, c_ss, cy_ratio, gy_ratio, dky_ratio, ky_ratio)
end

# =========================================================================================
# 3. SIMULACIÓN Y MOMENTOS (CORREGIDO: Flatten Data + Small Sample)
# =========================================================================================
function run_simulation_and_moments(mod_base, params_full, ss_vals, results_dir)
    
    mod_scen = joinpath(results_dir, "model_gen_tables.mod")
    
    # Usar la varianza estimada del gobierno
    sigma_mu_sim = params_full.sigma_mu_hat 

    # 1. Construir Bloques
    params_def_str = """
    beta_val = $(params_full.beta_val);
    delta_val = $(params_full.delta_val);
    theta_val = $(params_full.theta_val);
    N_val = $(params_full.N_total);
    gamma_val = $(params_full.gamma_hat);
    lambda_val = $(params_full.lambda_hat);
    rho_g_val = $(params_full.rho_g_hat);
    g_ss_val = $(params_full.g_ss_hat);
    """
    
    initval_block = """
    initval;
        lambda=$(params_full.lambda_hat); g=$(params_full.g_ss_hat); 
        n=$(ss_vals.n_ss); k=$(ss_vals.k_ss); 
        y=$(ss_vals.y_ss); c=$(ss_vals.c_ss);
        dy_obs=$(params_full.lambda_hat*100); h_obs=$(log(ss_vals.n_ss));
    end;
    """
    
    shocks_block = "shocks; var e_lambda; stderr $(params_full.sigma_lambda_hat); var e_mu; stderr $(sigma_mu_sim); end;"

    # 2. Configuración de Dynare (Small Sample: 120 periodos, 500 réplicas)
    dynare_command = "steady(nocheck); check; stoch_simul(order=1, periods=120, replic=500, irf=0, nograph);"

    # Escribir archivo
    mod_content = read(mod_base, String)
    mod_content = replace(mod_content, r"^\s*@#include.*$"m => params_def_str) 
    mod_content = replace(mod_content, r"steady_state_model;.*?end;"s => "") 
    mod_content = replace(mod_content, r"initval;.*?end;"s => "") 
    mod_content = replace(mod_content, r"shocks;.*end;"s => "") 
    mod_content = replace(mod_content, r"stoch_simul.*" => "")

    open(mod_scen, "w") do io
        println(io, mod_content) 
        println(io, initval_block) 
        println(io, shocks_block)
        println(io, dynare_command)
    end

    # 3. Ejecutar Dynare
    context = Dynare.dynare(mod_scen)
    
    # 4. Procesamiento de Resultados
    all_sims = context.results.model_results[1].simulations
    if isempty(all_sims)
        error("Error: No se generaron simulaciones.")
    end

    # Acumuladores
    m_sig_y, m_sig_c_y, m_sig_dk_y, m_sig_n_y, m_sig_g_y, m_sig_w_prod, m_corr = 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
    N_sims = length(all_sims)

    for i in 1:N_sims
        sim_data = all_sims[i].data
        
        # --- CORRECCIÓN AQUÍ: Agregado vec() para aplanar matrices ---
        get_d(var) = vec(Float64.(collect(getproperty(sim_data, Symbol(var)))))

        vec_y = get_d("y"); vec_c = get_d("c"); vec_g = get_d("g"); vec_n = get_d("n")
        vec_dk = vec_y .- vec_c .- vec_g 
        vec_prod = vec_y ./ vec_n
        vec_w = (1 - params_full.theta_val) .* vec_prod 

        # HP Filter
        cycle_y = hp_filter(log.(max.(vec_y, 1e-10)))
        cycle_c = hp_filter(log.(max.(vec_c, 1e-10)))
        cycle_dk = hp_filter(log.(max.(vec_dk, 1e-10)))
        cycle_n = hp_filter(log.(max.(vec_n, 1e-10)))
        cycle_g = hp_filter(log.(max.(vec_g, 1e-10)))
        cycle_prod = hp_filter(log.(max.(vec_prod, 1e-10)))
        cycle_w = hp_filter(log.(max.(vec_w, 1e-10)))

        # Estadísticos
        std_y = std(cycle_y)
        
        m_sig_y += std_y
        m_sig_c_y += std(cycle_c)/std_y
        m_sig_dk_y += std(cycle_dk)/std_y
        m_sig_n_y += std(cycle_n)/std_y
        m_sig_g_y += std(cycle_g)/std_y
        m_sig_w_prod += std(cycle_w)/std(cycle_prod)
        
        # Correlación (Ahora vec() asegura que devuelva un escalar)
        m_corr += cor(cycle_prod, cycle_n)
    end

    # Promedios
    sim_moments = (
        sig_y = m_sig_y / N_sims,
        sig_c_y = m_sig_c_y / N_sims,
        sig_dk_y = m_sig_dk_y / N_sims,
        sig_n_y = m_sig_n_y / N_sims,
        sig_g_y = m_sig_g_y / N_sims,
        sig_w_prod = m_sig_w_prod / N_sims,
        corr_prod_n = m_corr / N_sims
    )
    
    return sim_moments
end

# =========================================================================================
# 4. GENERACIÓN DE LATEX
# =========================================================================================
function generate_latex_tables(params_est, ss_vals, sim_moments)
    
    # Parámetros Fijos
    beta_val  = params_est.beta_val
    delta_val = 0.021
    theta_val = params_est.theta_val
    N_total   = params_est.N_total

    # Ratios SS
    (; cy_ratio, gy_ratio, dky_ratio, ky_ratio, n_ss) = ss_vals
    
    # Momentos Simulación
    (; sig_y, sig_c_y, sig_dk_y, sig_n_y, sig_g_y, sig_w_prod, corr_prod_n) = sim_moments

    # === CORRECCIÓN: Se usa `raw"..."` para evitar problemas con `\` y `$` de LaTeX ===
    latex_output = string(
        raw"""
    \begin{table}[H]
        \centering
        \caption{Estimaciones de Parámetros del Modelo: Comparación de Resultados Propios con el Modelo Divisible Labor without Government ($\alpha = 1$)}
        \label{tab:comparacion_parametros_update}
        \begin{tabular}{lcc}
        \toprule
        \textbf{Parámetro} & \textbf{Este Trabajo} & \textbf{Lawrence et.al., 1992} \\
        \midrule
        $\beta$ & """, @sprintf("%.4f", beta_val), raw""" & 0.9926 \\
        $\delta$ & """, @sprintf("%.4f", delta_val), raw""" & 0.0210 \\
        $\theta$ & """, @sprintf("%.4f", theta_val), raw""" & 0.3390 \\
        $N$ & """, @sprintf("%d", Int(N_total)), raw""" & 1369 \\
        $\gamma$ & """, @sprintf("%.4f", params_est.gamma_hat), raw""" & 2.9900 \\
        $\lambda$ & """, @sprintf("%.4f", params_est.lambda_hat), raw""" & 0.0040 \\
        $\sigma_{\varepsilon}$ & """, @sprintf("%.4f", params_est.sigma_lambda_hat), raw""" & 0.0180 \\
        $\bar{g}$ & """, @sprintf("%.4f", params_est.g_ss_hat), raw""" & 186.0000 \\
        $\rho$ & """, @sprintf("%.4f", params_est.rho_g_hat), raw""" & 0.9600 \\
        $\sigma_{\mu}$ & """, @sprintf("%.4f", params_est.sigma_mu_hat), raw""" & 0.0200 \\
        \bottomrule
        \end{tabular}
    \end{table}

    \begin{table}[H]
        \centering
        \caption{Propiedades de Primer Momento: Comparación de Resultados Propios con el Modelo Divisible Labor without Government ($\alpha = 1$)}
        \label{tab:comparacion_primer_momentos_update}
        \begin{tabular}{lcc}
        \toprule
        \textbf{Variable} & \textbf{Este Trabajo (SS)} & \textbf{Lawrence et.al., 1992} \\
        \midrule
        $c_t / y_t$ & """, @sprintf("%.4f", cy_ratio), raw""" & 0.5600 \\
        $g_t / y_t$ & """, @sprintf("%.4f", gy_ratio), raw""" & 0.1770 \\
        $dk_t / y_t$ & """, @sprintf("%.4f", dky_ratio), raw""" & 0.2600 \\
        $k_{t+1} / y_t$ & """, @sprintf("%.2f", ky_ratio), raw""" & 10.54 \\
        $n_t$ & """, @sprintf("%.2f", n_ss), raw""" & 315.60 \\
        \bottomrule
        \end{tabular}
    \end{table}

    \begin{table}[H]
        \centering
        \caption{Momentos de Segundo Orden: Comparación de Resultados Propios con el Modelo Divisible Labor without Government ($\alpha = 1$)}
        \label{tab:comparacion_momentos_corregida_update}
        \begin{tabular}{lcc}
        \toprule
        \textbf{Estadístico} & \textbf{Este Trabajo} & \textbf{Lawrence et.al., 1992} \\
        \midrule
        $\sigma_c / \sigma_y$ & """, @sprintf("%.4f", sig_c_y), raw""" & 0.5700 \\
        $\sigma_{dk} / \sigma_y$ & """, @sprintf("%.4f", sig_dk_y), raw""" & 2.3300 \\
        $\sigma_n / \sigma_y$ & """, @sprintf("%.4f", sig_n_y), raw""" & 0.3600 \\
        $\sigma_{r} / \sigma_{y/n}$ & """, @sprintf("%.4f", sig_w_prod), raw""" & 0.5400 \\
        $\sigma_g / \sigma_y$ & """, @sprintf("%.4f", sig_g_y), raw""" & 1.7600 \\
        $\sigma_y$ & """, @sprintf("%.4f", sig_y * 100), raw""" & 0.0200 \\
        \text{corr}(y/n, n) & """, @sprintf("%.4f", corr_prod_n), raw""" & 0.9500 \\
        \bottomrule
        \end{tabular}
    \end{table}
    """)
    return latex_output
end

# =========================================================================================
# 5. PROCESAMIENTO DE DATOS (NUEVO)
# =========================================================================================
function preprocess_usa_data(dataset::DataFrame)
    # 1. Conversión de Tipos
    data_cols = names(dataset, Not(:date)) 
    for col_name in data_cols
        dataset[!, Symbol(col_name)] = Float64.(dataset[!, Symbol(col_name)])
    end

    # 2. Transformación Per Cápita
    transform!(dataset, 
        [:Y_raw, :N_raw] => ByRow(/) => :y_pc,
        [:C_raw, :N_raw] => ByRow(/) => :c_pc,
        [:G_raw, :N_raw] => ByRow(/) => :g_pc,
        [:H_raw, :N_raw] => ByRow(/) => :h_pc, # Horas por cápita
        renamecols=false
    )

    # 3. Tasa de crecimiento del producto (dy = diff log * 100)
    transform!(dataset, :y_pc => (y -> vcat(missing, diff(log.(y)) .* 100)) => :dy_obs)

    # 4. Horas (log) per cápita (h_log - mean)
    # Nota: Usamos skipmissing para calcular la media ignorando nans/missings previos
    h_log_mean = mean(log.(skipmissing(dataset.h_pc)))
    transform!(dataset, :h_pc => (h -> log.(h) .- h_log_mean) => :h_obs)

    # 5. Horas laborales per cápita (level log)
    transform!(dataset, :h_pc => (h -> log.(h)) => :h_log)

    # 6. Limpieza Final
    dropmissing!(dataset)
    select!(dataset, :date, :dy_obs, :h_obs, :R_raw, :C_raw, :G_raw, :I_raw, :y_pc, :c_pc, :g_pc, :h_pc, :h_log)
    
    println(">>> Filas finales para estimación: $(nrow(dataset))")
    
    return dataset
end

function save_usa_data(dataset::DataFrame, output_file::String, output_gmm::String)
    # 1. Guardar el dataset completo (con encabezados)
    CSV.write(output_file, dataset)
    
    # 2. Crear y guardar el dataset específico para GMM (sin encabezados)
    df_gmm = DataFrame(
        y = dataset.y_pc, 
        c = dataset.c_pc, 
        g = dataset.g_pc, 
        n = dataset.h_pc 
    )
    CSV.write(output_gmm, df_gmm, header=false)
    
    # 3. Mensajes de confirmación
    println(">>>   Archivo 'data_usa.csv' guardado en: $(output_file)")
    println(">>>   Archivo 'data_gmm.csv' guardado en: $(output_gmm)")
end

export estimate_parameters, solve_steady_state, run_simulation_and_moments, generate_latex_tables, preprocess_usa_data, save_usa_data

end # end module ReplicationTools