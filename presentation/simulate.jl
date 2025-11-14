using Dynare

# 1. Asumimos que el REPL está en la carpeta raíz del proyecto
#    (.../tarea_computacional)
#    Definimos la carpeta de los mods
mod_folder = "modfiles"

# 2. Entramos a esa carpeta
cd(mod_folder)

# 3. Ejecutamos Dynare
#    Como ya estamos "dentro" de modfiles, solo pasamos el nombre del archivo
println("Ejecutando Dynare desde: ", pwd())
context = @dynare "rbc_basic.mod"

# 4. IMPORTANTE: Regresamos a la carpeta raíz del proyecto
cd("..")

println("Simulación terminada, volviendo a: ", pwd())