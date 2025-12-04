using CSV
using DataFrames
using Statistics

# --- 1. Configuración ---
project_root = joinpath(@__DIR__, "..", "..")
source_dir   = joinpath(project_root, "source")
results_path = joinpath(project_root, "results", "p1")

# Cargar módulo de lógica específica
include(joinpath(@__DIR__, "..", "..", "source", "p1", "utils.jl"))
using .HansenReplication

println(">>> Generando Tabla Comparativa (LaTeX)...")

target_models = ["1", "2", "3", "4", "5"]
data_collection = Dict{String, DataFrame}()

# --- 2. Carga de Datos ---
for m in target_models
    file_path = joinpath(results_path, m, "item5_montecarlo_results.csv")
    if isfile(file_path)
        data_collection[m] = CSV.read(file_path, DataFrame)
    else
        println("⚠️ No se encontraron datos para el modelo $m")
    end
end

if isempty(data_collection)
    error("No hay datos para generar la tabla.")
end

# --- 3. Generación y Exportación ---
# Generar código LaTeX mediante el módulo
latex_code = HansenReplication.generate_comparison_table(data_collection)

# Guardar archivo .tex
out_path = joinpath(results_path, "comparison_p1.tex")
open(out_path, "w") do f
    write(f, latex_code)
end

println("✅ Tabla guardada exitosamente en: $out_path")