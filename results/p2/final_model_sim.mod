// Nombre archivo: 3_model.mod
// Replicación Christiano & Eichenbaum (1992) - Alpha=1

var y c k n g lambda dy_obs h_obs w;
varexo e_lambda e_mu;

parameters beta theta delta gamma N rho_g g_ss lambda_ss;

// Cargar parámetros estimados desde Octave
beta = 0.9926375361451395; delta = 0.021; theta = 0.339; N = 1369.0;
lambda_ss = 0.0040282613306786424; gamma = 3.927072446951861; rho_g = 0.9905121477271471; g_ss = 0.014709744867656893;


// Asignación









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
    lambda=0.0040282613306786424; g=0.014709744867656893; n=298.6227955623073; k=10375.954658595983; y=994.2366965133898; c=735.4899265136936;
    w=2.200737740592977;
    dy_obs=0.40282613306786424; h_obs=5.699181223659103;
end;

shocks; var e_lambda; stderr 0.010760979630996634; var e_mu; stderr 0.012391; end;
steady(nocheck); check; stoch_simul(order=1, periods=10200, irf=0, nograph);
