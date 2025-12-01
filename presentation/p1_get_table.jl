# Generates a summary table from simulation results.
using CSV
using DataFrames
using PrettyTables
using Printf

# --- Configuration ---
target_model = "1"
idx = findfirst(x -> x == "--model" || x == "-m", ARGS)
if idx !== nothing && idx < length(ARGS)
    target_model = ARGS[idx+1]
end

results_path = joinpath(@__DIR__, "..", "results", "p1", target_model)
csv_file = joinpath(results_path, "moments_summary.csv")
tex_path = joinpath(results_path, "table_model_$(target_model).tex")

# --- Load Data ---
if !isfile(csv_file)
    error("CSV not found for Model $target_model. Run simulation first.")
end
df = CSV.read(csv_file, DataFrame)

# --- Helper Function ---
function get_val(stat, var)
    row = filter(r -> r.Statistic == stat, df)
    return isempty(row) || !(string(var) in names(df)) ? NaN : row[1, Symbol(var)]
end

# --- Table Generation ---
vars_preference = ["y", "yM", "c", "i", "invest", "h", "hM", "productivity"]
vars_to_show = filter(v -> v in names(df), vars_preference)

data_matrix = Matrix{Any}(undef, length(vars_to_show), 4)

for (i, v) in enumerate(vars_to_show)
    # Use a more descriptive label for productivity
    label = (v == "productivity") ? "p (y/h)" : v
    label = (v == "invest") ? "i" : label # Standardize investment label
    data_matrix[i, 1] = label
    
    # Column 1: Std Dev (%)
    std_dev = get_val("StdDev", v) * 100
    data_matrix[i, 2] = @sprintf("%.2f", std_dev)
    
    # Column 2: Relative Std Dev
    if v == "y" || v == "yM"
        data_matrix[i, 3] = "1.00"
    else
        rel_std_dev = get_val("RelStdDev", v)
        data_matrix[i, 3] = @sprintf("%.2f", rel_std_dev)
    end
    
    # Column 3: Correlation with Y
    corr_with_y = get_val("CorrWithY", v)
    data_matrix[i, 4] = @sprintf("%.2f", corr_with_y)
end

# --- Output ---
header = ["Variable", "Std Dev (%)", "Rel Std Dev", "Corr with Y"]

# Print to console
pretty_table(data_matrix; header=header, crop=:none, alignment=:c)

# Save to LaTeX file
open(tex_path, "w") do f
    pretty_table(f, data_matrix; header=header, backend=Val(:latex))
end