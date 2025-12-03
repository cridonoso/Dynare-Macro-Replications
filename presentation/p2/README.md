# Replicación RBC: Estimación GMM (Christiano & Eichenbaum, 1992)

Este directorio contiene la implementación computacional para replicar los resultados del modelo de **Trabajo Divisible sin Gobierno** ($\alpha=1$) presentado por Christiano & Eichenbaum (1992). El proyecto incluye la descarga automática de datos, procesamiento de series de tiempo y estimación de parámetros estructurales mediante el Método Generalizado de Momentos (GMM).

## 📂 Estructura del Código

| Script | Descripción | Output |
| :--- | :--- | :--- |
| **`0_get_data.jl`** | Descarga datos de FRED, filtra la muestra (1955-1983), transforma a términos per cápita y aplica re-escalamiento monetario. | `data/data_usa.csv`<br>`data/data_gmm.csv` |
| **`1_estimate.jl`** | Ejecuta la estimación GMM, resuelve el estado estacionario, simula el modelo dinámico y compara momentos teóricos vs. datos. | `results/p2/*.tex`<br>`results/p2/*.pdf` |

## ⚙️ Metodología y Procesamiento

### 1. Tratamiento de Datos
Se aplica un **re-escalamiento monetario** crítico para alinear las unidades de los datos (Billones USD) con la dotación de tiempo teórica del modelo ($N=1369$).
* **Objetivo:** Asegurar que $\bar{g}_{data} \approx 186.0$ (valor calibrado por los autores).
* **Transformación:** $X_{adj} = X_{raw} \times \phi$, donde $\phi = 186.0 / \mathbb{E}[G_{raw}]$.

### 2. Estimación GMM
Los parámetros se recuperan utilizando las condiciones de primer orden (FOCs) evaluadas en los datos:
* **$\lambda$ (Crecimiento):** Media de la tasa de crecimiento del producto.
* **$\gamma$ (Ocio):** Despejado de la condición intratemporal de oferta laboral.
* **$\rho_g$ (Gobierno):** Estimación AR(1) del proceso de gasto público (aunque el modelo final asume sin gobierno, el parámetro se calcula para calibración).

### 3. Dinámica (Dynare)
El modelo resuelto es un sistema RBC estándar con:
* Función de producción Cobb-Douglas con shock tecnológico.
* Restricción de recursos.
* Ecuaciones de Euler para capital y trabajo.

---

## 🚀 Instrucciones de Ejecución

Para reproducir los resultados completos, ejecute los scripts en el siguiente orden estricto desde la consola de Julia:

```julia
# 1. Obtención y Procesamiento de Datos
include("presentation/p2/0_get_data.jl")

# 2. Estimación y Simulación
include("presentation/p2/1_estimate.jl")
```