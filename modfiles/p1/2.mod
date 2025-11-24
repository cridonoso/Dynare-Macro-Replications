/* Modelo RBC Non separable leisure*/

var c $c$ (long_name='consumption')
    y $y$ (long_name='output')
    h $h$ (long_name='hours')
    k $k$ (long_name='capital stock')
    invest $i$ (long_name='investment')
    lambda $\lambda$ (long_name='TFP')
    productivity ${\frac{y}{h}}$ (long_name='Productivity')
    L $L$ (long_name='ocio')
    X $X$ (long_name='stock de ocio')
    mu $\mu$ (long_name='lagrange multiplier');

varexo eps_a;

parameters beta $\beta$ (long_name='discount factor')
    delta $\delta$ (long_name='depreciation rate')
    theta $\theta$ (long_name='capital share')
    rho $\rho$ (long_name='AR coefficient TFP')
    A $A$ (long_name='labor disutility parameter')
    h_0 ${h_0}$ (long_name='full time workers in steady state')
    sigma_eps $\sigma_e$ (long_name='TFP shock volatility')
    eta $\eta$ (long_name='depreciación del ocio')
    a_0 $a_0$ (long_name='peso del ocio actual')
    ;

//Calibration, p. 319
beta = 0.99;
delta = 0.025;
theta = 0.36;
rho = 0.95;
A = 2;
sigma_eps=0.00712;
h_0=0.53;
a_0=0.35;
eta=0.10;

model;
//1. Euler Equation
1/c = beta*((1/c(+1))*(theta*(y(+1)/k) +(1-delta)));
//2. Labor FOC
(1/c)*(1-theta)*(y/h) = ((A*a_0)/L) + mu;
//3. Euler Equiation (Ocio)
mu = beta*((A*eta*(1-a_0))/L(+1) + mu(+1)*(1-eta));
//4.  Servicio de Ocio
L = a_0*(1-h) + eta*(1-a_0)*X(-1);
//5. Ley de movimiento del stock de Ocio
X = (1-eta)*X(-1) + (1-h);
//6. Resource constraint
c = y +(1-delta)*k(-1) - k;
//7. LOM capital
k= (1-delta)*k(-1) + invest;
//8. Production function
y = lambda*k(-1)^(theta)*h^(1-theta);
//9. LOM TFP
log(lambda) = rho*log(lambda(-1)) + eps_a;
//9. Productivity
productivity= y/h;
end;

steady_state_model;
lambda = 1;
h = 1/3;
X = (1-h)/eta;
L = 1-h;
k_y_ratio = theta / (1/beta - (1-delta));
y = (k_y_ratio)^(theta/(1-theta))*h;
k = k_y_ratio * y;
invest = delta*k;
c = y - invest;
productivity = y/h;
term_labor_benefit = (1-theta)*(y/h)/c;
denom_A = a_0 + (beta*eta*(1-a_0))/(1-beta*(1-eta));
A = term_labor_benefit*(1-h)/denom_A;
mu = (beta*A*eta*(1-a_0)) / ( (1-h)*(1-beta*(1-eta)) );
end;

steady;

shocks;
var eps_a; stderr sigma_eps;
end;

check;
steady;
stoch_simul(order=1,irf=20,loglinear,hp_filter=1600,periods=200) y c invest k h productivity;