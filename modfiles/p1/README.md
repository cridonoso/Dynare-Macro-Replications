# Archivos MOD: Modelos de Ciclos Económicos Reales (Hansen, 1985)

## Pregunta 1: Replicación de Extensiones RBC

En esta sección se reproducen cinco variantes del modelo de Ciclos Económicos Reales (RBC) presentadas en la literatura (basado en **Hansen, 1985** y extensiones posteriores). El objetivo es evaluar la capacidad de cada estructura para generar volatilidad macroeconómica consistente con los datos empíricos, especialmente en el mercado laboral.

---

### 1. `1.mod`: Modelo RBC Básico
Es el modelo **canónico** de referencia.
* **Características:**
    * Agente representativo con preferencias separables (log-log implícito).
    * Función de producción Cobb-Douglas estándar.
    * Trabajo perfectamente divisible.
* **Dinámica:** La utilidad marginal del consumo es independiente del ocio, lo que limita la volatilidad de las horas trabajadas frente a shocks de productividad.

---

### 2. `2.mod`: Ocio No Separable (Kydland & Prescott)
Esta extensión introduce **formación de hábitos en el ocio** ("Leisure Services").
* **Características:**
    * La utilidad depende de un stock de "servicios de ocio" ($L_t$), que es una función del ocio actual y del pasado ($X_{t-1}$).
    * Ecuación: $L_t = \alpha(1-h_t) + (1-\alpha)X_{t-1}$.
* **Efecto:** Introduce una no-separabilidad intertemporal. Esto aumenta la sustitución intertemporal de la oferta laboral (hace que la oferta de trabajo sea más elástica a corto plazo), generando mayor volatilidad en las horas.

---

### 3. `3.mod`: Trabajo Indivisible (Hansen)
Basado en **Hansen (1985)** y la teoría de loterías de empleo de **Rogerson (1988)**.
* **Características:**
    * Los agentes eligen entre trabajar un número fijo de horas ($\hat{h}$) o no trabajar (margen extensivo).
    * Existe un mercado de seguros completo que permite compartir el riesgo.
    * **Resultado Analítico:** La función de utilidad del agente representativo se vuelve **lineal en horas trabajadas** ($U_{hours} \propto -B \cdot h_t$).
* **Efecto:** La oferta laboral agregada se vuelve infinitamente elástica (o muy elástica), amplificando masivamente la respuesta de las horas y el producto ante shocks tecnológicos.

---

### 4. `4.mod`: Gasto de Gobierno
Incorpora un sector público que consume recursos pero no produce utilidad directa ni productividad (gasto improductivo).
* **Características:**
    * Restricción de recursos: $Y_t = C_t + I_t + G_t$.
    * $G_t$ sigue un proceso estocástico exógeno AR(1).
* **Efecto:** Los shocks de gasto público generan un **efecto riqueza** negativo (al aumentar $G$, bajan los recursos disponibles para consumo privado), lo que incentiva a los hogares a trabajar más y consumir menos, alterando las correlaciones cíclicas.

---

### 5. `5.mod`: Producción Doméstica (Home Production)
Modelo de dos sectores (Mercado y Hogar) inspirado en **Benhabib, Rogerson & Wright (1991)**.
* **Características:**
    * Los agentes asignan tiempo entre trabajo de mercado ($h_M$), producción doméstica ($h_H$) y ocio.
    * El consumo agregado es un índice **CES** de bienes de mercado ($c_M$) y bienes del hogar ($c_H$).
    * Shocks de productividad correlacionados entre ambos sectores.
* **Efecto:** Permite una sustitución adicional entre sectores. Ante un shock negativo en el mercado, los agentes pueden desplazar recursos al sector doméstico en lugar de solo al ocio, lo que ayuda a explicar mejor la baja correlación entre productividad y horas observada en los datos.