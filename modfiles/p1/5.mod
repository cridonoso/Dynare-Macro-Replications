/* Model with Market and Home Production */

// -------------------------------------------------------------------------
// 1. Variable and Parameter Declaration
// -------------------------------------------------------------------------
var c $c$ (long_name='aggregate consumption') // Consumo Agregado
    k $k$ (long_name='capital stock') // Capital
    invest $i$ (long_name='investment') // Inversión
    leisure $l$ (long_name='leisure') // Ocio
    hM $h_M$ (long_name='market hours') // Horas de Mercado
    hH $h_H$ (long_name='home hours') // Horas en Casa
    cM $c_M$ (long_name='market consumption') // Consumo de Mercado
    cH $c_H$ (long_name='home consumption') // Consumo en Casa
    yM $y_M$ (long_name='market output') // Producto de Mercado
    yH $y_H$ (long_name='home output') // Producto en Casa
    zM $z_M$ (long_name='market TFP shock') // Shock PTF Mercado
    zH $z_H$ (long_name='home TFP shock') // Shock PTF Casa
    productivity (long_name='market productivity') // Productividad de Mercado
    y (long_name='aggregate output alias') // Alias para yM
    h (long_name='market hours alias'); // Alias para hM

varexo eM eH; 

parameters beta delta theta eta rhoM rhoH e A alpha phi ratio_yM_kM kM kH; 

// -------------------------------------------------------------------------
// 2. Calibration
// -------------------------------------------------------------------------
beta  = 0.99;    
delta = 0.025;   
theta = 0.36;    
eta   = 0.08;    
rhoM  = 0.95;    
rhoH  = 0.95;    
e     = 0.8;     
 
// Parameters calibrated in the SS
A     = 2.84;
alpha = 0.344;
phi   = 0.885;

// IMPORTANT: We define k as predetermined
// This tells Dynare that k_t is a state variable (it comes from t-1)
predetermined_variables k;

// -------------------------------------------------------------------------
// 3. Model Equations
// -------------------------------------------------------------------------
model;
// 1. Aggregate Consumption
c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);

// 2. Leisure
leisure = 1 - hM - hH;

// 3. Market Production (k is predetermined, so k is the current stock)
yM = exp(zM) * (phi*k)^(theta) * hM^(1-theta); 

// 4. Home Production
yH = exp(zH) * ((1-phi)*k)^(eta) * hH^(1-eta); 

// 5. Market Resource Balance
cM + invest = yM;

// 6. Home Resource Balance
cH = yH; 

// 7. Capital Law of Motion
// Since k is predetermined:
// k is k_t (start of the period)
// k(+1) is k_{t+1} (stock for the next period)
k(+1) = (1-delta)*k + invest;

// 8. Exogenous Process zM (CORRECTED: Backward looking)
zM = rhoM*zM(-1) + eM;

// 9. Exogenous Process zH (CORRECTED: Backward looking)
zH = rhoH*zH(-1) + eH;

// 10. Euler Equation
// Note: As k is predetermined, k(+1) is the stock used in t+1.
alpha*cM^(e-1)*c^(1-e)*(1/c) 
= beta * (alpha*cM(+1)^(e-1)*c(+1)^(1-e)*(1/c(+1))) * (theta*(yM(+1)/(phi*k(+1))) + (1-delta));

// 11. Intratemporal Condition Market vs Home
alpha*cM^(e-1)*c^(1-e)*(1-theta)*(yM/hM) 
= (1-alpha)*cH^(e-1)*c^(1-e)*(1-eta)*(yH/hH);

// 12. Consumption vs Leisure Condition
A/leisure = (1/(2*c)) * (alpha*cM^(e-1)*c^(1-e)*(1-theta)*(yM/hM) + (1-alpha)*cH^(e-1)*c^(1-e)*(1-eta)*(yH/hH));

// --- Definiciones para compatibilidad con scripts de Julia ---
productivity = yM / hM;
y = yM;
h = hM;
end;

// -------------------------------------------------------------------------
// 4. Steady State Calculation
// -------------------------------------------------------------------------
hM_ss = 0.33; 
hH_ss = 0.28;
ratio_yM_kM = (1/beta - (1-delta))/theta; 
kM = (ratio_yM_kM / hM_ss^(1-theta))^(1/(theta-1)); 
k_ss = kM/phi;                                    
kH = (1-phi)*k_ss;                                 
i_ss = delta*k_ss;                                 

// -------------------------------------------------------------------------
// 5. Initialization
// -------------------------------------------------------------------------
initval;
zM = 0; // In log-level, the SS is 0
zH = 0;
hM = hM_ss;
hH = hH_ss;
leisure = 1 - hM - hH; 
k = k_ss;                                         
invest = i_ss;                                         
yM = kM^theta * hM^(1-theta);                 
cM = yM - invest;                                  
yH = kH^eta * hH^(1-eta);                     
cH = yH;                                      
c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);
y = yM;
h = hM;      
end;

// -------------------------------------------------------------------------
// 6. Shocks and Simulation
// -------------------------------------------------------------------------
shocks;
var eM = 0.007^2;
var eH = 0.007^2;
end;

steady; 
check; // Useful command to check eigenvalues

stoch_simul(order=1, irf=20) c k zM zH yM yH;