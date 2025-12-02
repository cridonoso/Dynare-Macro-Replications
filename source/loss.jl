using Statistics
# El script principal define: siggma, betta.

# --- Función para calcular los pesos de la función de pérdida (Welfare Loss) ---
function get_weights(alppha, epsilon, theta, varphi)
    # Definimos los valores que get_weights necesita pero que vienen del scope global del script principal
    betta  = 0.99
    siggma = 1.0     
    # Parámetros compuestos intermedios (lambda)
    Omega = (1-alppha)/(1-alppha+alppha*epsilon)
    lambda = (1-theta)*(1-betta*theta)/theta * Omega

    # Pesos finales
    weight_y = siggma + (varphi + alppha)/(1-alppha)
    weight_pi = epsilon / lambda
    
    return weight_y, weight_pi # Retorna Wp como Wpi
end

# --- Función de Pérdida de Bienestar (Solo para referencia, no usada en el script principal) ---
function welfare_loss(sim_data, idx_ygap, idx_pi, 
                      siggma, varphi, alppha, 
                      epsilon, theta, betta)

    # Cálculo de pesos (replicado para hacer la función independiente)
    Omega = (1-alppha)/(1-alppha+alppha*epsilon)
    lambda = (1-theta)*(1-betta*theta)/theta * Omega

    weight_y  = siggma + (varphi + alppha)/(1-alppha)
    weight_pi = epsilon / lambda 

    # Extraer series
    y_gap = sim_data[:, idx_ygap]
    pi    = sim_data[:, idx_pi]
    
    # Calcular varianzas de la muestra
    var_y = var(y_gap)
    var_p = var(pi)
    
    # Fórmula del enunciado
    L = 0.5 * (weight_y * var_y + weight_pi * var_p)
    return L
end