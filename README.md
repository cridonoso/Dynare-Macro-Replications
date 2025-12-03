# Tarea Computacional: Macroeconomía Dinámica

Este repositorio contiene la resolución y replicación computacional de tres problemas clásicos de macroeconomía dinámica, utilizando **Julia** y **Dynare**. El proyecto abarca desde modelos de Ciclos Económicos Reales (RBC) hasta estimación econométrica (GMM) y análisis de bienestar en modelos Neokeynesianos.

## 📚 Contenido del Repositorio

El trabajo se divide en tres módulos independientes. Haz clic en los enlaces para ver la documentación detallada y scripts de cada problema:

| Módulo | Descripción | Referencia Principal |
| :--- | :--- | :--- |
| [**Problema 1: RBC y Mercado Laboral**](./presentation/p1/README.md) | Comparación de 5 modelos RBC con fricciones (trabajo indivisible, ocio no separable, producción doméstica). | Hansen (1985) |
| [**Problema 2: Estimación GMM**](./presentation/p2/README.md) | Procesamiento de datos (FRED), estimación de parámetros estructurales vía GMM y validación del modelo. | Christiano & Eichenbaum (1992) |
| [**Problema 3: Política Monetaria**](./presentation/p3/README.md) | Análisis de bienestar comparando reglas de Taylor Contemporáneas vs. Forward-Looking. | Galí (2015), Cap. 4 |

---

## 🛠️ Requisitos e Instalación

Para ejecutar este código, necesitas tener instalado **Julia** (v1.9+) y configurar el entorno del proyecto.

### 1. Prerrequisitos
* **Julia:** [Descargar e instalar](https://julialang.org/downloads/).
* **Dynare:** El código utiliza `Dynare.jl`. Asegúrate de que tu sistema pueda ejecutar comandos de Dynare o tener los binarios accesibles si usas la configuración manual.

### 2. Configuración del Entorno (Primera vez)
Este proyecto utiliza `Project.toml` para gestionar dependencias exactas. Sigue estos pasos para instalar todas las librerías necesarias (`DataFrames`, `Plots`, `Dynare`, etc.) automáticamente:

1.  Abre una terminal en la carpeta raíz del repositorio:
    ```bash
    cd tarea_computacional
    ```
2.  Inicia Julia:
    ```bash
    julia
    ```
3.  Ingresa al modo de paquetes presionando la tecla `]`.
4.  Activa e instancia el entorno:
    ```julia
    pkg> activate .
    pkg> instantiate
    ```
    *(Esto descargará e instalará todas las versiones correctas de los paquetes).*
5.  Presiona `Backspace` para volver al terminal estándar de Julia (`julia>`).

---

## 📂 Estructura de Carpetas

* **`data/`**: Contiene los datos crudos (CSV) y procesados (especialmente para el Problema 2).
* **`modfiles/`**: Archivos `.mod` de Dynare con la estructura matemática de los modelos, organizados por problema (`p1`, `p2`, `p3`).
* **`presentation/`**: **Punto de entrada de ejecución.** Contiene los scripts principales (`.jl`) y los `README` específicos de cada tarea.
* **`results/`**: Carpeta de salida donde se guardan automáticamente las tablas (.tex), gráficos (.pdf) y datos simulados (.csv).
* **`source/`**: Código fuente compartido y módulos auxiliares (`utils.jl`, `simulation.jl`, `plots.jl`) que contienen la lógica pesada para mantener los scripts de presentación limpios.

---

## 🚀 Ejecución Rápida

Una vez configurado el entorno, puedes ejecutar cualquier script llamándolo desde la raíz. Por ejemplo, para correr el análisis del **Problema 1**:

```julia
# Desde la consola de Julia en la raíz del proyecto:
include("presentation/p1/0_run_analysis.jl")
```
## Authors
- Cristobal Donoso
- Roberto Flores
- Francisco Medina
- Nicolas Moreno