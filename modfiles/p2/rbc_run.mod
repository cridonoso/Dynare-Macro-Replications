var y c k i n g A;
varexo e_a e_g;

parameters beta delta theta gamma N_bar rho_g g_bar lambda;

// Asignación de valores calibrados desde Julia
beta  = 0.9926375361451395;
delta = 0.021;
theta = 0.1852177848674954;
gamma = 22.933010831877205;
N_bar = 1369.0;
rho_g = 0.96;
g_bar = 0.012148318659727087;
lambda = 0.004;

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
    var e_a; stderr 0.018;
    var e_g; stderr 0.02;
end;

steady;
check;
stoch_simul(order=1, periods=200, irf=0);
