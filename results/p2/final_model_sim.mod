// Nombre archivo: 3_model.mod
// Replicación Christiano & Eichenbaum (1992) - Alpha=1

var y c k n g lambda dy_obs h_obs w;
varexo e_lambda e_mu;

parameters beta theta delta gamma N rho_g g_ss lambda_ss;

// Cargar parámetros estimados desde Octave
beta = 0.9926375361451395; delta = 0.021; theta = 0.339; N = 1369.0;
lambda_ss = 0.0037092270809439363; gamma = 3.3483073360077786; rho_g = 0.9958903794772136; g_ss = 0.011815215971179738;


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
    lambda=0.0037092270809439363; g=0.011815215971179738; n=299.6345420764695; k=10569.528886907488; y=1002.725569817462; c=742.4432605220085;
    w=2.212033355887885;
    dy_obs=0.37092270809439365; h_obs=5.702563538977429;
end;

shocks; var e_lambda; stderr 0.010951545078475289; var e_mu; stderr 0.012391; end;
steady(nocheck); check; stoch_simul(order=1, periods=10200, irf=0, nograph);
