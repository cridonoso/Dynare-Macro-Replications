/* * Modelo 4: RBC con Gasto de Gobierno Estocástico
 * Incluye un shock exógeno al gasto público.
 */

// --- 1. Variables y Parámetros ---
var c invest y k h z g productivity;
varexo e_z e_g;

parameters beta delta theta rho A lamg ghat;

// --- 2. Calibración ---
beta  = 0.99;
delta = 0.025;
theta = 0.36;
rho   = 0.95;
lamg  = 0.96;       // Persistencia del gasto
ghat  = 0.271634;   // Gasto de estado estacionario (calibrado ex-ante)
A     = 2.4445;     // Desutilidad laboral

// --- 3. Dinámica del Modelo ---
model;
    // Hogares: Ecuación de Euler
    1/c = beta * (1/c(+1)) * (theta * exp(z(+1)) * k^(theta-1) * h(+1)^(1-theta) + 1 - delta);
    
    // Hogares: Oferta laboral
    A/(1-h) = (1/c) * (1-theta) * y / h;

    // Firmas: Función de producción
    y = exp(z) * k(-1)^theta * h^(1-theta);
    
    // Agregación: Restricción de recursos (con gobierno)
    c + invest + g = y;
    
    // Agregación: Ley de movimiento del capital
    k = (1-delta)*k(-1) + invest;
    
    // Definiciones
    productivity = y / h;
    
    // Procesos Exógenos
    z = rho*z(-1) + e_z;                                        // TFP
    log(g) = (1-lamg)*log(ghat) + lamg*log(g(-1)) + e_g;        // Gasto Gobierno
end;

// --- 4. Estado Estacionario ---
steady_state_model;
    z = 0;
    g = ghat;
    h = 1/3;
    
    // Ratios y Niveles
    k_y_ratio = theta / (1/beta - (1-delta));
    y = (k_y_ratio)^(theta/(1-theta)) * h;
    k = k_y_ratio * y;
    invest = delta * k;
    
    // Consumo residual
    c = y - invest - g;
    
    // Parámetros derivados
    A = (1-theta)*(y/h)/c * (1-h);
    productivity = y / h;
end;

steady;
check;

// --- 5. Shocks y Simulación ---
shocks;
    var e_z; stderr 0.00712; 
    var e_g; stderr 0.021;   
end;

stoch_simul(nograph, order=1, irf=0, noprint);