// Replicación Christiano & Eichenbaum (1992) - Alpha=1

var y c k n g lambda dy_obs h_obs w;
varexo e_lambda e_mu;

parameters beta theta delta gamma N rho_g g_ss lambda_ss;

// Cargar parámetros estimados desde Octave
beta_val = 0.9926375361451395;
delta_val = 0.021;
theta_val = 0.339;
N_val = 1369.0;
gamma_val = 3.3427445168450696;
lambda_val = 0.0036578873720433175;
rho_g_val = 0.9960029157452728;
g_ss_val = 208.65794744839732;


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
    lambda=0.0036578873720433175; g=208.65794744839732; 
    n=301.69876812558994; k=10668.384673025885; 
    y=1010.4703064779537; c=539.6418183663617;
    dy_obs=0.36578873720433175; h_obs=5.709429063046271;
end;

shocks; var e_lambda; stderr 0.010874758001813799; var e_mu; stderr 0.008014227742999066; end;
steady(nocheck); check; stoch_simul(order=1, periods=120, replic=500, irf=0, nograph);
