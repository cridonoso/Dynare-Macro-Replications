/* * Modelo 3: RBC con Trabajo Indivisible (Hansen)
 * La utilidad es lineal respecto a las horas trabajadas.
 */

// --- 1. Variables y Parámetros ---
var c y h k invest lambda productivity;
varexo eps_a;

parameters beta delta theta rho A h_ss sigma_eps B;

// --- 2. Calibración ---
beta      = 0.99;
delta     = 0.025;
theta     = 0.36;
rho       = 0.95;
A         = 2;         // Parámetro base (no usado directamente en ecuaciones, ver B)
sigma_eps = 0.00712;
h_ss      = 1/3;

// --- 3. Dinámica del Modelo ---
model;
    // Hogares: Ecuación de Euler
    1/c = beta * ((1/c(+1)) * (theta*(y(+1)/k) + (1-delta)));
    
    // Hogares: Oferta laboral (Rogerson/Hansen - lineal en h)
    (1-theta)*(y/h) = B*c;
    
    // Firmas: Función de producción
    y = lambda * k(-1)^(theta) * h^(1-theta);
    
    // Agregación: Restricción de recursos
    c = y + (1-delta)*k(-1) - k;
    
    // Agregación: Ley de movimiento del capital
    k = (1-delta)*k(-1) + invest;
    
    // Definiciones y Shocks
    productivity = y/h;
    log(lambda) = rho*log(lambda(-1)) + eps_a;
end;

// --- 4. Estado Estacionario ---
steady_state_model;
    lambda = 1;
    h = h_ss;
    
    // Ratios y Niveles
    k_y_ratio = theta / (1/beta - (1-delta));
    y = (k_y_ratio)^(theta/(1-theta)) * h;
    k = k_y_ratio * y;
    invest = delta * k;
    c = y - invest;
    productivity = y/h;
    
    // Calibración inversa del parámetro B
    B = (1-theta)*(y/h)/c;
end;

steady;
check;

// --- 5. Shocks y Simulación ---
shocks;
    var eps_a; stderr sigma_eps;
end;

stoch_simul(nograph, order=1, irf=20, loglinear, hp_filter=1600, periods=200) y c invest k h productivity;