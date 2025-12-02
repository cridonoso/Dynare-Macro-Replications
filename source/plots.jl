"""
Module for generating standardized, publication-quality plots for the project.
Uses the PGFPlotsX backend for LaTeX rendering.

Supports English ('EN') and Spanish ('ES') languages.
"""
module Plotting

using Plots
using StatsPlots
using Printf
using DataFrames
using StatsBase

# --- Configuration ---
# Set the backend to PGFPlotsX for LaTeX integration.
pgfplotsx()

# Default plot settings for a consistent style.
default(
    framestyle = :box,
    grid = false,
    fontfamily = "Computer Modern",
    # Centralized font size configuration
    titlefontsize = 14,  # Título del gráfico
    legendfontsize = 11, # Leyenda
    tickfontsize = 9,    # Números en los ejes
    guidefontsize = 11   # Nombres de los ejes (X, Y)
)

"""
    plot_moments_histograms(model_id, var_name, rel_std_data, corr_data, results_dir)

Generates and saves a figure with two horizontal subplots:
1. Histogram of the relative standard deviation of a variable.
2. Histogram of the correlation of that variable with output.

Saves the output as a PDF file.

Args:
- `lang` (String): Language for the plot text ('EN' or 'ES').
"""
function plot_moments_histograms(lang, model_id, var_name, rel_std_data, corr_data, results_dir)
    # --- Language Dictionary ---
    labels = Dict(
        "EN" => (
            main_title = "Model $model_id: Moments for Variable `$var_name'",
            vol_title = "Volatility of $var_name relative to Y",
            corr_title = "Correlation of $var_name with Y",
            vol_xlabel = "Relative Std. Dev.",
            corr_xlabel = "Correlation"
        ),
        "ES" => (
            main_title = "Modelo $model_id: Momentos para la Variable `$var_name'",
            vol_title = "Volatilidad de $var_name relativa a Y",
            corr_title = "Correlación de $var_name con Y",
            vol_xlabel = "Desv. Estándar Relativa",
            corr_xlabel = "Correlación"
        )
    )
    txt = labels[lang]

    # Create a layout with two subplots side-by-side.
    # Added top_margin to prevent title overlap.
    p = plot(layout = (1, 2), size = (800, 350), legend=false, top_margin=10Plots.px)

    # --- Calculate y-axis limits to add headroom ---
    # Get histogram counts without plotting
    h1 = fit(Histogram, rel_std_data, nbins=50)
    h2 = fit(Histogram, corr_data, nbins=50)
    # Set upper limit to 110% of the max bar height
    ylims1 = (0, maximum(h1.weights) * 1.1)
    ylims2 = (0, maximum(h2.weights) * 1.1)

    # Subplot 1: Relative Standard Deviation
    histogram!(p[1], rel_std_data,
        bins = 50,
        alpha = 0.7,
        color = :dodgerblue,
        title = txt.vol_title,
        xlabel = txt.vol_xlabel,
        ylims = ylims1
    )

    # Subplot 2: Correlation with Output
    histogram!(p[2], corr_data,
        bins = 50,
        alpha = 0.7,
        color = :salmon,
        title = txt.corr_title,
        xlabel = txt.corr_xlabel,
        ylims = ylims2
    )

    # Add a main title to the entire figure.
    plot!(p, plot_title = txt.main_title)

    # Save the figure in vectorized PDF format.
    savefig(p, joinpath(results_dir, "hist_moments_$(var_name)_$(lang).pdf"))
end

