module DataTools

using Revise
using DataFrames
using Dates
using Downloads
using CSV
using Base.Filesystem



function change_name(df, name, replace)
    # Encuentra la columna por nombre (ignorando mayúsculas/minúsculas)
    date_col_idx = findfirst(x -> lowercase(string(x)) == name, names(df))
    if date_col_idx !== nothing
        rename!(df, names(df)[date_col_idx] => replace)
    end
    return df
end

function rename_data_column!(df::DataFrame, old_col_name, new_name::String)
    # old_col_name debe ser el nombre actual de la columna (String o Symbol).
    # new_name se convierte a Symbol para ser usado como el nuevo nombre de la columna.
    rename!(df, old_col_name => Symbol(new_name))
    return df
end

function download_fred_series(series_id)
    url = "https://fred.stlouisfed.org/graph/fredgraph.csv?id=$series_id&frequency=q&aggregation_method=avg"
    
    try
        io = IOBuffer()
        Downloads.download(url, io)
        seekstart(io)
        df = CSV.read(io, DataFrame)
        df = change_name(df, "date", "date")   
        df = change_name(df, "observation_date", "date")
        return df
    catch e
        println("    Error downloading $series_id: $e")
        return DataFrame()
    end
end

function get_fred_series(fred_codes; savepath::Union{String, Nothing} = nothing)
    
    if savepath !== nothing && isfile(savepath)
        println("Cache encontrado en $(savepath). Cargando datos guardados...")
        try
            return DataFrame(CSV.File(savepath))
        catch e
            @warn "Error al cargar el archivo de caché. Procediendo a descargar. Error: $e"
        end
    end
    
    df_merged = DataFrame()
    is_first = true

    for (code, name) in fred_codes
        println("    Fetching $(code) -> $(name)... ")
        df_series = download_fred_series(code) 

        if !isempty(df_series) && hasproperty(df_series, Symbol(code))
             rename_data_column!(df_series, Symbol(code), name)
        end
        # ----------------------------------

        if isempty(df_series)
            println("    [FAILED]")
        end

        if is_first
            df_merged = df_series
            is_first = false
        else
            df_merged = innerjoin(df_merged, df_series, on = :date, makeunique=true)
        end
    end

    if savepath !== nothing
        println("Descarga completada. Guardando datos en $(savepath)...") 
        mkpath(dirname(savepath)) 
        CSV.write(savepath, df_merged)
    end
        
    return df_merged
end

function get_local_series(series_data; sourcepath::String = "./data") # Corrección: sourcepath debe ser de palabra clave

    df_merged = DataFrame()
    is_first = true

    # series_data itera sobre (code, name, filename)
    for (code, name, filename) in series_data

        full_path = joinpath(sourcepath, filename)

        println("    Loading $(code) ($(name)) from file: $(full_path)...")
        
        if !isfile(full_path)
            @warn "File not found: $(full_path). Skipping series $(code)."
            continue 
        end

        try
            df_series = DataFrame(CSV.File(full_path))
            
            # 1. Renombrar columna de fecha (usando la función robusta)
            df_series = change_name(df_series, "observation_date", "date")
            
            # 2. Renombrar la columna de datos a su nombre deseado (name)
            # La columna de datos se asume que es la segunda (índice 2).
            data_col_name = names(df_series)[2]
            
            # --- USO DE LA FUNCIÓN UNIFICADA ---
            df_series = rename_data_column!(df_series, data_col_name, name)
            # ----------------------------------
            
            if is_first
                df_merged = df_series
                is_first = false
            else
                df_merged = innerjoin(df_merged, df_series, on = :date, makeunique=true)
            end
            
            println("    [OK] Series $(code) successfully merged.")

        catch e
            @warn "Error processing file $(full_path): $e. Skipping series."
            continue 
        end
    end

    if is_first
        println("Warning: No series were loaded or the input data was empty.")
    end
    
    return df_merged
end

function slice_by_date(df::DataFrame, start_date::Date, end_date::Date)
    if !hasproperty(df, :date)
        throw(ArgumentError("DataFrame should contains a column named :date"))
    end
    condition = (df.date .>= start_date) .&& (df.date .<= end_date)
    return df[condition, :]
end

end # end module




#     println(">>> Calculating Economic Variables (C&E 1992 definitions)...")
    
#     Y = Float64.(df_merged.Y_raw)
#     C = Float64.(df_merged.C_raw)
#     G = Float64.(df_merged.G_raw)
#     H = Float64.(df_merged.H_raw)
#     N = Float64.(df_merged.N_raw) # Población

#     df_merged.y_pc = Y ./ N
#     df_merged.c_pc = C ./ N
#     df_merged.g_pc = G ./ N
#     df_merged.n_pc = H ./ N 

#     # 3. Variables para el modelo (Observables)
#     # Inicializar con missings
#     df_merged.dy_obs = Vector{Union{Float64, Missing}}(missing, rows)
#     df_merged.h_obs  = Vector{Union{Float64, Missing}}(missing, rows)

#     if rows > 1
#         # Crecimiento Output (diff log * 100)
#         # diff reduce el vector en 1, asignamos desde el índice 2
#         dy = diff(log.(df_merged.y_pc)) .* 100
#         df_merged.dy_obs[2:end] = dy
#     end

#     # Horas logarítmicas (desviadas de la media)
#     h_log = log.(df_merged.n_pc)
#     df_merged.h_obs = h_log .- mean(h_log)

#     # Eliminar la primera fila que tiene missing por el diff
#     dropmissing!(df_merged)
    
#     println(">>> Final rows for estimation: $(nrow(df_merged))")
#     return df_merged
# end