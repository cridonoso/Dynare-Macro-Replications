# Problema 1: Ciclos Económicos Reales (RBC) - Replicación de Hansen (1985)

Este directorio contiene la secuencia de scripts para resolver, simular y comparar cinco variantes del modelo RBC, contrastando la economía de trabajo divisible estándar con la economía de trabajo indivisible de Hansen.

## 📋 Tabla Resumen de Ejecución

| Orden | Script | Función Teórica / Computacional | Salida Principal |
| :--- | :--- | :--- | :--- |
| **1** | `0_run_analysis.jl` | **Resolución y Monte Carlo:** Resuelve el sistema de ecuaciones (Dynare) y simula 10,000 trayectorias para obtener momentos robustos. Genera también una simulación de muestra única. | `results/p1/{id}/*.csv` |
| **2** | `1_gen_table.jl` | **Tabla Comparativa:** Calcula desviaciones estándar relativas y correlaciones promediadas de Monte Carlo, generando el código LaTeX final. | `results/p1/comparison_p1.tex` |
| **3** | `2_plot_histograms.jl` | **Distribuciones (Densidad):** Grafica las densidades Kernel de los momentos simulados para comparar visualmente la volatilidad entre modelos. | `results/p1/densities_comparison_*.pdf` |
| **4** | `3_plot_simulation.jl` | **Dinámica Temporal:** Genera gráficos de series de tiempo para una simulación única (200 periodos), permitiendo inspeccionar la persistencia y volatilidad de las variables en niveles. | `results/p1/{id}/plots/*.pdf` |
| **5** | `4_scatter.jl` | **Mercado Laboral:** Analiza la relación Horas vs. Productividad (Filtro HP) para evaluar el ajuste del modelo a la "cuña" observada en datos. | `results/p1/scatter_sim_*.pdf` |

## 🧠 Conexión con la Teoría

### Mapeo de Modelos (`modfiles/p1/`)
El análisis itera sobre variantes estructurales para aislar mecanismos de transmisión:
* **Modelo 1:** RBC Estándar (Trabajo Divisible).
* **Modelo 2:** Ocio No Separable (Kydland & Prescott).
* **Modelo 3:** Trabajo Indivisible (Hansen) - Loterías de empleo.
* **Modelo 4:** Gobierno (Gasto exógeno).
* **Modelo 5:** Producción Doméstica.

### Visualización (`3_plot_simulation.jl`)
Este script es clave para la intuición económica, ya que permite ver:
* La **correlación positiva** entre consumo, inversión y producto.
* La **suavización del consumo** (menor volatilidad que el producto).
* La alta volatilidad de la inversión.

## 🚀 Instrucciones de Ejecución

Para reproducir todo el análisis, ejecuta los scripts en orden desde el REPL de Julia:

```julia
# 1. Resolver modelos y generar datos (Monte Carlo + Simulación Única)
include("presentation/p1/0_run_analysis.jl")

# 2. Generar Tabla LaTeX de Momentos
include("presentation/p1/1_gen_table.jl")

# 3. Generar Gráficos de Distribución (Histogramas)
include("presentation/p1/2_plot_histograms.jl")

# 4. Generar Gráficos de Series de Tiempo (Por defecto Modelo 1)
# Nota: Para otros modelos, modificar la variable `target_model` o pasar argumentos por terminal.
include("presentation/p1/3_plot_simulation.jl")

# 5. Generar Scatter Plots (Horas vs Productividad)
include("presentation/p1/4_scatter.jl")
```