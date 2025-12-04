# Política Monetaria: Reglas de Taylor y Bienestar (Galí, 2015)

Este directorio contiene la replicación computacional de los ejercicios de bienestar del Capítulo 4 de Galí (2015). El análisis compara el desempeño estabilizador de dos reglas de política monetaria (Contemporánea vs. Forward-Looking) bajo distintos escenarios de shocks exógenos.

## 📂 Estructura del Código

| Script | Descripción | Output |
| :--- | :--- | :--- |
| **`0_theoretical_moments.jl`** | Replica la **Tabla 4.1**. Utiliza los momentos asintóticos teóricos calculados directamente por Dynare (sin simulación) resolviendo la ecuación de Lyapunov del sistema. | `results/p3/2_theoretical/*.tex` |
| **`1_run_simulations.jl`** | Ejecuta simulaciones Monte Carlo (10,000 it.) para tres escenarios (Tecnológico, Demanda, Ambos). Aplica máscaras a la matriz de covarianza para aislar los shocks. | `results/p3/*/loss_dist_*.csv` |
| **`2_gen_reports.jl`** | Procesa los CSV generados, crea histogramas comparativos de pérdida de bienestar y genera la tabla resumen con las medias de las distribuciones. | `results/p3/6_summary/*.pdf`<br>`results/p3/6_summary/*.tex` |

## ⚙️ Especificación de Modelos (`modfiles/p3/`)

Se utilizan dos variantes del modelo Neokeynesiano básico log-linealizado:

1.  **Regla Contemporánea (`gali_current.mod`):**
    * La autoridad monetaria responde a la inflación y brecha de producto actuales.
    * Regla: $i_t = \rho + \phi_\pi \pi_t + \phi_y \tilde{y}_t$

2.  **Regla Forward-Looking (`gali_forward.mod`):**
    * La autoridad responde a las expectativas de inflación futura.
    * Regla: $i_t = \rho + \phi_\pi \mathbb{E}_t[\pi_{t+1}] + \phi_y \tilde{y}_t$

La **Pérdida de Bienestar ($L$)** se calcula como una suma ponderada de las varianzas de la inflación y la brecha del producto, utilizando pesos derivados micro-fundamentados en los parámetros estructurales ($\sigma, \varphi, \epsilon, \theta$).

---

## 🚀 Instrucciones de Ejecución

Para reproducir los resultados completos, ejecute los scripts en el siguiente orden estricto desde la consola de Julia (REPL):

```julia
# 1. Generar Tabla de Momentos Teóricos (Tabla 4.1)
include("presentation/p3/0_theoretical_moments.jl")

# 2. Ejecutar Simulaciones Monte Carlo (Generación de datos)
include("presentation/p3/1_run_simulations.jl")

# 3. Generar Reportes y Gráficos (Histogramas y Tablas)
include("presentation/p3/2_gen_reports.jl")
```