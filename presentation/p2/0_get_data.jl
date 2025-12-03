using DataFrames
using Statistics
using Dates
using CSV

include(joinpath(@__DIR__, "..", "..", "source", "plots.jl"))
include(joinpath(@__DIR__, "..", "..", "source", "data.jl"))
using .Plotting
using .DataTools

# --- Util Paths ---
project_root = joinpath(@__DIR__, "..", "..")
source_dir   = joinpath(project_root, "source")

output_file = joinpath(project_root, "./data/data_usa.csv")
output_gmm  = joinpath(project_root, "./data/data_gmm.csv")

# --- Diccionario FRED ---
fred_codes = Dict(
    "GDPC1"   => "Y_raw",      # Real GDP
    "HOANBS"  => "H_raw",      # Nonfarm Business Sector: Hours of All Persons (Fuente: BLS)
    "CNP16OV" => "N_raw",      # Civilian Noninstitutional Population (16+) (Fuente: BLS)
    "GPDIC1"  => "I_raw",      # Real Disposable Income (Fuente: FRED),
    "FEDFUNDS" => "R_raw",     # Interest Rate (Fuente: FRED)
    "PCECC96"  => "C_raw",     # Consumo Privado (Fuente: FRED)
)
fred_series = DataTools.get_fred_series(fred_codes, savepath="./data/rawfred.csv")

# --- Diccionario Local ---
local_series_to_load = [
    ("A955RX1Q020SBEA", "G_raw",  "gob_trimestral.csv")
]
local_series = DataTools.get_local_series(local_series_to_load)

# --- Join Diccionarios ---
dataset = innerjoin(fred_series, local_series, on = :date)

# --- Filter by Dates --- 
start_date = Date(1955, 7, 1)    # init
end_date   = Date(1984, 1, 1)    # paper's end
# end_date   = Date(2023, 10, 1) # own

dataset = DataTools.slice_by_date(dataset, start_date, end_date)


# ---- Preprocessing Pipeline ---

# Data Type Conversion
data_cols = names(dataset, Not(:date)) 
for col_name in data_cols
    dataset[!, Symbol(col_name)] = Float64.(dataset[!, Symbol(col_name)])
end

# PerCapita Transform
transform!(dataset, 
    [:Y_raw, :N_raw] => ByRow(/) => :y_pc,
    [:C_raw, :N_raw] => ByRow(/) => :c_pc,
    [:G_raw, :N_raw] => ByRow(/) => :g_pc,
    [:H_raw, :N_raw] => ByRow(/) => :h_pc, # Horas por cápita
    renamecols=false
)

# Output growth rate per capita (dy = diff log * 100 ) 
transform!(dataset, :y_pc => (y -> vcat(missing, diff(log.(y)) .* 100)) => :dy_obs)

# Hours (log) per capita (h_log - mean)
h_log_mean = mean(log.(skipmissing(dataset.h_pc)))
transform!(dataset, :h_pc => (h -> log.(h) .- h_log_mean) => :h_obs)

# Working Hours per capita (level log)
transform!(dataset, :h_pc => (h -> log.(h)) => :h_log)

# Remove missing values
dropmissing!(dataset)

# Saving Final DataFrame
select!(dataset, :date, :dy_obs, :h_obs, :R_raw, :C_raw, :G_raw, :I_raw, :y_pc, :c_pc, :g_pc, :h_pc, :h_log)
println(">>> Final rows for estimation: $(nrow(dataset))")

CSV.write(output_file, dataset)
df_gmm = DataFrame(
    y = dataset.y_pc, 
    c = dataset.c_pc, 
    g = dataset.g_pc, 
    n = dataset.h_pc 
)
CSV.write(output_gmm, df_gmm, header=false)
println("Archivo 'data_usa.csv' guardado en $(output_file)")
println("Archivo 'data_gmm.csv' guardado en $(output_gmm)")