/* * Modelo 5: RBC con Producción Doméstica (Home Production)
 * Modelo de dos sectores: Mercado (M) y Hogar (H).
 */

// --- 1. Variables y Parámetros ---
var c k kM kH invest leisure hM hH cM cH yM yH zM zH g productivity y h;
varexo eM eH eG; 

parameters beta delta theta eta rhoM rhoH rhoG e A alpha;

// --- 2. Calibración ---
beta  = 0.99;    
delta = 0.025;   
theta = 0.36;    // Participación capital (Mercado)
eta   = 0.08;    // Participación capital (Hogar)
rhoM  = 0.95;    // Persistencia TFP Mercado
rhoH  = 0.95;    // Persistencia TFP Hogar
rhoG  = 0.95; 
e     = 0.8;     // Parámetro de elasticidad de sustitución

// A y alpha se calculan en el bloque de estado estacionario

// --- 3. Dinámica del Modelo ---
predetermined_variables k;

model;
    // --- Sector Hogares ---
    // Agregador de Consumo (CES)
    c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);
    
    // Definición de Ocio
    leisure = 1 - hM - hH;

    // Ecuación de Euler (Intertemporal)
    (alpha*cM^(e-1)*c^(1-e) / c) = 
        beta * (alpha*cM(+1)^(e-1)*c(+1)^(1-e) / c(+1)) * (theta*(yM(+1)/kM(+1)) + (1-delta));

    // Arbitraje Laboral (Intratemporal Mercado vs Hogar)
    (1-theta)*(yM/hM) * (alpha*cM^(e-1)*c^(1-e)) = 
        (1-eta)*(yH/hH) * ((1-alpha)*cH^(e-1)*c^(1-e));

    // Oferta Laboral (Ocio vs Consumo)
    A/leisure = (1/c) * alpha*cM^(e-1)*c^(1-e) * (1-theta)*(yM/hM);
    
    // Arbitraje de Capital (Mercado vs Hogar)
    theta*(yM/kM) * (alpha*cM^(e-1)*c^(1-e)) = 
        eta*(yH/kH) * ((1-alpha)*cH^(e-1)*c^(1-e));

    // --- Sector Producción ---
    yM = exp(zM) * kM^(theta) * hM^(1-theta); // Producción de Mercado
    yH = exp(zH) * kH^(eta) * hH^(1-eta);     // Producción Doméstica

    // --- Agregación y Recursos ---
    cM + invest + g = yM;       // Restricción Mercado
    cH = yH;                    // Restricción Hogar
    k(+1) = (1-delta)*k + invest; // Acumulación Capital Agregado
    kM + kH = k;                // Asignación de Capital
    
    // --- Procesos Exógenos ---
    zM = rhoM*zM(-1) + eM;
    zH = rhoH*zH(-1) + eH;
    log(g) = (1-rhoG)*log(0.2*yM) + rhoG*log(g(-1)) + eG;

    // Definiciones Auxiliares
    productivity = yM / hM;
    y = yM;
    h = hM;
end;

// --- 4. Estado Estacionario ---
steady_state_model;
    // Objetivos (Targets)
    hM = 0.33;
    hH = 0.28;
    leisure = 1 - hM - hH;
    zM = 0;
    zH = 0;
    
    // 1. Sector Mercado (Lógica estándar RBC)
    MPK_M = 1/beta - (1-delta);
    yM_kM_ratio = MPK_M / theta;
    kM = hM * (yM_kM_ratio)^(1/(theta-1));
    yM = kM^theta * hM^(1-theta);
    
    // 2. Sector Hogar (Condición de eficiencia)
    kH = kM * (hH/hM) * ((1-theta)/theta) * (eta/(1-eta));
    yH = kH^eta * hH^(1-eta);
    cH = yH;
    
    // 3. Agregados
    k = kM + kH;
    invest = delta * k;
    g = 0.2 * yM;
    cM = yM - invest - g;
    
    // 4. Preferencias (Ingeniería inversa para Alpha y A)
    MPL_M = (1-theta)*(yM/hM);
    MPL_H = (1-eta)*(yH/hH);
    
    term1 = MPL_M * cM^(e-1);
    term2 = MPL_H * cH^(e-1);
    alpha = term2 / (term1 + term2);
    
    c = (alpha*cM^e + (1-alpha)*cH^e)^(1/e);
    RHS = (1/c) * alpha*cM^(e-1)*c^(1-e) * MPL_M;
    A = RHS * leisure;
    
    // Auxiliares finales
    productivity = yM / hM;
    y = yM;
    h = hM;
end;

steady;
check;

// --- 5. Shocks y Simulación ---
shocks;
    var eM = 0.007^2;
    var eH = 0.007^2;
    var eM, eH = 0.6666 * 0.007 * 0.007; // Correlación entre sectores
    var eG = 0; 
end;

stoch_simul(nograph, order=1, irf=20, hp_filter=1600) y c invest h productivity;