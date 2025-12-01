var c_bar k_bar y_bar n g_bar lambda dy_obs h_obs;
varexo eps_lambda eps_mu;
varobs dy_obs h_obs;

parameters beta theta delta gamma N rho_g g_ss lambda_ss;

beta      = 1.03^(-0.25); 
delta     = 0.0210;
theta     = 0.33;        
gamma     = 2.99;         
N         = 1369;         
lambda_ss = 0.0045;       
g_ss      = 186.0;        
rho_g     = 0.98;         

model;
    // 1. Euler: k_bar es el capital decidido hoy para mañana
    1/beta = (theta * y_bar(+1) / k_bar + (1 - delta) * exp(-lambda(+1))) * (c_bar / c_bar(+1));
    
    // 2. Recursos: k_bar(-1) es el capital disponible hoy
    c_bar + k_bar - (1 - delta) * k_bar(-1) * exp(-lambda) = y_bar;
    
    // 3. Producción
    y_bar = n^(1 - theta) * (k_bar(-1) * exp(-lambda))^theta;
    
    // 4. Oferta Laboral
    (gamma * c_bar) / (N - n) = (1 - theta) * (y_bar / n);
    
    // 5. Gasto Gobierno
    log(g_bar) = (1 - rho_g) * log(g_ss) + rho_g * log(g_bar(-1)) + eps_mu;
    
    // 6. Tecnología
    lambda = lambda_ss + eps_lambda;

    // Observables
    dy_obs = (log(y_bar) - log(y_bar(-1)) + lambda) * 100;
    h_obs  = log(n) - log(steady_state(n));
end;

initval;
    lambda = 0.0045; g_bar = 186.0; n = 300; k_bar = 10000; y_bar = 1000; c_bar = 800; dy_obs = 0.45; h_obs = 0;
end;

shocks;
    var eps_lambda; stderr 0.01;
    var eps_mu;     stderr 0.01;
end;

steady;
check;
// Generamos 113,000 periodos (equivale a 1000 replicas de 113)
stoch_simul(order=1, irf=0, periods=113000, nograph, noprint);
