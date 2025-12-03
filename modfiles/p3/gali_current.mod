/* * Modelo: New Keynesian Model (Galí 2015, Cap. 4)
 * Variante: Regla de Política Contemporánea (Current Looking)
 */

// --- 1. Variables ---
var pi      $ \pi $         (long_name='inflation')
    y_gap   $ \tilde{y} $   (long_name='output gap')
    y_nat   $ y^n $         (long_name='natural output')
    y       $ y $           (long_name='output')
    r_nat   $ r^n $         (long_name='natural interest rate')
    r_real  $ r $           (long_name='real interest rate')
    i       $ i $           (long_name='nominal interest rate')
    n       $ n $           (long_name='hours')
    a       $ a $           (long_name='technology shock')
    z       $ z $           (long_name='preference shock');

varexo e_a  $ \varepsilon_a $ 
       e_z  $ \varepsilon_z $;

// --- 2. Parámetros ---
parameters beta sigma varphi alpha epsilon theta 
           rho_a rho_z phi_pi phi_y;

// Calibración (Galí 2015, Tabla 4.1)
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
    // Parámetros compuestos
    # Omega = (1-alpha)/(1-alpha+alpha*epsilon);
    # psi_n_ya = (1+varphi)/(sigma*(1-alpha)+varphi+alpha);
    # lambda = (1-theta)*(1-beta*theta)/theta * Omega;
    # kappa = lambda * (sigma + (varphi+alpha)/(1-alpha));

    // 1. Curva IS Dinámica
    y_gap = y_gap(+1) - (1/sigma)*(i - pi(+1) - r_nat);

    // 2. Curva de Phillips Neokeynesiana (NKPC)
    pi = beta * pi(+1) + kappa * y_gap;

    // 3. Regla de Política Monetaria (Contemporánea)
    i = phi_pi * pi + phi_y * y_gap;

    // 4. Tasa de Interés Natural
    r_nat = -sigma*psi_n_ya*(1-rho_a)*a + (1-rho_z)*z;

    // 5. Producto Natural
    y_nat = psi_n_ya * a;

    // 6. Definiciones Auxiliares
    y = y_gap + y_nat;
    n = (y - a)/(1-alpha);
    r_real = i - pi(+1);

    // 7. Procesos Exógenos
    a = rho_a * a(-1) + e_a;
    z = rho_z * z(-1) + e_z;
end;

// --- 4. Shocks ---
shocks;
    var e_a; stderr 1.0; // Calibrado al 1% para análisis
    var e_z; stderr 1.0;
end;

stoch_simul(order=1, irf=0, nograph);