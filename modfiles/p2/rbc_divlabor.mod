// Replicación Christiano & Eichenbaum (1992) - Alpha=1

var y c k n g lambda dy_obs h_obs w;
varexo e_lambda e_mu;

parameters beta theta delta gamma N rho_g g_ss lambda_ss;

// Cargar parámetros estimados desde Octave
@#include "parameters.inc"

// Asignación
beta      = beta_val;
theta     = theta_val;
delta     = delta_val;
gamma     = gamma_val;
N         = N_val;
rho_g     = rho_g_val;
g_ss      = g_ss_val;
lambda_ss = lambda_val;

model;
    // --- Bloque del Modelo RBC Estacionario ---
    // Variables están normalizadas por tecnología z_t.
    // k es capital mañana. k(-1) es capital hoy.
    
    // 1. Euler (Consumo e Inversión)
    1/c = beta * (1/(c(+1)*exp(lambda(+1)))) * (theta * y(+1)/k(-1) + (1-delta));

    // 2. Restricción de Recursos
    // y = c + inversión + g
    y = c + k - (1-delta)*k(-1)*exp(-lambda) + g;

    // 3. Producción
    y = (k(-1)*exp(-lambda))^theta * n^(1-theta);

    // 4. Oferta Laboral (FOC Intratemporal, Alpha=1)
    w = (1-theta) * y / n;
    (gamma * c) / (N - n) = w;

    // 5. Gasto Gobierno (AR1)
    log(g) = (1 - rho_g)*log(g_ss) + rho_g*log(g(-1)) + e_mu;

    // 6. Choque Tecnológico
    lambda = lambda_ss + e_lambda;

    // --- Observables ---
    // Tasa de crecimiento del producto
    dy_obs = (log(y) - log(y(-1)) + lambda)*100;
    
    // Horas logarítmicas (desviadas)
    h_obs = log(n); 
end;

// --- Bloque de Estado Estacionario ---
steady_state_model;
    lambda = lambda_ss;
    g = g_ss;

    // 1. CORRECCIÓN DEL RATIO Y/K (incluye crecimiento exp(lambda_ss))
    yk_ratio = (exp(lambda_ss)/beta - (1-delta)) / theta;
    
    // Solución para n (la fórmula es compleja pero se mantiene si yk_ratio es correcto)
    n = ( (1-theta)*yk_ratio*(N-g/yk_ratio) ) / ( gamma*(1-delta) + (1-theta)*yk_ratio );
    
    // Cálculo de k y y
    k = (n^(1-theta) / yk_ratio)^(1/theta);
    y = k * yk_ratio;
    
    // 2. CORRECCIÓN DE C (Consumo en estado estacionario)
    // c = y - Inversión_SS - g. Donde Inversión_SS = k * (exp(lambda_ss) - (1-delta))
    c = y - k*(exp(lambda_ss) - (1-delta)) - g;

    dy_obs = lambda*100;
    h_obs = log(n);
end;