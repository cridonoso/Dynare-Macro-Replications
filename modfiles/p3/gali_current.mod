var pi y_gap y_nat y yhat i r_nat a z;
varexo eps_a eps_z;

parameters betta siggma varphi alppha epsilon theta rho_a rho_z phi_pi phi_y;
parameters Omega psi_n_ya lambda kappa;

/* ===== Calibración (Galí 2015) ===== */
betta  = 0.99;
siggma = 1;
varphi = 5;
alppha = 1/4;
epsilon = 9;
theta   = 3/4;
rho_a = 0.90;
rho_z = 0.50;

/* ===== Coeficientes Política (default) ===== */
phi_pi = 1.5;
phi_y  = 0.125;

/* ===== Parámetros compuestos ===== */
Omega    = (1-alppha)/(1-alppha+alppha*epsilon);
psi_n_ya = (1+varphi)/(siggma*(1-alppha)+varphi+alppha);
lambda   = (1-theta)*(1-betta*theta)/theta * Omega;
kappa    = lambda*(siggma + (varphi+alppha)/(1-alppha));

model(linear);
    // Curva de Phillips NK
    pi = betta*pi(+1) + kappa*y_gap;

    // IS en brechas (output gap)
    y_gap = -(1/siggma)*( i - pi(+1) - r_nat ) + y_gap(+1);

    // Tasa natural
    r_nat = -siggma*psi_n_ya*(1-rho_a)*a + (1-rho_z)*z;
    y_nat = psi_n_ya * a;

    // Output total
    y    = y_nat + y_gap;
    yhat = y - steady_state(y);

    // Regla de Taylor (Contemporánea)
    i = 0.0 + phi_pi*pi + phi_y*y_gap; // <-- Regla de Taylor (Current)

    // Procesos de choques
    a = rho_a*a(-1) + eps_a;
    z = rho_z*z(-1) + eps_z;
end;

steady;
check;

shocks;
var eps_a = 1; 
var eps_z = 1; 
end;

stoch_simul(order=1, irf=0, nograph);