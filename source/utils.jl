using LinearAlgebra
using Statistics
using Dynare # Asegúrate de que esté cargado

function solve_discrete_lyapunov(A, Q)
    n = size(A, 1)
    if maximum(abs.(eigen(A).values)) >= 1.0 - 1e-6
        error("Matriz A inestable o raíz unitaria")
    end
    lhs = I - kron(A, A)
    rhs = vec(Q)
    return reshape(lhs \ rhs, n, n)
end

"""
    rbc_gmm_loss_robust(params_guess, base_mod_path, target_moments)
"""
function rbc_gmm_loss_robust(params_guess, base_mod_path, target_moments)
    # 1. Configurar y Escribir .mod temporal
    work_dir = dirname(base_mod_path)
    temp_mod_name = "rbc_temp_est.mod"
    temp_mod_path = joinpath(work_dir, temp_mod_name)
    
    mod_content = read(base_mod_path, String)
    
    theta_val = params_guess[1]
    rho_val   = params_guess[2]
    sig_lam   = params_guess[3]
    sig_mu    = params_guess[4]
    
    # Escribimos el bloque de shocks y stoch_simul
    shocks_block = """
    theta = $theta_val;
    rho_g = $rho_val;
    shocks;
        var eps_lambda; stderr $sig_lam;
        var eps_mu;     stderr $sig_mu;
    end;
    steady;
    stoch_simul(order=1, irf=0, periods=0, nograph, noprint);
    """
    
    # Reemplazamos el stoch_simul original para evitar duplicados
    content_clean = replace(mod_content, "stoch_simul(order=1, irf=0, periods=0, nograph, noprint);" => "")
    # Fallback por si la string no coincide exactamente (espacios, etc)
    if content_clean == mod_content
         # Si no lo encontró, lo añadimos al final sin borrar nada (menos limpio pero funciona)
         content_clean = mod_content
    end
    
    write(temp_mod_path, content_clean * shocks_block)
    
    # 2. Ejecutar Dynare
    context = try
        eval(:(@dynare $temp_mod_path))
    catch
        return 1e10
    end
    
    # 3. Extraer Resultados
    if isempty(context.results.model_results)
        return 1e10
    end
    
    res = context.results.model_results[1]
    
    # Buscar Varianza (Sigma_y)
    Sigma_y = nothing
    if isdefined(res, :linearrationalexpectations)
        lre = res.linearrationalexpectations
        if isdefined(lre, :endogenous_variance)
            Sigma_y = lre.endogenous_variance
        end
    end
    
    if Sigma_y === nothing
        return 1e10
    end
    
    # 4. Calcular Momentos
    sym = context.symboltable
    
    # Indices en la matriz de varianza (Orden de declaración)
    idx_dy = sym["dy_obs"].orderintype
    idx_h  = sym["h_obs"].orderintype
    
    if size(Sigma_y, 1) < max(idx_dy, idx_h)
        return 1e10
    end
    
    var_dy = Sigma_y[idx_dy, idx_dy]
    var_h  = Sigma_y[idx_h, idx_h]
    cov_dy_h = Sigma_y[idx_dy, idx_h]
    
    # Media
    lam_ss_val = context.work.params[sym["lambda_ss"].orderintype]
    mean_dy = 100 * lam_ss_val
    
    # Desviaciones
    std_dy = sqrt(max(0, var_dy))
    std_h  = sqrt(max(0, var_h))
    
    if std_h < 1e-6 || std_dy < 1e-6
        return 1e10
    end
    
    # Correlación cruzada
    corr_dy_h = cov_dy_h / (std_dy * std_h)
    
    # NOTA: Omitimos Autocorrelación para evitar problemas de dimensión con ghx
    # Vector de 4 momentos
    model_moments = [mean_dy, std_dy, std_h, corr_dy_h]
    
    # 5. Loss
    diff = model_moments - target_moments
    return dot(diff, diff)
end

# Función HP Filter (Si no la tenías)
function hp_filter(y::Vector{Float64}, lambda::Float64=1600.0)
    n = length(y)
    if n < 3 return zeros(n) end
    I_mat = Matrix{Float64}(I, n, n)
    D = zeros(n-2, n)
    for i in 1:n-2
        D[i, i] = 1.0; D[i, i+1] = -2.0; D[i, i+2] = 1.0
    end
    A = I_mat + lambda * (D' * D)
    return y - (A \ y)
end