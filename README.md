# Tarea Computacional: Macroeconomía Dinámica

<span style="color: red;">
⚠️ **ADVERTENCIA:** Se han identificado algunos problemas tras la revisión con el profesor y ayudantes que serán corregidos próximamente. Por ahora, los resultados no replican exactamente el de los autores respectivos.
</span>

Este repositorio contiene la implementación computacional y replicación de tres modelos canónicos de macroeconomía dinámica (RBC y Neo-Keynesiano). El código ha sido estructurado modularmente para separar la lógica de simulación (`source`) de la ejecución de resultados (`presentation`).

## 📚 Estructura del Proyecto

La arquitectura del proyecto sigue el principio de separación de responsabilidades:

| Directorio | Propósito | Contenido Principal |
| :--- | :--- | :--- |
| **`presentation/`** | **Ejecución** | Scripts numerados (e.g., `0_run...`, `1_gen...`) que generan los resultados finales. Aquí es donde el usuario interactúa. |
| **`source/`** | **Lógica** | Módulos reutilizables (`simulation.jl`, `plots.jl`) y librerías específicas por problema (`HansenReplication`, `ReplicationTools`). |
| **`modfiles/`** | **Teoría** | Archivos `.mod` de Dynare que definen las condiciones de primer orden (CPO) y el estado estacionario de cada modelo. |
| **`data/`** | **Insumos** | Datos macroeconómicos crudos (FRED) y procesados (`data_gmm.csv`) listos para la estimación. |
| **`results/`** | **Salida** | Tablas en LaTeX, gráficos PDF y datos simulados generados automáticamente. |

## ⚙️ Requisitos de Software

Para ejecutar este código, necesitas tener instalado lo siguiente:

1.  **Julia (v1.9 o superior)**
    * Es el lenguaje de programación principal.
    * 📥 **[Descargar e Instrucciones de Instalación](https://julialang.org/downloads/)**

2.  **Dynare (v4.6 o superior)**
    * Es el "motor" externo que resuelve los modelos económicos estocásticos.
    * ⚠️ **Importante sobre el "PATH":** Para que Julia pueda comunicarse con Dynare, este debe estar accesible en el *PATH* de tu sistema.

3.  **Configuración del Entorno (Paquetes)**
    Este proyecto utiliza un entorno reproducible. Para instalar automáticamente todas las dependencias exactas (versiones de paquetes) que se utilizaron, sigue estos pasos:

    * Abre una terminal en la carpeta raíz del proyecto (`tarea_computacional/`).
    * Inicia Julia escribiendo `julia`.
    * Entra al modo de paquetes presionando la tecla `]`.
    * Ejecuta los siguientes comandos para activar el entorno e instalar todo:

    ```julia
    (v1.9) pkg> activate .
      Activating project at `~/ruta/a/tarea_computacional`

    (tarea_computacional) pkg> instantiate
    ```
    * Esto descargará e instalará automáticamente paquetes como `Dynare`, `DataFrames`, `Plots`, etc., basándose en los archivos `Project.toml` y `Manifest.toml`.
    * Presiona `Backspace` para volver al modo normal de Julia.

## 🚀 Guía Rápida de Ejecución

Cada problema (`p1`, `p2`, `p3`) es autocontenido. A continuación se presentan dos formas de ejecutar el código.

### Opción A: Desde el REPL de Julia (⚡ Recomendado)
Esta es la forma más rápida y eficiente. Al mantener la sesión abierta, evitas que Julia tenga que recompilar los paquetes en cada ejecución.

1.  **Iniciar:** Abre una terminal en la carpeta raíz del proyecto e inicia Julia cargando el entorno:
    ```bash
    julia --project=.
    ```
2.  **Ejecutar:** Usa el comando `include` para correr los scripts secuencialmente.
    *(Ejemplo para el Problema 2: Estimación con Gasto de Gobierno)*

    ```julia
    # 1. Descarga y procesamiento de datos
    include("presentation/p2/0_get_data.jl")

    # 2. Estimación y tablas
    include("presentation/p2/1_estimate.jl")
    ```

### Opción B: Desde la Terminal (Shell)
Útil para ejecuciones rápidas o automatización, pero **más lento** debido a la latencia de inicio y compilación de Julia en cada comando.

1.  Abre una terminal y navega a la carpeta raiz del proyecto
2.  Ejecuta los scripts apuntando al entorno raíz (`--project=.`):
    ```bash
    # Paso 1
    julia --project="." 0_get_data.jl

    # Paso 2
    julia --project="." 1_estimate.jl
    ```

---
*Curso: Macroeconomía - Doctorado en Economía*
