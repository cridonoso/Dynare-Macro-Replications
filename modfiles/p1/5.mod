/* Model with Market and Home Production (Hansen & Wright 1992) - ROBUST VERSION */

// 1. Variable and Parameter Declaration
var c $c$ (long_name='aggregate consumption')
    k $k$ (long_name='aggregate capital stock')
    kM $k_M$ (long_name='market capital stock')
    kH $k_H$ (long_name='home capital stock')
    invest $i$ (long_name='investment')
    leisure $l$ (long_name='leisure')
    hM $h_M$ (long_name='market hours')
    hH $h_H$ (long_name='home hours')
    cM $c_M$ (long_name='market consumption')
    cH $c_H$ (long_name='home consumption')
    yM $y_M$ (long_name='market output')
    yH $y_H$ (long_name='home output')
    zM $z_M$ (long_name='market TFP shock')
    zH $z_H$ (long_name='home TFP shock')
    g  $g$ (long_name='government spending')
    // Auxiliary
    productivity (long_name='market productivity')
    y (long_name='aggregate output alias')
    h (long_name='market hours alias');

varexo eM eH eG; 

parameters beta delta theta eta rhoM rhoH rhoG e A alpha;

// 2. Calibration
beta  = 0.99;    
delta = 0.025;   
theta = 0.36;    
eta   = 0.08;    
rhoM  = 0.95;    
rhoH  = 0.95;
rhoG  = 0.95; 
e     = 0.8;     

// A and alpha are calculated in steady state

// 3. Model Equations
predetermined_variables k;

model;
    // 1. Aggregate Consumption
    c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);

    // 2. Leisure
    leisure = 1 - hM - hH;

    // 3. Market Production
    yM = exp(zM) * kM^(theta) * hM^(1-theta);

    // 4. Home Production
    yH = exp(zH) * kH^(eta) * hH^(1-eta);

    // 5. Market Resource Constraint
    cM + invest + g = yM;

    // 6. Home Resource Constraint
    cH = yH;

    // 7. Aggregate Capital Accumulation
    k(+1) = (1-delta)*k + invest;

    // 8. Capital Allocation
    kM + kH = k;

    // 9. Exogenous Processes
    zM = rhoM*zM(-1) + eM;
    zH = rhoH*zH(-1) + eH;
    log(g) = (1-rhoG)*log(0.2*yM) + rhoG*log(g(-1)) + eG;

    // --- FOCs ---

    // 10. Euler Equation
    (alpha*cM^(e-1)*c^(1-e) / c) = 
        beta * (alpha*cM(+1)^(e-1)*c(+1)^(1-e) / c(+1)) * (theta*(yM(+1)/kM(+1)) + (1-delta));

    // 11. Labor Arbitrage
    (1-theta)*(yM/hM) * (alpha*cM^(e-1)*c^(1-e)) = 
    (1-eta)*(yH/hH)   * ((1-alpha)*cH^(e-1)*c^(1-e));

    // 12. Labor Supply
    A/leisure = (1/c) * alpha*cM^(e-1)*c^(1-e) * (1-theta)*(yM/hM);

    // 13. Capital Arbitrage
    theta*(yM/kM) * (alpha*cM^(e-1)*c^(1-e)) = 
    eta*(yH/kH)   * ((1-alpha)*cH^(e-1)*c^(1-e));

    // Definitions
    productivity = yM / hM;
    y = yM;
    h = hM;
end;

// 4. Steady State Calculation - EXACT ANALYTICAL SOLUTION
steady_state_model;
    // Targets
    hM = 0.33;
    hH = 0.28;
    leisure = 1 - hM - hH;
    
    // 1. Solve Market Capital (Standard RBC logic)
    // MPK = r + delta = 1/beta - 1 + delta
    MPK_M = 1/beta - (1-delta);
    // MPK = theta * yM/kM  => yM/kM ratio is fixed
    yM_kM_ratio = MPK_M / theta;
    // kM from production function inversion
    kM = hM * (yM_kM_ratio)^(1/(theta-1));
    yM = kM^theta * hM^(1-theta);
    
    // 2. Solve Home Capital using Allocative Efficiency Condition
    // Dividing Labor FOC by Capital FOC implies:
    // (1-theta)/theta * kM/hM = (1-eta)/eta * kH/hH
    // This gives us kH exactly without needing alpha or cM yet.
    kH = kM * (hH/hM) * ((1-theta)/theta) * (eta/(1-eta));
    
    // 3. Calculate Home Output/Consumption
    yH = kH^eta * hH^(1-eta);
    cH = yH;
    
    // 4. Calculate Market Consumption (Resource Constraint)
    k = kM + kH;
    invest = delta * k;
    g = 0.2 * yM;
    cM = yM - invest - g; // Residual to ensure consistency
    
    // 5. Reverse Engineer Preferences (Alpha & A)
    // Solve Alpha from Labor Arbitrage FOC
    MPL_M = (1-theta)*(yM/hM);
    MPL_H = (1-eta)*(yH/hH);
    // equation: MPL_M * alpha * cM^(e-1) = MPL_H * (1-alpha) * cH^(e-1)
    // Let T1 = MPL_M * cM^(e-1) and T2 = MPL_H * cH^(e-1)
    // alpha * T1 = (1-alpha) * T2  => alpha(T1+T2) = T2
    term1 = MPL_M * cM^(e-1);
    term2 = MPL_H * cH^(e-1);
    alpha = term2 / (term1 + term2);
    
    // Solve A from Labor Supply FOC
    c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);
    // A = U_c * MPL_M * leisure
    // U_c = c^(1-e-1) * alpha * cM^(e-1) * c^(e-1) ... wait, U(c) = log(c).
    // Let's use the FOC equation directly:
    // A/leisure = (1/c) * alpha * cM^(e-1) * c^(1-e) * MPL_M
    // Note: c^(1-e)/c = c^(-e) inside? No, 1/c * c^(1-e) = c^(-e).
    // Let's stick to the equation in the model block:
    // LHS: A/leisure. RHS: Marginal Utility of Consumption * Marginal Utility of cM * MPL_M
    // MU_Aggregate_C = 1/c
    // dC_dcM = alpha * cM^(e-1) * c^(1-e)
    RHS = (1/c) * alpha*cM^(e-1)*c^(1-e) * MPL_M;
    A = RHS * leisure;

    // Init Exogenous
    zM = 0;
    zH = 0;
    productivity = yM / hM;
    y = yM;
    h = hM;
end;

// 5. Shocks and Simulation
shocks;
    var eM = 0.007^2;
    var eH = 0.007^2;
    // Correlation 2/3
    var eM, eH = 0.6666 * 0.007 * 0.007; 
    
    // Set govt shock to 0 for pure Home Prod model analysis
    var eG = 0; 
end;

steady;
check;

stoch_simul(order=1, irf=20, hp_filter=1600) y c invest h productivity;