/* * Modelo: New Keynesian Model (Galí 2015, Cap. 4)
 * Variante: Regla de Política Forward-Looking
 */

// --- 1. Variables ---
var pi y_gap y_nat y r_nat r_real i n a z;

varexo e_a e_z;

// --- 2. Parámetros ---
parameters beta sigma varphi alpha epsilon theta 
           rho_a rho_z phi_pi phi_y;

// Calibración
beta    = 0.99;
sigma   = 1.0;
varphi  = 5.0;
alpha   = 0.25;
epsilon = 9.0;
theta   = 0.75;

rho_a   = 0.90;
rho_z   = 0.50;

phi_pi  = 1.5;
phi_y   = 0.125; 

// --- 3. Modelo Dinámico ---
model(linear);
    // Parámetros auxiliares
    # Omega = (1-alpha)/(1-alpha+alpha*epsilon);
    # psi_n_ya = (1+varphi)/(sigma*(1-alpha)+varphi+alpha);
    # lambda = (1-theta)*(1-beta*theta)/theta * Omega;
    # kappa = lambda * (sigma + (varphi+alpha)/(1-alpha));

    // 1. Curva IS Dinámica
    y_gap = y_gap(+1) - (1/sigma)*(i - pi(+1) - r_nat);

    // 2. Curva de Phillips Neokeynesiana (NKPC)
    pi = beta * pi(+1) + kappa * y_gap;

    // 3. Regla de Política Monetaria (Forward-Looking)
    // DIFERENCIA CLAVE: Reacciona a E_t[pi_{t+1}]
    i = phi_pi * pi(+1) + phi_y * y_gap;

    // 4. Ecuaciones Restantes (Idénticas al modelo base)
    r_nat = -sigma*psi_n_ya*(1-rho_a)*a + (1-rho_z)*z;
    y_nat = psi_n_ya * a;
    y = y_gap + y_nat;
    n = (y - a)/(1-alpha);
    r_real = i - pi(+1);
    
    // Procesos Exógenos
    a = rho_a * a(-1) + e_a;
    z = rho_z * z(-1) + e_z;
end;

// --- 4. Shocks ---
shocks;
    var e_a; stderr 1.0;
    var e_z; stderr 1.0;
end;

stoch_simul(order=1, irf=0, nograph);