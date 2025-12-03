# Documentación del Código: Replicación RBC (Christiano & Eichenbaum, 1992)

Este directorio contiene la implementación computacional para replicar los resultados del modelo de **Trabajo Divisible sin Gobierno** ($\alpha=1$) presentado por Christiano & Eichenbaum (1992). El flujo de trabajo se controla principalmente desde el script `1_estimate.jl` y utiliza el módulo auxiliar `ReplicationTools` definido en `utils.jl` ademas de `0_get_data.jl` para descargar y generar la base de datos.


## 1. Obtención y Procesamiento de Datos (`0_get_data.jl`)

Este script es el punto de partida del flujo de trabajo. Su función es descargar, consolidar y transformar las series de tiempo macroeconómicas necesarias para la estimación del modelo.

### Fuentes de Datos
El script combina datos de dos fuentes principales:
1.  **FRED (Federal Reserve Economic Data):** Se descargan automáticamente las series trimestrales para Producto (`GDPC1`), Inversión (`GPDIC1`), Consumo (`PCECC96`), Horas Trabajadas (`HOANBS`), Población (`CNP16OV`) y Tasa de Interés (`FEDFUNDS`).
2.  **Datos Locales:** Se carga la serie de Gasto de Gobierno (`A955RX1Q020SBEA`) desde un archivo CSV local, ya que requiere un tratamiento específico ([Link](https://fred.stlouisfed.org/series/A955RX1Q020SBEA)).

### Pipeline de Procesamiento
Una vez unidos los datos brutos, se aplica el siguiente *pipeline* de transformaciones secuenciales:

1.  **Filtro Temporal:** Se recorta la muestra al periodo de interés (1955:Q3 - 1983:Q4) para ser consistente con el estudio original.
2.  **Conversión Per Cápita:** Todas las variables de nivel (Producto, Consumo, Inversión, Gasto, Horas) se dividen por la población civil no institucional ($N_t$).
3.  **Construcción de Observables:**
    * **Crecimiento del Producto ($\Delta y_t$):** Se calcula como la diferencia logarítmica porcentual: $100 \times \Delta \ln(y_t)$.
    * **Horas ($h_t$):** Se calcula el logaritmo de las horas per cápita y se le resta su media muestral (detrending por media).
4.  **Re-escalamiento Monetario:** Se escalan las variables monetarias ($Y, C, G$) por un factor $\phi$ para alinear las unidades de los datos con la dotación de tiempo del modelo teórico ($N=1369$), asegurando que $\bar{g} \approx 186.0$.

### Salidas (Outputs)
El script genera dos archivos en la carpeta `data/`:
* `data_usa.csv`: Base de datos completa con encabezados, útil para inspección y gráficos.
* `data_gmm.csv`: Archivo sin encabezados que contiene solo las columnas necesarias ($y, c, g, n$) para la rutina de estimación GMM.


## 2. Procesamiento y Re-escalamiento de Datos

El tratamiento inicial de los datos se realiza en la carga de datos. Una transformación crítica es el **re-escalamiento monetario** para hacer consistentes las unidades de los datos (miles de millones de USD) con la dotación de tiempo del modelo ($N=1369$).

**Fundamento Teórico:**
Se busca un factor de escala $\phi$ tal que la media del gasto de gobierno en la muestra coincida con el valor calibrado por los autores en su Tabla 1 ($\bar{g} = 186.0$):
$$\phi = \frac{186.0}{\mathbb{E}[G_{raw}]}$$

**Implementación en Código (`1_estimate.jl`):**
Se calcula este escalar y se aplica a todas las variables monetarias ($Y, C, G$).

```julia
# 1. Calcular factor para que g_bar coincida con Lawrence (186)
TARGET_G = 186.0
scale_money = TARGET_G / mean(g_raw) 

# Aplicación del factor (Transformación de Niveles)
y_data = y_raw .* scale_money
c_data = c_raw .* scale_money
g_data = g_raw .* scale_money
```

---

## 3. Estimación de Parámetros (GMM)

La función `estimate_parameters` dentro del módulo `ReplicationTools` (en `utils.jl`) implementa el Método Generalizado de Momentos para recuperar los parámetros estructurales basándose en las condiciones de primer orden del modelo.

### A. Crecimiento Tecnológico ($\lambda$)
Se estima como la media de la tasa de crecimiento del producto.

* **Ecuación:** $\lambda = \mathbb{E}[\Delta \ln(y_t)]$
* **Código (`utils.jl`, función `estimate_parameters`):**
  ```julia
  dy = diff(log.(y_data))
  lambda_hat = mean(dy)
  ```

### B. Parámetro de Ocio ($\gamma$)
Se recupera despejando la condición intratemporal (oferta laboral) evaluada en los promedios muestrales.

* **Ecuación:** $\frac{\gamma c_t}{N - n_t} = (1-\theta) \frac{y_t}{n_t} \implies \gamma = (1-\theta) \frac{y_t}{n_t} \frac{N-n_t}{c_t}$
* **Código (`utils.jl`, función `estimate_parameters`):**
  ```julia
  vec_gamma = (1 - theta_val) .* (y_data ./ n_data_adj) .* (N_total .- n_data_adj) ./ c_data
  gamma_hat = mean(vec_gamma)
  ```

### C. Proceso del Gasto Público
Se estima un proceso AR(1) para el logaritmo del gasto público ($g_t$).

* **Ecuación:** $\ln(g_t) = (1-\rho)\ln(\bar{g}) + \rho \ln(g_{t-1}) + \mu_t$
* **Código (`utils.jl`, función `estimate_parameters`):**
  ```julia
  lg = log.(g_data)
  # Regresión OLS: Y_reg = const + rho * X_reg
  B_ols = X_reg \ Y_reg 
  rho_g_hat = B_ols[2]
  ```

---

## 4. Solución del Estado Estacionario

La función `solve_steady_state` (en `utils.jl`) resuelve numéricamente el sistema no lineal transformado (detrended) para encontrar el equilibrio de largo plazo.

### A. Ecuación de Euler (Ratio Capital-Producto)
El ratio de capital-producto se determina por la tasa de descuento y el crecimiento tecnológico bruto.

* **Ecuación:** $1 = \beta \mathbb{E}_t \left[ \left( \theta \frac{y}{k} + 1-\delta \right) e^{-\lambda} \right]$
* **Código (`utils.jl`, función `solve_steady_state`):**
  ```julia
  # Despeje de (K/Y) inverso
  ky_ratio_inv = (1/beta_val * exp_lam - (1-delta_val)) / theta_val
  ```

### B. Solución Numérica para el Trabajo ($n_{ss}$)
Se utiliza un *solver* iterativo para encontrar el $n$ que satisface simultáneamente la producción y la restricción de recursos.

* **Función Residual (`resid_n`):** Combina la restricción de recursos y la condición de optimalidad del trabajo.
  $$c_{val} = y - k(1 - (1-\delta)e^{-\lambda}) - g$$
  $$RHS = (1-\theta) \frac{y}{n} \frac{N-n}{\gamma}$$
* **Código (`utils.jl`, función `solve_steady_state`):**
  ```julia
  resid_n(n) = begin
      # ... (cálculo de k y y dado n) ...
      c_val = y - k*(1 - (1-delta_val)*exp(-lambda_hat)) - g_ss_hat
      rhs = (1-theta_val)*(y/n)*((N_total-n)/gamma_hat)
      return c_val - rhs
  end
  ```

---

## 5. Dinámica y Simulación (Dynare)

La dinámica del modelo se define en el archivo `rbc_divlabor.mod` y se ejecuta desde Julia mediante la función `run_simulation_and_moments` (en `utils.jl`).

### Sistema Dinámico
El bloque `model;` en Dynare contiene las ecuaciones log-linealizadas o no lineales exactas del sistema.

* **Producción:** $y_t = (k_{t-1} e^{-\lambda_t})^\theta n_t^{1-\theta}$
  * **Código (`rbc_divlabor.mod`):**
    ```dynare
    y = (k(-1)*exp(-lambda))^theta * n^(1-theta);
    ```
* **Restricción de Recursos:** $y_t = c_t + k_t - (1-\delta)k_{t-1}e^{-\lambda_t} + g_t$
  * **Código (`rbc_divlabor.mod`):**
    ```dynare
    y = c + k - (1-delta)*k(-1)*exp(-lambda) + g;
    ```

### Filtrado de Resultados
Los resultados de la simulación son procesados con el Filtro Hodrick-Prescott (HP) antes de calcular los momentos de segundo orden (volatilidades y correlaciones) para ser comparables con los datos.

* **Código (`utils.jl`, función `run_simulation_and_moments`):**
  ```julia
  cycle_y = hp_filter(log.(max.(vec_y, 1e-10)))
  # ... (aplicado a c, dk, n, etc.)
  ```

---
---
---
## Instrucciones de Ejecución

Para reproducir los resultados (tablas y gráficos) desde cero, siga estos pasos. No se requiere experiencia previa en programación, solo una instalación funcional de Julia.

### 1. Requisitos Previos
* Tener instalado **Julia** (versión 1.9 o superior). Puede descargarlo [aquí](https://julialang.org/downloads/).
* Tener la carpeta del proyecto descargada en su computadora.

### 2. Configuración del Entorno (Solo la primera vez)
Julia utiliza un sistema de entornos que garantiza que todos tengan las mismas versiones de las librerías. Para configurarlo:

1.  Abra una terminal (o consola de comandos) y navegue hasta la carpeta raíz del proyecto (`/Dynare-Macro-Replications`).
2.  Escriba `julia` y presione **Enter**. Esto abrirá la consola interactiva (REPL).
3.  Presione la tecla **`]`** para entrar al "modo de package" (el indicador cambiará a color azul y dirá `pkg>`).
4.  Escriba los siguientes comandos y presione Enter después de cada uno:
    ```julia
    activate .
    instantiate
    ```
    *(Esto descargará e instalará automáticamente todas las librerías necesarias como Dynare, DataFrames y CSV según lo definido en el archivo `Project.toml`)*.
5.  Presione la tecla **`Backspace`** (borrar) para salir del modo de paquetes y volver al modo normal `julia>`.

### 3. Generación de Resultados
Una vez configurado el entorno, ejecute los scripts en el siguiente orden copiando y pegando las líneas en la consola de Julia:

**Paso 1: Descargar y Procesar Datos**
Este script conecta con FRED, descarga las series, aplica el re-escalamiento y guarda los archivos base en `data/`.
```julia
include("presentation/p2/0_get_data.jl")
```

**Paso 2: Estimación y Simulación**
Este script lee los datos procesados, estima los parámetros estructurales, simula el modelo y genera el código LaTeX de las tablas.
```julia
include("presentation/p2/1_estimate.jl")
```

Al finalizar, los resultados (tablas y gráficos) estarán disponibles en la carpeta `results/p2/`.