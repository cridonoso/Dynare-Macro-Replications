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
    println(">>> Downloading FRED data...")
    df_merged = DataFrame(date = Date[])
    first_iter = true

    for (code, name) in fred_codes
        println("   - Fetching: $code ($name)")
        df_temp = download_fred_series(code)
        
        if isempty(df_temp)
            error("Failed to download essential series: $code")
        end
        
        if code == "CNP16OV" # Monthly to Quarterly filter
            filter!(row -> month(row.date) in [1, 4, 7, 10], df_temp)
        end

        # Renombrar 'value' al nombre interno deseado (ej: Y_raw)
        rename!(df_temp, "value" => name)

        if first_iter
            df_merged = df_temp
            first_iter = false
        else
            # Join on date
            df_merged = innerjoin(df_merged, df_temp, on = :date)
        end
    end

    # Filter dates
    filter!(row -> row.date >= start_date && row.date <= end_date, df_merged)
    sort!(df_merged, :date)

    println(">>> Base data fetched. Size: ", size(df_merged))
    println(">>> Processing variables (Log + HP Filter)...")
    
    # Calculations (Per Capita + Log)
    # 1. Real GDP Per Capita
    df_merged.y_log = log.(df_merged.Y_raw ./ df_merged.N_raw)
    
    # 2. Real Consumption Per Capita
    df_merged.c_log = log.(df_merged.C_raw ./ df_merged.N_raw)
    
    # 3. Real Investment Per Capita
    df_merged.i_log = log.(df_merged.I_raw ./ df_merged.N_raw)
    
    # 4. Hours Per Capita
    df_merged.h_log = log.(df_merged.H_raw ./ df_merged.N_raw)

    # HP Filter (Using function from utils.jl - ensure it's loaded!)
    # Note: Since this file is included by get_data.jl which includes utils.jl, hp_filter is available.
    df_merged.y = hp_filter(df_merged.y_log)
    df_merged.c = hp_filter(df_merged.c_log)
    df_merged.i = hp_filter(df_merged.i_log)
    df_merged.h = hp_filter(df_merged.h_log)

    # Select final variables for Dynare
    return select(df_merged, :date, :y, :c, :i, :h)
end