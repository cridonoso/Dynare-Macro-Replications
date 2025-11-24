using CSV
using DataFrames
using PrettyTables
using Printf

# -------------------------------------------------------------------------
# CONFIGURATION
# -------------------------------------------------------------------------
# Adjust this path to point to your specific model result folder (e.g., results/p1/1)
# For automation across all models, you can wrap this in a loop or pass arguments.
target_model = "1" # Change this to "2", "3", etc.
results_path = joinpath(@__DIR__, "..", "results", "p1", target_model)
csv_file = joinpath(results_path, "moments_summary.csv")

if !isfile(csv_file)
    error("Summary CSV not found: $csv_file. Run the simulation first.")
end

# -------------------------------------------------------------------------
# LOAD AND PROCESS DATA
# -------------------------------------------------------------------------
df = CSV.read(csv_file, DataFrame)

# Helper function to extract a value given a statistic row and variable column
function get_val(stat_name, var_name)
    # Find row
    row = filter(r -> r.Statistic == stat_name, df)
    if isempty(row)
        return NaN
    end
    # Find column (case insensitive check if needed, but CSV usually matches model)
    if string(var_name) in names(df)
        return row[1, Symbol(var_name)]
    else
        # Handle potential name mismatches (e.g., 'invest' vs 'i')
        # Add mappings if necessary
        return NaN
    end
end

# Define the mapping for your model variables to the Table 3 labels
# Adjust the values on the RIGHT to match your .mod variable names
var_map = Dict(
    "y" => "y",
    "c" => "c",
    "i" => "i",   # or "invest" for model 3
    "h" => "h",
    "w" => "w",   # Real wage (MPL), usually not in basic RBC mod but calculable
    "r" => "r"    # Real interest rate
)

# Special handling for Model 3 which uses 'invest' instead of 'i'
if "invest" in names(df)
    var_map["i"] = "invest"
end

# -------------------------------------------------------------------------
# BUILD TABLE DATA
# -------------------------------------------------------------------------
# We want rows: y, c, i, h, etc.
# Columns: Standard Deviation, Relative Std Dev, Correlation with Output

variables_to_show = ["y", "c", "i", "h"] 
# Add productivity 'p' if available (y/h)
if "productivity" in names(df)
    push!(variables_to_show, "productivity")
end

table_data = Matrix{Any}(undef, length(variables_to_show), 4)

for (i, v) in enumerate(variables_to_show)
    mod_var = get(var_map, v, v) # Get model variable name
    
    # 1. Variable Name
    table_data[i, 1] = v
    
    # 2. Standard Deviation (in percent, so * 100)
    val_std = get_val("StdDev", mod_var) * 100
    table_data[i, 2] = @sprintf("%.2f", val_std)
    
    # 3. Relative Std Dev (sigma_x / sigma_y)
    if v == "y"
        table_data[i, 3] = "1.00"
    else
        val_rel = get_val("RelStdDev", mod_var)
        table_data[i, 3] = @sprintf("%.2f", val_rel)
    end
    
    # 4. Correlation with Y
    val_corr = get_val("CorrWithY", mod_var)
    table_data[i, 4] = @sprintf("%.2f", val_corr)
end

# -------------------------------------------------------------------------
# PRINT TABLE
# -------------------------------------------------------------------------
header = ["Variable", "Standard Deviation (%)", "Relative Std Dev", "Correlation with Y"]

println("\nTable 3: Standard Deviations and Correlations with Output (Model $target_model)")
pretty_table(table_data; header=header, crop=:none, alignment=:c)

# Optional: Save to LaTeX
latex_file = joinpath(results_path, "table_3_model_$(target_model).tex")
open(latex_file, "w") do f
    pretty_table(f, table_data; header=header, backend=Val(:latex))
end
println("\nLaTeX table saved to: $latex_file")