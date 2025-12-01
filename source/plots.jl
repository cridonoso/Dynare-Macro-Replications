"""
Module for generating standardized, publication-quality plots for the project.
Uses the PGFPlotsX backend for LaTeX rendering.

Supports English ('EN') and Spanish ('ES') languages.
"""
module Plotting

using Plots
using StatsPlots
using Printf
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
    titlefontsize = 12,
    legendfontsize = 10,
    tickfontsize = 8,
    guidefontsize = 10
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
    savefig(p, joinpath(results_dir, "hist_L_$(scenario_name)_$(lang).pdf"))
end

end # module Plotting