"""
    plot_loss_histogram(model_name, scenario_name, loss_data, results_dir)

Generates and saves a histogram of the welfare loss (L).
Saves the output as a PDF file.

Args:
- `lang` (String): Language for the plot text ('EN' or 'ES').
"""
function plot_loss_histogram(lang, model_name, scenario_name, loss_data, results_dir)
    # --- Language and Name Mapping Dictionaries ---
    model_map = Dict(
        "gali_current" => Dict("EN" => "Current", "ES" => "Contemporánea"),
        "gali_forward" => Dict("EN" => "Forward Looking", "ES" => "Forward Looking")
    )
    scenario_map = Dict(
        "1_Technology" => Dict("EN" => "Technology Shock", "ES" => "Shock de Tecnología"),
        "2_Demand" => Dict("EN" => "Demand Shock", "ES" => "Shock de Demanda"),
        "3_Both" => Dict("EN" => "Both Shocks", "ES" => "Ambos Shock")
    )

    # Get the pretty names based on the selected language
    pretty_model_name = model_map[model_name][lang]
    pretty_scenario_name = scenario_map[scenario_name][lang]

    labels = Dict(
        "EN" => (
            main_title = "Model: $pretty_model_name",
            dist_title = "Welfare Loss Distribution: $pretty_scenario_name",
            xlabel = "Loss (L)"
        ),
        "ES" => (
            main_title = "Modelo: $pretty_model_name",
            dist_title = "Distribución de Pérdida de Bienestar: $pretty_scenario_name",
            xlabel = "Pérdida (L)"
        )
    )
    txt = labels[lang]

    # --- Calculate y-axis limits to add headroom ---
    if !isempty(loss_data)
        h = fit(Histogram, loss_data, nbins=50)
        ylims_with_margin = (0, maximum(h.weights) * 1.1)
    else
        ylims_with_margin = (0, 1) # Default if no data
    end

    p = histogram(loss_data,
        bins = 50, legend = false, alpha = 0.7, color = :blue,
        title = txt.dist_title,
        xlabel = txt.xlabel, 
        plot_title = txt.main_title,
        ylims = ylims_with_margin,
        size = (800, 400), # Adjusted size for better spacing
        top_margin = 10Plots.px)
    
    # CORRECCIÓN: Incluir el nombre del modelo en el nombre del archivo para evitar sobrescribir.
    savefig(p, joinpath(results_dir, "hist_L_$(model_name)_$(scenario_name)_$(lang).pdf"))
end

"""
    plot_loss_comparison(lang, scenario_name, data_current, data_forward, results_dir)

Generates a side-by-side comparison of welfare loss histograms for
current-looking and forward-looking policy rules.

Args:
- `lang` (String): Language for the plot text ('EN' or 'ES').
- `scenario_name` (String): The name of the shock scenario.
- `data_current` (Vector): Loss data for the current-looking rule.
- `data_forward` (Vector): Loss data for the forward-looking rule.
- `results_dir` (String): The path to save the plot.
"""
function plot_loss_comparison(lang, scenario_name, data_current, data_forward, results_dir)
    # --- Language and Name Mapping Dictionaries ---
    scenario_map = Dict(
        "1_Technology" => Dict("EN" => "Technology Shock", "ES" => "Shock de Tecnología"),
        "2_Demand" => Dict("EN" => "Demand Shock", "ES" => "Shock de Demanda"),
        "3_Both" => Dict("EN" => "Both Shocks", "ES" => "Ambos Shocks")
    )
    pretty_scenario_name = scenario_map[scenario_name][lang]

    labels = Dict(
        "EN" => (
            main_title = "Welfare Loss Distribution: $pretty_scenario_name",
            title_current = "Current-Looking Rule",
            title_forward = "Forward-Looking Rule",
            xlabel = "Loss (L)"
        ),
        "ES" => (
            main_title = "Distribución de Pérdida de Bienestar: $pretty_scenario_name",
            title_current = "Regla Contemporánea",
            title_forward = "Regla Forward-Looking",
            xlabel = "Pérdida (L)"
        )
    )
    txt = labels[lang]

    # --- Plot Generation: Overlaid Histograms ---
    p = plot(
        title = txt.main_title,
        xlabel = txt.xlabel,
        ylabel = lang == "EN" ? "Density" : "Densidad",
        legend = :topright,
        size = (600, 400), # Tamaño reducido para mejor proporción en LaTeX
        top_margin = 10Plots.px
    )

    # Histograma 1: Regla Contemporánea
    histogram!(p, data_current,
        normalize = :pdf,
        bins = 50,
        alpha = 0.6,
        color = :dodgerblue,
        label = txt.title_current
    )

    # Histograma 2: Regla Forward-Looking (superpuesto)
    histogram!(p, data_forward,
        normalize = :pdf,
        bins = 50,
        alpha = 0.6,
        color = :salmon,
        label = txt.title_forward
    )

    # Save the figure
    savefig(p, joinpath(results_dir, "hist_comparison_$(scenario_name)_$(lang).pdf"))
end

