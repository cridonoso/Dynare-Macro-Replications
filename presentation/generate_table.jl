using CSV
using DataFrames
using PrettyTables
using Printf

# --- Parse Args ---
target_model = "1"
idx = findfirst(x -> x == "--model" || x == "-m", ARGS)
if idx !== nothing && idx < length(ARGS)
    target_model = ARGS[idx+1]
end

# --- Paths ---
results_path = joinpath(@__DIR__, "..", "results", "p1", target_model)
csv_file = joinpath(results_path, "moments_summary.csv")

if !isfile(csv_file)
    error("CSV not found for Model $target_model. Run simulation first.")
end

df = CSV.read(csv_file, DataFrame)

# --- Helpers ---
function get_val(stat, var)
    row = filter(r -> r.Statistic == stat, df)
    if isempty(row) return NaN end
    # Check symbol existence
    if string(var) in names(df) return row[1, Symbol(var)] end
    return NaN
end

# --- Variable Mapping ---
var_map = Dict(
    "y" => "y", 
    "c" => "c", 
    "i" => "i", 
    "h" => "h", 
    "productivity" => "productivity",
    "yM" => "yM", 
    "hM" => "hM"
)

if "invest" in names(df) 
    var_map["i"] = "invest" 
end

# --- Build Table ---
vars_preference = ["y", "yM", "c", "i", "h", "hM", "productivity"]

# Filtramos: Que esté en el mapa Y que exista en el CSV generado
vars_to_show = filter(v -> haskey(var_map, v) && (var_map[v] in names(df)), vars_preference)

data = Matrix{Any}(undef, length(vars_to_show), 4)

for (i, v) in enumerate(vars_to_show)
    m_var = var_map[v]
    
    label = (v == "productivity") ? "p (y/h)" : v
    data[i, 1] = label
    
    # 1. Std Dev (Percent)
    val = get_val("StdDev", m_var) * 100
    data[i, 2] = @sprintf("%.2f", val)
    
    # 2. Rel Std Dev
    if v == "y" || v == "yM"
        data[i, 3] = "1.00"
    else
        val = get_val("RelStdDev", m_var)
        data[i, 3] = @sprintf("%.2f", val)
    end
    
    # 3. Correlation
    val = get_val("CorrWithY", m_var)
    data[i, 4] = @sprintf("%.2f", val)
end

# --- Output ---
header = ["Variable", "Std Dev (%)", "Rel Std Dev", "Corr with Y"]
println("\nTable 3 Statistics - Model $target_model")
pretty_table(data; header=header, crop=:none, alignment=:c)

tex_path = joinpath(results_path, "table_model_$(target_model).tex")
open(tex_path, "w") do f
    pretty_table(f, data; header=header, backend=Val(:latex))
end
println("\nLaTeX saved to: $tex_path")