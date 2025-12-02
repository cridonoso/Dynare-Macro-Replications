/* RBC Model with Government Spending */

// 1. Variable and Parameter Declaration
var c (long_name='consumption')
    invest (long_name='investment')
    y (long_name='output')
    k (long_name='capital stock')
    h (long_name='hours')
    z (long_name='TFP shock')
    g (long_name='government spending')
    productivity (long_name='labor productivity');

varexo e_z e_g;

parameters beta $\beta$ (long_name='discount factor')
    delta $\delta$ (long_name='depreciation rate')
    theta $\theta$ (long_name='capital share')
    rho $\rho$ (long_name='AR coefficient TFP')
    A $A$ (long_name='labor disutility parameter')
    lamg $\lambda_g$ (long_name='AR coefficient government spending')
    ghat $\bar{g}$ (long_name='steady state government spending');

// 2. Calibration
beta  = 0.99;
delta = 0.025;
theta = 0.36;
rho   = 0.95;
lamg  = 0.96;
ghat  = 0.271634;     // = 0.22 * y_ss (con y_ss≈1.2347)
A     = 2.4445;       // calibrated with h=1/3 and g/y=0.22

// 3. Ecuaciones del Modelo
model;
    // 1. Production function
    y = exp(z)*k(-1)^theta*h^(1-theta);
    // 2. Resource constraint
    c + invest + g = y;
    // 3. Law of motion for capital
    k = (1-delta)*k(-1) + invest;
    // 4. TFP process
    z = rho*z(-1) + e_z;
    // 5. Government spending process
    log(g) = (1-lamg)*log(ghat) + lamg*log(g(-1)) + e_g;
    // 6. Euler equation
    1/c = beta*(1/c(+1))*(theta*exp(z(+1))*k^(theta-1)*h(+1)^(1-theta) + 1 - delta);
    // 7. Labor supply
    A/(1-h) = (1/c) * (1-theta) * y / h;
    // 8. Definición de Productividad
    productivity = y / h;
end;

// 4. Steady State Calculation
steady_state_model;
    z = 0;
    g = ghat;
    h = 1/3;
    k_y_ratio = theta / (1/beta - (1-delta));
    y = (k_y_ratio)^(theta/(1-theta))*h;
    k = k_y_ratio * y;
    invest = delta*k;
    c = y - invest - g;
    A = (1-theta)*(y/h)/c * (1-h);
    productivity = y / h;
end;

steady;
check;

// 5. Shocks and Simulation
shocks;
    var e_z; stderr 0.00712; 
    var e_g; stderr 0.021;   
end;

stoch_simul(order=1, irf=0, noprint, nograph);