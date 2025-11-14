// 1. Variable Declaration
var y c k i h a;      
varexo e;             

// 2. Parameter Declaration
// CHANGED: Renamed sigma_e to sigma_eps
parameters beta delta alpha rho sigma_eps gamma;

// 3. Calibration
beta = 0.99;
delta = 0.025;
alpha = 0.36;
rho = 0.95;           
sigma_eps = 0.007;   // CHANGED: Renamed here
gamma = 2.0;          

// 4. The Model Block
model;
    // 1. Euler Equation
    (1/c) = beta * (1/c(+1)) * (alpha * exp(a(+1)) * k^(alpha-1) * h(+1)^(1-alpha) + (1-delta));
    
    // 2. Intratemporal Labor Supply
    (gamma / (1-h)) / (1/c) = (1-alpha) * exp(a) * k(-1)^alpha * h^(-alpha);

    // 3. Resource Constraint
    c + k - (1-delta)*k(-1) = exp(a) * k(-1)^alpha * h^(1-alpha);
    
    // 4. Production Function
    y = exp(a) * k(-1)^alpha * h^(1-alpha);
    
    // 5. Investment Definition
    i = y - c;

    // 6. Technology Shock Process
    a = rho * a(-1) + e;
end;

// 5. Steady State Calculation
initval;
    k = 10;
    c = 1;
    h = 0.3;
    a = 0;
end;

steady; 

// 6. Simulation
shocks;
    // CHANGED: Renamed here
    var e; stderr sigma_eps;
end;

stoch_simul(order=1, irf=40, hp_filter=1600) y c i h;