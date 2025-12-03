/* * Modelo 1: RBC Básico
 * Estructura estándar con trabajo divisible y utilidad separable.
 */

// --- 1. Variables y Parámetros ---
var y c k invest h lambda productivity;
varexo eps_a;

parameters beta delta theta rho sigma_eps gamma;

// --- 2. Calibración ---
beta      = 0.99;    // Factor de descuento
delta     = 0.025;   // Tasa de depreciación
theta     = 0.36;    // Participación del capital
rho       = 0.95;    // Persistencia del shock de TFP
sigma_eps = 0.00712; // Volatilidad del shock
gamma     = 2.0;     // Parámetro de desutilidad del trabajo (A)

// --- 3. Dinámica del Modelo ---
model;
    // Hogares: Ecuación de Euler
    1/c = beta * (1/c(+1)) * (theta * y(+1)/k + (1-delta));
    
    // Hogares: Oferta laboral intratemporal
    gamma / (1-h) = (1/c) * (1-theta) * y / h;
    
    // Firmas: Función de producción Cobb-Douglas
    y = lambda * k(-1)^theta * h^(1-theta);
    
    // Agregación: Restricción de recursos
    c + invest = y;
    
    // Agregación: Ley de movimiento del capital
    k = (1-delta)*k(-1) + invest;
    
    // Definiciones: Productividad laboral
    productivity = y / h;
    
    // Procesos Exógenos: Shock de TFP (AR1)
    log(lambda) = rho * log(lambda(-1)) + eps_a;
end;

// --- 4. Estado Estacionario ---
steady_state_model;
    lambda = 1;
    h = 1/3; // Objetivo de horas trabajadas
    
    // Ratios clave
    k_y_ratio = theta / (1/beta - (1-delta));
    
    // Niveles
    y = (k_y_ratio)^(theta/(1-theta)) * h;
    k = k_y_ratio * y;
    invest = delta * k;
    c = y - invest;
    
    // Parámetros derivados
    productivity = y/h;
    gamma = (1-theta)*(y/h)/c * (1-h);
end;

steady;
check;

// --- 5. Shocks y Simulación ---
shocks;
    var eps_a; stderr sigma_eps;
end;

stoch_simul(nograph, order=1, irf=20, loglinear, hp_filter=1600, periods=200) y c invest k h productivity;