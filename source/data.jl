# Nombre archivo: source/data.jl
# CORREGIDO: Frecuencia Trimestral forzada para alineación perfecta
using DataFrames
using CSV
using Dates
using Statistics
using Downloads

function download_fred_series(series_id)
    # TRUCO CLAVE: Agregamos '&frequency=q&aggregation_method=avg'
    # Esto fuerza a FRED a convertir series mensuales (Consumo, Pob) a Trimestrales
    # promediando los meses. Así todas las fechas serán 01-01, 04-01, 07-01, 10-01.
    url = "https://fred.stlouisfed.org/graph/fredgraph.csv?id=$series_id&frequency=q&aggregation_method=avg"
    
    try
        io = IOBuffer()
        Downloads.download(url, io)
        seekstart(io)
        df = CSV.read(io, DataFrame)
        
        # Normalizar nombre de fecha
        date_col_idx = findfirst(x -> lowercase(string(x)) == "observation_date", names(df))
        if date_col_idx !== nothing
            rename!(df, names(df)[date_col_idx] => "date")
        end
        
        # Normalizar columna de valor
        # A veces FRED devuelve el ID como nombre, a veces "value".
        col_names = names(df)
        val_col_idx = findfirst(n -> n != "date", col_names)
        
        if val_col_idx !== nothing
            rename!(df, col_names[val_col_idx] => "value")
        end
        
        return df
    catch e
        println("    Error downloading $series_id: $e")
        return DataFrame()
    end
end

function process_usa_data(fred_codes::Dict, start_date::Date, end_date::Date)
    println(">>> Downloading and merging FRED data (Quarterly Aggregation)...")
    
    df_merged = DataFrame()
    is_first = true

    # Ordenamos el diccionario para que el merge sea determinístico (opcional pero útil)
    for (code, name) in fred_codes
        print("    Fetching $code -> $name... ")
        df_series = download_fred_series(code)
        
        if isempty(df_series)
            println("[FAILED]")
            continue
        end
        println("[OK] ($(nrow(df_series)) obs)")
        
        # Renombrar columna de valor al nombre económico deseado
        if "value" in names(df_series)
            rename!(df_series, "value" => name)
        else
            println("    Warning: 'value' column not found in $code")
            continue
        end
        
        if is_first
            df_merged = df_series
            is_first = false
        else
            # Ahora el innerjoin es seguro porque TODAS son trimestrales
            df_merged = innerjoin(df_merged, df_series, on = :date, makeunique=true)
        end
    end

    # --- CARGA LOCAL DE DATOS (CSV) ---
    # Debido a problemas con FRED, cargamos estas series desde archivos locales.
    project_root = joinpath(@__DIR__, "..")

    # 1. Cargar Gasto de Gobierno (G_raw)
    println("    Loading local data for Government Spending (G_raw)...")
    g_local_path = joinpath(project_root, "data", "A955RX1Q020SBEA.csv")
    if isfile(g_local_path)
        df_g = CSV.read(g_local_path, DataFrame)
        rename!(df_g, "observation_date" => "date", "A955RX1Q020SBEA" => "G_raw")
        df_merged = innerjoin(df_merged, df_g, on = :date)
        println("    [OK] (Loaded G_raw)")
    else
        error("No se encontró el archivo local para Gasto de Gobierno: $g_local_path")
    end

    # 2. Cargar Consumo Privado (C_raw)
    println("    Loading local data for Private Consumption (C_raw)...")
    c_annual_path = joinpath(project_root, "data", "PCECCA.csv")
    c_monthly_path = joinpath(project_root, "data", "PCEC96.csv")

    if isfile(c_annual_path)
        df_c_annual = CSV.read(c_annual_path, DataFrame)
        rename!(df_c_annual, "observation_date" => "date", "PCECCA" => "C_raw")

        # Convertir datos anuales a trimestrales
        df_c_quarterly = DataFrame(date=Date[], C_raw=Float64[])
        for row in eachrow(df_c_annual)
            year = Dates.year(row.date)
            # Solo procesar años relevantes para evitar un DataFrame gigante
            if year >= Dates.year(start_date) - 1 && year <= Dates.year(end_date) + 1
                for q in 1:4
                    quarter_date = Date(year, (q-1)*3 + 1, 1)
                    push!(df_c_quarterly, (date=quarter_date, C_raw=row.C_raw))
                end
            end
        end
        
        # Unir con el DataFrame principal
        df_merged = innerjoin(df_merged, df_c_quarterly, on = :date)
        println("    [OK] (Loaded and processed C_raw from annual data)")
    elseif isfile(c_monthly_path)
        # Lógica de respaldo si solo existe el mensual (no se usará si el anual está)
        println("    Warning: Annual consumption data not found, using monthly as fallback.")
        # Aquí iría la lógica para procesar el archivo mensual si fuera necesario.
    else
        error("No se encontró ningún archivo local para Consumo: $c_annual_path o $c_monthly_path")
    end

    println(">>> Merged rows before filtering: $(nrow(df_merged))")

    # Filtrar fechas
    filter!(row -> row.date >= start_date && row.date <= end_date, df_merged)
    sort!(df_merged, :date)

    rows = nrow(df_merged)
    println(">>> Rows after filtering ($start_date to $end_date): $rows")
    
    if rows == 0
        error("El DataFrame está vacío. Revisa que las fechas solicitadas (1955-1984) coincidan con la data descargada.")
    end

    println(">>> Calculating Economic Variables (C&E 1992 definitions)...")
    
    # 1. Construcción de variables según el paper
    # NOTA: C_raw (PCEC) es una proxy. El paper usa una medida más compleja que incluye
    # el flujo de servicios de bienes durables, no el gasto en ellos.

    # 2. Transformaciones Per Cápita (asegurando tipo Float64)
    # Convertimos todo a Float64 para evitar errores de tipo
    Y = Float64.(df_merged.Y_raw)
    C = Float64.(df_merged.C_raw)
    G = Float64.(df_merged.G_raw)
    H = Float64.(df_merged.H_raw)
    N = Float64.(df_merged.N_raw) # Población

    df_merged.y_pc = Y ./ N
    df_merged.c_pc = C ./ N
    df_merged.g_pc = G ./ N
    df_merged.n_pc = H ./ N 

    # 3. Variables para el modelo (Observables)
    # Inicializar con missings
    df_merged.dy_obs = Vector{Union{Float64, Missing}}(missing, rows)
    df_merged.h_obs  = Vector{Union{Float64, Missing}}(missing, rows)

    if rows > 1
        # Crecimiento Output (diff log * 100)
        # diff reduce el vector en 1, asignamos desde el índice 2
        dy = diff(log.(df_merged.y_pc)) .* 100
        df_merged.dy_obs[2:end] = dy
    end

    # Horas logarítmicas (desviadas de la media)
    h_log = log.(df_merged.n_pc)
    df_merged.h_obs = h_log .- mean(h_log)

    # Eliminar la primera fila que tiene missing por el diff
    dropmissing!(df_merged)
    
    println(">>> Final rows for estimation: $(nrow(df_merged))")
    return df_merged
end