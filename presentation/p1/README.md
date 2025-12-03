# Replicación RBC: Trabajo Indivisible (Hansen, 1985)

Este directorio contiene la implementación computacional para replicar y extender el modelo de **Trabajo Indivisible** propuesto por Gary Hansen (1985). El análisis compara cinco especificaciones distintas del modelo de Ciclos Económicos Reales (RBC) para evaluar el impacto de distintas fricciones (trabajo indivisible, ocio no separable, producción doméstica y gobierno) sobre la volatilidad macroeconómica.

## 📂 Estructura del Código

El flujo de trabajo se controla mediante scripts secuenciales ubicados en esta carpeta:

| Script | Descripción | Output |
| :--- | :--- | :--- |
| **`0_run_analysis.jl`** | **Motor Principal.** Resuelve los 5 modelos en Dynare, simula una muestra única y ejecuta Monte Carlo (10,000 it.). | `results/p1/*/item4_*.csv`<br>`results/p1/*/item5_*.csv` |
| **`1_gen_table.jl`** | Consolida los resultados de Monte Carlo y genera la tabla comparativa en formato LaTeX. | `results/p1/comparison_p1.tex` |
| **`2_plot_histograms.jl`** | Genera gráficos de densidad (Kernel) comparando las distribuciones de los estadísticos entre modelos. | `results/p1/hist_*.pdf` |
| **`4_scatter.jl`** | Genera el gráfico de dispersión 1x5 mostrando la correlación entre Horas y Productividad (Ciclo HP). | `results/p1/scatter_sim_*.pdf` |

## ⚙️ Especificación de Modelos (`modfiles/p1/`)

El análisis itera sobre cinco variantes estructurales:

1.  **Modelo 1 (RBC Básico):** Utilidad logarítmica y trabajo perfectamente divisible.
2.  **Modelo 2 (Ocio No Separable):** Introducción de persistencia en la oferta laboral (Kydland & Prescott).
3.  **Modelo 3 (Trabajo Indivisible):** Modelo de Hansen con loterías de empleo y utilidad lineal en horas.
4.  **Modelo 4 (Gobierno):** Inclusión de shocks de gasto público exógeno.
5.  **Modelo 5 (Producción Doméstica):** Modelo de dos sectores (Mercado y Hogar) según Benhabib et al.

---

## 🚀 Instrucciones de Ejecución

Para reproducir los resultados completos, ejecute los scripts en el siguiente orden estricto desde la consola de Julia:

```julia
# 1. Simulación Intensiva (Resolver modelos y generar datos)
include("presentation/p1/0_run_analysis.jl")

# 2. Generación de Reportes (Tabla LaTeX)
include("presentation/p1/1_gen_table.jl")

# 3. Visualización (Gráficos)
include("presentation/p1/4_scatter.jl")
include("presentation/p1/2_plot_histograms.jl")
```