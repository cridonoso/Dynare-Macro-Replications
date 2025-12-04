using DataFrames
using Statistics
using Dates
using CSV

include(joinpath(@__DIR__, "..", "..", "source", "plots.jl"))
include(joinpath(@__DIR__, "..", "..", "source", "p2", "data.jl"))
include(joinpath(@__DIR__, "..", "..", "source", "p2", "utils.jl"))

using .Plotting
using .DataTools
using .ReplicationTools


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

# Verificar si el flag "--paper" está presente en los argumentos
if "--paper" in ARGS
    println(">>>   Modo Paper activado: Filtrando hasta 1984.")
    end_date = Date(1984, 1, 1)  # paper's end
else
    println(">>>   Modo Actual (Default): Filtrando hasta 2023.")
    end_date = Date(2023, 10, 1) # own
end

# Preparar dataset de acuerdo al preprocesamiento del paper
dataset = preprocess_usa_data(dataset)

# Guardar datos procesados
save_usa_data(dataset, output_file, output_gmm)