// Replicación Christiano & Eichenbaum (1992) - Alpha=1

var y c k n g lambda dy_obs h_obs w;
varexo e_lambda e_mu;

parameters beta theta delta gamma N rho_g g_ss lambda_ss;

// Cargar parámetros estimados desde Octave
beta_val = 0.9926375361451395;
delta_val = 0.021;
theta_val = 0.339;
N_val = 1369.0;

gamma_val = 3.4703372342642944;
lambda_val = 0.0029531622859703464;
rho_g_val = 0.9073575890535783;
g_ss_val = 182.85693368384798;


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

initval;
    lambda=0.0029531622859703464; g=182.85693368384798; n=301.1659430582231; k=11017.183219082704; 
    y=1020.3580531562362; c=574.3349742386871;
    dy_obs=0.29531622859703466; h_obs=5.707661418676914;
end;

shocks; var e_lambda; stderr 0.011866939916248454; var e_mu; stderr 1.0e-8; end;
steady(nocheck); check; stoch_simul(order=1, periods=10200, irf=0, nograph);
