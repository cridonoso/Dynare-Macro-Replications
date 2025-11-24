# Script principal para obtener y guardar los datos (Parte II)
using DataFrames
using CSV
using Dates

# PATHS
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
output_file  = joinpath(project_root, "./data/data_usa.csv")

include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "data.jl"))


start_date = Date(1947, 1, 1)
end_date   = Date(2023, 10, 1)

# Diccionario de Códigos FRED
fred_codes = Dict(
    "GDPC1"   => "Y_raw",  # PIB Real
    "PCECC96" => "C_raw",  # Consumo Real
    "GPDIC1"  => "I_raw",  # Inversión Real
    "HOANBS"  => "H_raw",  # Horas Trabajadas (Sector Negocios)
    "CNP16OV" => "N_raw"   # Población Civil (>16 años)
)

# Ejecutar procesamiento
final_df = process_usa_data(fred_codes, start_date, end_date)

# Guardar CSV para Dynare
CSV.write(output_file, final_df)

println("\n>>> Proceso completado con éxito.")
println(">>> Datos guardados en: $output_file")
println("\nResumen (Primeras 5 filas):")
println(first(final_df, 5))