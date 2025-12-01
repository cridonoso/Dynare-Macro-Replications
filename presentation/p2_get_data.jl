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
start_date = Date(1955, 1, 1)
# end_date   = Date(1984, 1, 1) # paper
end_date   = Date(2025, 1, 1)

# DICCIONARIO CORREGIDO SEGÚN PAPER:
fred_codes = Dict(
        "GDPC1"   => "Y_raw",      # Real GDP (Trimestral)
        "PCND"    => "C_Nom_ND",   # Nominal Nondurables (Mensual/Trim) - REEMPLAZA PCNDGC96
        "PCESV"   => "C_Nom_SV",   # Nominal Services (Mensual/Trim) - REEMPLAZA PCESVC96
        "GDPDEF"  => "P_Deflator", # GDP Deflator (Trimestral, Index 2012=100)
        "GCEC1"   => "G_raw",      # Real Govt Spending
        "HOANBS"  => "H_raw",      # Hours (Trimestral)
        "CNP16OV" => "N_raw"       # Population (Mensual)
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