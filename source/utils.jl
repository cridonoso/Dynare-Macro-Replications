"""
    organize_model_output(mod_file_path::String, output_path::String)

Mueve los archivos de salida generados por Dynare (.log, carpetas graphs/output)
desde la ubicación del archivo .mod hacia la carpeta de destino especificada.

# Argumentos
- `mod_file_path`: Ruta al archivo .mod ejecutado (ej: "modfiles/p1/1.mod")
- `output_path`: Carpeta de destino para los resultados (ej: "results/p1/1")
"""
function organize_model_output(mod_file_path::String, output_path::String)
    # 1. Identificar rutas origen
    # Dynare genera los outputs en la misma carpeta que el .mod
    src_dir = dirname(mod_file_path)
    mod_name = splitext(basename(mod_file_path))[1] # "1" de "1.mod"
    
    src_log = joinpath(src_dir, mod_name * ".log")
    src_output_folder = joinpath(src_dir, mod_name) # Carpeta "1" generada por Dynare

    # 2. Preparar destino
    if !isdir(output_path)
        mkpath(output_path)
        println(">>> [Utils] Created output directory: $output_path")
    end

    println(">>> [Utils] Organizing files for model '$mod_name'...")

    # 3. Mover Log
    if isfile(src_log)
        dest_log = joinpath(output_path, mod_name * ".log")
        mv(src_log, dest_log, force=true)
        println("    ✔ Log moved to: $dest_log")
    else
        println("    ⚠ Warning: Log file not found at $src_log")
    end

    # 4. Mover contenido de carpeta de salida (graphs, output)
    if isdir(src_output_folder)
        # Movemos el contenido interno para evitar anidar carpetas innecesariamente
        # o movemos la carpeta entera si prefieres mantener la estructura "1/graphs"
        
        # Estrategia: Mover contenido (graphs, output) directamente a results/p1/1/
        for item in readdir(src_output_folder)
            src_item = joinpath(src_output_folder, item)
            dest_item = joinpath(output_path, item)
            mv(src_item, dest_item, force=true)
            println("    ✔ Moved output: $item")
        end
        # Borrar la carpeta vacía original
        rm(src_output_folder)
    else
        println("    ⚠ Warning: Output folder '$src_output_folder' not found")
    end
    
    println(">>> [Utils] Cleanup complete.")
end