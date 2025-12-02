# Fetches and processes macroeconomic data for the project.
using DataFrames
using CSV
using Dates

# --- Configuration ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
output_file  = joinpath(project_root, "./data/data_usa.csv")
output_gmm  = joinpath(project_root, "./data/data_gmm.csv")

# --- Load Utilities ---
include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "data.jl"))

# --- Data Parameters ---
# Período del paper: 1955:Q3 a 1983:Q4. Usamos un rango un poco más amplio para el procesamiento.
start_date = Date(1955, 7, 1)
end_date   = Date(2023, 10, 1)
# end_date   = Date(1983, 10, 1)

# DICCIONARIO DE SERIES DE FRED
fred_codes = Dict(
    # Producto y Componentes
    "GDPC1"   => "Y_raw",      # Real GDP
    # Mercado Laboral y Población
    "HOANBS"  => "H_raw",      # Nonfarm Business Sector: Hours of All Persons (Fuente: BLS)
    "CNP16OV" => "N_raw"       # Civilian Noninstitutional Population (16+) (Fuente: BLS)
)

# --- 3. EXECUTION ---
final_df = process_usa_data(fred_codes, start_date, end_date)

# Guardar Dataframe completo (CSV con headers)
CSV.write(output_file, final_df)
println("Archivo 'data_usa.csv' guardado.")

# Guardar Dataframe NUMÉRICO
df_octave = DataFrame(y=final_df.y_pc, c=final_df.c_pc, g=final_df.g_pc, n=final_df.n_pc)
CSV.write(output_gmm, df_octave, header=false)
println("Archivo 'data_gmm.csv' guardado.")