/* * Modelo 2: RBC con Ocio No Separable
 * Incluye formación de hábitos en el ocio ("Leisure Services").
 */

// --- 1. Variables y Parámetros ---
var c y h k invest lambda productivity L X mu;
varexo eps_a;

parameters beta delta theta rho A h_ss sigma_eps eta a_0;

// --- 2. Calibración ---
beta      = 0.99;
delta     = 0.025;
theta     = 0.36;
rho       = 0.95;
A         = 2;
sigma_eps = 0.00712;
h_ss      = 1/3;
a_0       = 0.35; // Peso del ocio actual
eta       = 0.10; // Tasa de depreciación del stock de ocio

// --- 3. Dinámica del Modelo ---
model;
    // Hogares: Ecuación de Euler (Consumo)
    1/c = beta * ((1/c(+1)) * (theta*(y(+1)/k) + (1-delta)));
    
    // Hogares: Condición de primer orden (Trabajo/Ocio)
    (1/c)*(1-theta)*(y/h) = ((A*a_0)/L) + mu;
    
    // Hogares: Ecuación de Euler para el Ocio (Intertemporal)
    mu = beta * ((A*eta*(1-a_0))/L(+1) + mu(+1)*(1-eta));
    
    // Definición: Servicios de Ocio
    L = a_0*(1-h) + eta*(1-a_0)*X(-1);
    
    // Definición: Ley de movimiento del stock de Ocio
    X = (1-eta)*X(-1) + (1-h);
    
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
    
    // Dinámica del ocio en SS
    X = (1-h)/eta;
    L = 1-h;
    
    // Producción y Capital
    k_y_ratio = theta / (1/beta - (1-delta));
    y = (k_y_ratio)^(theta/(1-theta)) * h;
    k = k_y_ratio * y;
    invest = delta * k;
    c = y - invest;
    
    // Parámetros derivados y variables auxiliares
    productivity = y/h;
    term_labor_benefit = (1-theta)*(y/h)/c;
    denom_A = a_0 + (beta*eta*(1-a_0))/(1-beta*(1-eta));
    A = term_labor_benefit*(1-h)/denom_A;
    mu = (beta*A*eta*(1-a_0)) / ((1-h)*(1-beta*(1-eta)));
end;

steady;
check;

// --- 5. Shocks y Simulación ---
shocks;
    var eps_a; stderr sigma_eps;
end;

stoch_simul(nograph, order=1, irf=20, loglinear, hp_filter=1600, periods=200) y c invest k h productivity;