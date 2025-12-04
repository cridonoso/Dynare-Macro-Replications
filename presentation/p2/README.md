# Replicación RBC: Estimación GMM (Christiano & Eichenbaum, 1992)

Este directorio contiene la implementación computacional para replicar los resultados del modelo de **Trabajo Divisible sin Gobierno** ($\alpha=1$) presentado por Christiano & Eichenbaum (1992). El proyecto incluye la descarga automática de datos, procesamiento de series de tiempo y estimación de parámetros estructurales mediante el Método Generalizado de Momentos (GMM).

## 📂 Estructura del Código

| Script | Descripción | Output |
| :--- | :--- | :--- |
| **`0_get_data.jl`** | Descarga datos de FRED y los transforma a términos per cápita. Permite seleccionar entre muestra extendida (1955-2023) o replicación exacta (1955-1984). | `data/data_usa.csv`<br>`data/data_gmm.csv` |
| **`1_estimate.jl`** | Aplica el re-escalamiento monetario, ejecuta la estimación GMM, resuelve el estado estacionario y genera las tablas comparativas. | `results/p2/tablas_finales.tex` |

## ⚙️ Metodología y Procesamiento

### 1. Tratamiento de Datos
El script de estimación aplica un **re-escalamiento monetario** crítico para alinear las unidades de los datos (Billones USD) con la dotación de tiempo teórica del modelo ($N=1369$).
* **Objetivo:** Asegurar que $\bar{g}_{data} \approx 186.0$ (valor calibrado por los autores).
* **Transformación:** $X_{adj} = X_{raw} \times \phi$, donde $\phi = 186.0 / \mathbb{E}[G_{raw}]$.

### 2. Estimación GMM
Los parámetros se recuperan utilizando las condiciones de primer orden (FOCs) evaluadas en los datos:
* **$\lambda$ (Crecimiento):** Media de la tasa de crecimiento del producto.
* **$\gamma$ (Ocio):** Despejado de la condición intratemporal de oferta laboral (ecuación que iguala la relación marginal de sustitución al salario real).
* **$\rho_g$ (Gobierno):** Estimación AR(1) del proceso de gasto público (utilizado para la calibración del estado estacionario).

### 3. Dinámica (Dynare)
El modelo resuelto (`rbc_divlabor.mod`) es un sistema RBC estándar que incluye:
* Función de producción Cobb-Douglas con shock tecnológico estocástico.
* Restricción de recursos de la economía.
* Ecuaciones de Euler intertemporales para capital y oferta laboral.

---

## 🚀 Instrucciones de Ejecución

Para reproducir los resultados completos, ejecute los scripts en el siguiente orden desde la consola de Julia (REPL):

```julia
# 1. Obtención y Procesamiento de Datos
# Nota: Usa argumentos de línea de comando si deseas replicar el paper (e.g., `julia 0_get_data.jl --paper`)
include("presentation/p2/0_get_data.jl")

# 2. Estimación y Simulación
include("presentation/p2/1_estimate.jl")
```