"""
    plot_statistic_histogram(lang, model_id, stat_name, stat_data, us_value, results_dir)

Generates and saves a histogram for a single model statistic from a Monte Carlo simulation,
and overlays a vertical line for the corresponding U.S. data value.

Args:
- `lang` (String): Language for the plot text ('EN' or 'ES').
- `model_id` (String): The ID of the model being plotted.
- `stat_name` (String): The internal name of the statistic (e.g., "sigma_y").
- `stat_data` (Vector): The vector of data from the Monte Carlo simulation.
- `us_value` (Float64): The reference value from U.S. data.
- `results_dir` (String): The path to save the plot.
"""
function plot_statistic_histogram(lang, model_id, stat_name, stat_data, us_value, results_dir)
    # --- Language and Label Dictionary ---
    stat_labels = Dict(
        "sigma_y" => ("Volatility of Output (σ_y)", "Volatilidad del Producto (σ_y)"),
        "rel_sigma_c" => ("Relative Volatility Consumption (σ_c/σ_y)", "Volatilidad Relativa Consumo (σ_c/σ_y)"),
        "rel_sigma_i" => ("Relative Volatility Investment (σ_i/σ_y)", "Volatilidad Relativa Inversión (σ_i/σ_y)"),
        "rel_sigma_h" => ("Relative Volatility Hours (σ_h/σ_y)", "Volatilidad Relativa Horas (σ_h/σ_y)"),
        "rel_sigma_p" => ("Relative Volatility Productivity (σ_p/σ_y)", "Volatilidad Relativa Productividad (σ_p/σ_y)"),
        "rel_sigma_h_p" => ("Rel. Vol. Hours vs Prod (σ_h/σ_p)", "Vol. Rel. Horas vs Prod (σ_h/σ_p)"),
        "corr_h_p" => ("Correlation (Hours, Productivity)", "Correlación (Horas, Productividad)")
    )

    labels = Dict(
        "EN" => (
            model_dist = "Model Distribution",
            us_data = "U.S. Data"
        ),
        "ES" => (
            model_dist = "Distribución del Modelo",
            us_data = "Dato EE.UU."
        )
    )
    txt = labels[lang]
    plot_title = lang == "EN" ? stat_labels[stat_name][1] : stat_labels[stat_name][2]

    # --- Plot Generation ---
    p = histogram(stat_data,
        normalize = :pdf,
        label = txt.model_dist,
        title = plot_title,
        color = :dodgerblue,
        alpha = 0.7,
        legend = :topright,
        size = (600, 400) # Standard size
    )

    # Add vertical line for U.S. data
    vline!([us_value], label=txt.us_data, color=:red, linewidth=2)

    # Save the figure
    plot_path = joinpath(results_dir, "plots")
    mkpath(plot_path)
    savefig(p, joinpath(plot_path, "hist_$(stat_name)_$(lang).pdf"))
end

"""
    plot_simulation_timeseries(lang, model_id, df_sim, results_dir)

Generates and saves a figure with subplots for each time series in the simulation data.

Args:
- `lang` (String): Language for the plot text ('EN' or 'ES').
- `model_id` (String): The ID of the model being plotted.
- `df_sim` (DataFrame): DataFrame containing the time series data, one variable per column.
- `results_dir` (String): The path to save the plot.
"""
function plot_simulation_timeseries(lang, model_id, df_sim, results_dir)
    # --- Language and Label Dictionary ---
    var_labels = Dict(
        "y" => ("Output (y)", "Producto (y)"),
        "c" => ("Consumption (c)", "Consumo (c)"),
        "invest" => ("Investment (i)", "Inversión (i)"),
        "k" => ("Capital (k)", "Capital (k)"),
        "h" => ("Hours (h)", "Horas (h)"),
        "lambda" => ("TFP (λ)", "PTF (λ)"),
        "productivity" => ("Productivity (y/h)", "Productividad (y/h)")
    )

    labels = Dict(
        "EN" => (main_title = "Model $model_id: Single Simulation (200 periods)", xlabel = "Period"),
        "ES" => (main_title = "Modelo $model_id: Simulación Única (200 periodos)", xlabel = "Periodo")
    )
    txt = labels[lang]

    # --- Plot Generation ---
    num_vars = ncol(df_sim)
    # Usamos un layout flexible, por ejemplo, 2 columnas
    layout_cols = 2
    layout_rows = ceil(Int, num_vars / layout_cols)
    
    p = plot(layout = (layout_rows, layout_cols), 
             size = (layout_cols * 400, layout_rows * 250), 
             legend = false,
             plot_title = txt.main_title)

    for (i, col_name) in enumerate(names(df_sim))
        plot_title = ""
        if haskey(var_labels, col_name)
            plot_title = lang == "EN" ? var_labels[col_name][1] : var_labels[col_name][2]
        end
        
        plot!(p[i], df_sim[!, col_name], title=plot_title, xlabel=txt.xlabel)
    end

    # CORRECCIÓN: Ocultar los subplots vacíos si el número de variables es impar.
    for i in (num_vars + 1):(layout_rows * layout_cols)
        plot!(p[i], framestyle=:none)
    end

    # Save the figure
    plot_path = joinpath(results_dir, "plots")
    mkpath(plot_path)
    savefig(p, joinpath(plot_path, "timeseries_simulation_$(lang).pdf"))
end

end # module Plotting