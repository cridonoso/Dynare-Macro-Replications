using CSV
using DataFrames
using Dates
using Statistics
using LinearAlgebra
using Downloads

# --- Download Function ---
function download_fred_series(series_id)
    url = "https://fred.stlouisfed.org/graph/fredgraph.csv?id=$series_id"
    try
        io = IOBuffer()
        Downloads.download(url, io)
        seekstart(io)
        df = CSV.read(io, DataFrame)

        date_col_idx = findfirst(x -> lowercase(string(x)) == "observation_date", names(df))
        
        if date_col_idx !== nothing
            rename!(df, names(df)[date_col_idx] => "date")
        else
            println("Warning: No 'date' column found for $series_id")
        end

        if ncol(df) == 2
            val_col = names(df)[findfirst(n -> n != "date", names(df))]
            rename!(df, val_col => "value")
        elseif series_id in names(df)
            rename!(df, series_id => "value")
        end
        
        return df
    catch e
        println("Error downloading $series_id: $e")
        return DataFrame()
    end
end

# --- Process Data Function ---
function process_usa_data(fred_codes::Dict, start_date::Date, end_date::Date)
    # 1. Aseguramos que Gasto de Gobierno esté en el diccionario
    if !haskey(fred_codes, "GCEC1")
        fred_codes["GCEC1"] = "G_raw" # Real Govt Consumption & Investment
    end

    println(">>> Downloading FRED data...")
    
    # Inicializamos un DataFrame para unir todas las series
    df_merged = DataFrame()
    is_first = true

    for (code, name) in fred_codes
        println("    Downloading $code as $name...")
        df_series = download_fred_series(code)
        
        if isempty(df_series)
            println("    Warning: Failed to download or process $code. Skipping.")
            continue
        end
        
        # Renombramos la columna 'value' al nombre deseado (ej: 'Y_raw')
        rename!(df_series, "value" => name)
        
        if is_first
            df_merged = df_series
            is_first = false
        else
            df_merged = outerjoin(df_merged, df_series, on = :date)
        end
    end
    # Filter dates
    filter!(row -> row.date >= start_date && row.date <= end_date, df_merged)
    dropmissing!(df_merged)
    disallowmissing!(df_merged)
    sort!(df_merged, :date)

    println(">>> Processing variables...")

    # A. Transformaciones Per Cápita (Logaritmos)
    # Nota: Es crucial guardar esto para la Tabla 1 (Calibración)
    df_merged.y_lvl = log.(df_merged.Y_raw ./ df_merged.N_raw)
    df_merged.c_lvl = log.(df_merged.C_raw ./ df_merged.N_raw)
    df_merged.i_lvl = log.(df_merged.I_raw ./ df_merged.N_raw)
    df_merged.g_lvl = log.(df_merged.G_raw ./ df_merged.N_raw)
    df_merged.h_lvl = log.(df_merged.H_raw ./ df_merged.N_raw)

    # B. Filtro HP (Ciclos) para Tablas 2 y 3 (Estadísticas de Negocios)
    try
        df_merged.y_cycle = hp_filter(df_merged.y_lvl)
        df_merged.c_cycle = hp_filter(df_merged.c_lvl)
        df_merged.i_cycle = hp_filter(df_merged.i_lvl)
        df_merged.g_cycle = hp_filter(df_merged.g_lvl)
        df_merged.h_cycle = hp_filter(df_merged.h_lvl)
    catch e
        println("Warning: hp_filter function not found or failed. Skipping HP columns.")
    end

    # C. Variables para Estimación (Observables Estacionarios para Dynare)
    println(">>> Generating Estimation Observables (Growth Rates & Demeaned)...")

    # 1. Crecimiento del PIB (dy_obs)
    # Calculamos la primera diferencia logarítmica multiplicada por 100.
    # [missing; ...] se usa para mantener la longitud del vector alineada con el DataFrame.
    dy_val = diff(df_merged.y_lvl) .* 100
    df_merged.dy_obs = [missing; dy_val]

    # 2. Horas Desviadas (h_obs)
    # Logaritmo de horas menos su media muestral.
    df_merged.h_obs = df_merged.h_lvl .- mean(df_merged.h_lvl)

    # Limpieza final:
    # Eliminamos la primera fila porque 'dy_obs' será 'missing' (resultado de diff)
    dropmissing!(df_merged)

    # Retornamos todo: Niveles, Ciclos HP y Observables para estimación
    return df_merged
end