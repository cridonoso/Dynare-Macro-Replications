# Fetches and processes macroeconomic data for the project.
using DataFrames
using CSV
using Dates

# --- Configuration ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
output_file  = joinpath(project_root, "./data/data_usa.csv")

# --- Load Utilities ---
include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "data.jl"))

# --- Data Parameters ---
start_date = Date(1947, 1, 1)
end_date   = Date(2023, 10, 1)

fred_codes = Dict(
    "GDPC1"   => "Y_raw",  # Real GDP
    "PCECC96" => "C_raw",  # Real Consumption
    "GPDIC1"  => "I_raw",  # Real Investment
    "HOANBS"  => "H_raw",  # Nonfarm Business Sector Hours
    "CNP16OV" => "N_raw"   # Civilian Population
)

# --- Execution ---
final_df = process_usa_data(fred_codes, start_date, end_date)
CSV.write(output_file, final_df)