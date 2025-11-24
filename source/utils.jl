function organize_model_output(mod_file_path::String, output_path::String)
    src_dir = dirname(mod_file_path)
    mod_name = splitext(basename(mod_file_path))[1]
    
    src_log = joinpath(src_dir, mod_name * ".log")
    src_output_folder = joinpath(src_dir, mod_name)

    if !isdir(output_path)
        mkpath(output_path)
        println(">>> [Utils] Created output directory: $output_path")
    end

    println(">>> [Utils] Organizing files for model '$mod_name'...")

    if isfile(src_log)
        dest_log = joinpath(output_path, mod_name * ".log")
        mv(src_log, dest_log, force=true)
        println("    ✔ Log moved to: $dest_log")
    else
        println("    ⚠ Warning: Log file not found at $src_log")
    end

    if isdir(src_output_folder)
        for item in readdir(src_output_folder)
            src_item = joinpath(src_output_folder, item)
            dest_item = joinpath(output_path, item)
            mv(src_item, dest_item, force=true)
            println("    ✔ Moved output: $item")
        end
        rm(src_output_folder)
    else
        println("    ⚠ Warning: Output folder '$src_output_folder' not found")
    end
    
    println(">>> [Utils] Cleanup complete.")
end

# --- HP Filter (Lambda=1600) ---
function hp_filter(y::Vector{Float64}, lambda::Float64=1600.0)
    n = length(y)
    if n < 3 return zeros(n) end
    
    D = zeros(n-2, n)
    for i in 1:n-2
        D[i, i] = 1.0; D[i, i+1] = -2.0; D[i, i+2] = 1.0
    end
    
    A = I + lambda * (D' * D)
    return y - (A \ y)
end