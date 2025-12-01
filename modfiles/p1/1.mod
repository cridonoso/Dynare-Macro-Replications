/* Basic RBC Model */

// 1. Variable and Parameter Declaration
var y $y$ (long_name='output')
    c $c$ (long_name='consumption')
    k $k$ (long_name='capital stock')
    invest $i$ (long_name='investment')
    h $h$ (long_name='hours')
    lambda $\lambda$ (long_name='TFP')
    productivity ${\frac{y}{h}}$ (long_name='Productivity');

varexo eps_a;

parameters beta $\beta$ (long_name='discount factor')
    delta $\delta$ (long_name='depreciation rate')
    theta $\theta$ (long_name='capital share')
    rho $\rho$ (long_name='AR coefficient TFP')
    sigma_eps $\sigma_e$ (long_name='TFP shock volatility')
    gamma $\gamma$ (long_name='labor disutility parameter');

// 3. Calibration
beta = 0.99;
delta = 0.025;
theta = 0.36;
rho = 0.95;
sigma_eps = 0.00712;
gamma = 2.0;

// 4. The Model Block
model;
    // 1. Euler Equation
    1/c = beta * (1/c(+1)) * (theta * y(+1)/k + (1-delta));

    // 2. Intratemporal Labor Supply
    gamma / (1-h) = (1/c) * (1-theta) * y / h;

    // 3. Resource Constraint
    c + invest = y;

    // 4. Production Function
    y = lambda * k(-1)^theta * h^(1-theta);

    // 5. Investment Definition
    k = (1-delta)*k(-1) + invest;

    // 6. Technology Shock Process
    log(lambda) = rho * log(lambda(-1)) + eps_a;

    // 7. Productivity
    productivity = y / h;
end;

// 5. Steady State Calculation
steady_state_model;
    lambda = 1;
    h = 1/3;
    k_y_ratio = theta / (1/beta - (1-delta));
    y = (k_y_ratio)^(theta/(1-theta))*h;
    k = k_y_ratio * y;
    invest = delta*k;
    c = y - invest;
    productivity = y/h;
    gamma = (1-theta)*(y/h)/c * (1-h);
end;

steady;
check;

// 6. Simulation
shocks;
    var eps_a; stderr sigma_eps;
end;

stoch_simul(order=1, irf=20, loglinear, hp_filter=1600, periods=200) y c invest k h productivity;