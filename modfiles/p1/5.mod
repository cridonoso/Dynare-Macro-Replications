// -------------------------------------------------------------------------
// 1. Declaración de Variables y Parámetros
// -------------------------------------------------------------------------
var c k i l hM hH cM cH yM yH zM zH, productivity; 
varexo eM eH; 

parameters beta delta theta eta rhoM rhoH e A alpha phi ratio_yM_kM kM kH; 

// -------------------------------------------------------------------------
// 2. Calibración
// -------------------------------------------------------------------------
beta  = 0.99;    
delta = 0.025;   
theta = 0.36;    
eta   = 0.08;    
rhoM  = 0.95;    
rhoH  = 0.95;    
e     = 0.8;     

// Parámetros calibrados en el SS
A     = 2.84;
alpha = 0.344;
phi   = 0.885;

// IMPORTANTE: Definimos k como predeterminada
// Esto le dice a Dynare que k_t es una variable de estado (viene de t-1)
predetermined_variables k;

// -------------------------------------------------------------------------
// 3. Ecuaciones del Modelo
// -------------------------------------------------------------------------
model;
// 1. Consumo Agregado 
c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);

// 2. Ocio 
l = 1 - hM - hH;

// 3. Producción de Mercado (k es predeterminado, así que k es el stock actual)
yM = exp(zM) * (phi*k)^(theta) * hM^(1-theta); 

// 4. Producción del Hogar 
yH = exp(zH) * ((1-phi)*k)^(eta) * hH^(1-eta); 

// 5. Balance de Recursos del Mercado 
cM + i = yM;

// 6. Balance de Recursos del Hogar 
cH = yH; 

// 7. Ecuación de Movimiento del Capital 
// Al ser k predeterminado:
// k es k_t (inicio del periodo)
// k(+1) es k_{t+1} (stock para el siguiente periodo)
k(+1) = (1-delta)*k + i;

// 8. Proceso Exógeno zM (CORREGIDO: Backward looking)
zM = rhoM*zM(-1) + eM;

// 9. Proceso Exógeno zH (CORREGIDO: Backward looking)
zH = rhoH*zH(-1) + eH;

// 10. Ecuación de Euler 
// Nota: Como k es predeterminado, k(+1) es el stock usado en t+1.
alpha*cM^(e-1)*c^(1-e)*(1/c) 
= beta * (alpha*cM(+1)^(e-1)*c(+1)^(1-e)*(1/c(+1))) * (theta*(yM(+1)/(phi*k(+1))) + (1-delta));

// 11. Condición Intratemporal Mercado vs Hogar 
alpha*cM^(e-1)*c^(1-e)*(1-theta)*(yM/hM) 
= (1-alpha)*cH^(e-1)*c^(1-e)*(1-eta)*(yH/hH);

// 12. Condición Consumo vs Ocio 
A/l = (1/(2*c)) * (alpha*cM^(e-1)*c^(1-e)*(1-theta)*(yM/hM) + (1-alpha)*cH^(e-1)*c^(1-e)*(1-eta)*(yH/hH));

productivity = yM / hM;
end;

// -------------------------------------------------------------------------
// 4. Cálculo de Steady State
// -------------------------------------------------------------------------
hM_ss = 0.33; 
hH_ss = 0.28;
ratio_yM_kM = (1/beta - (1-delta))/theta; 
kM = (ratio_yM_kM / hM_ss^(1-theta))^(1/(theta-1)); 
k_ss = kM/phi;                                    
kH = (1-phi)*k_ss;                                 
i_ss = delta*k_ss;                                 

// -------------------------------------------------------------------------
// 5. Inicialización
// -------------------------------------------------------------------------
initval;
zM = 0; // En log-level, el SS es 0
zH = 0;
hM = hM_ss;
hH = hH_ss;
l = 1 - hM - hH; 
k = k_ss;                                         
i = i_ss;                                         
yM = kM^theta * hM^(1-theta);                 
cM = yM - i;                                  
yH = kH^eta * hH^(1-eta);                     
cH = yH;                                      
c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);      
end;

// -------------------------------------------------------------------------
// 6. Shocks y Simulación
// -------------------------------------------------------------------------
shocks;
var eM = 0.007^2;
var eH = 0.007^2;
end;

steady; 
check; // Comando útil para verificar valores propios (Eigenvalues)

// Ya no necesitamos qz_criterium ni solve_algo raros porque el modelo está bien especificado
stoch_simul(order=1, irf=20) c k zM zH yM yH;