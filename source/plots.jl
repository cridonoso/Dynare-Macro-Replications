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
    titlefontsize = 14,
    legendfontsize = 12,
    tickfontsize = 10,
    guidefontsize = 12
)

"""
    plot_moments_histograms(lang, model_id, var_name, rel_std_data, corr_data, results_dir)
"""
function plot_moments_histograms(lang, model_id, var_name, rel_std_data, corr_data, results_dir)
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

    p = plot(layout = (1, 2), size = (800, 350), legend=false, top_margin=10Plots.px)

    h1 = fit(Histogram, rel_std_data, nbins=50)
    h2 = fit(Histogram, corr_data, nbins=50)
    ylims1 = (0, maximum(h1.weights) * 1.1)
    ylims2 = (0, maximum(h2.weights) * 1.1)

    histogram!(p[1], rel_std_data, bins=50, alpha=0.7, color=:dodgerblue, title=txt.vol_title, xlabel=txt.vol_xlabel, ylims=ylims1)
    histogram!(p[2], corr_data, bins=50, alpha=0.7, color=:salmon, title=txt.corr_title, xlabel=txt.corr_xlabel, ylims=ylims2)

    plot!(p, plot_title = txt.main_title)
    savefig(p, joinpath(results_dir, "hist_moments_$(var_name)_$(lang).pdf"))
end

"""
    plot_loss_histogram(lang, model_name, scenario_name, loss_data, results_dir)
"""
function plot_loss_histogram(lang, model_name, scenario_name, loss_data, results_dir)
    model_map = Dict("gali_current" => Dict("EN" => "Current", "ES" => "Contemporánea"), "gali_forward" => Dict("EN" => "Forward Looking", "ES" => "Forward Looking"))
    scenario_map = Dict("1_Technology" => Dict("EN" => "Technology Shock", "ES" => "Shock de Tecnología"), "2_Demand" => Dict("EN" => "Demand Shock", "ES" => "Shock de Demanda"), "3_Both" => Dict("EN" => "Both Shocks", "ES" => "Ambos Shock"))

    pretty_model = model_map[model_name][lang]
    pretty_scenario = scenario_map[scenario_name][lang]

    labels = Dict(
        "EN" => (main_title = "Model: $pretty_model", dist_title = "Welfare Loss Distribution: $pretty_scenario", xlabel = "Loss (L)"),
        "ES" => (main_title = "Modelo: $pretty_model", dist_title = "Distribución de Pérdida de Bienestar: $pretty_scenario", xlabel = "Pérdida (L)")
    )
    txt = labels[lang]

    h = isempty(loss_data) ? fit(Histogram, [0.0], nbins=1) : fit(Histogram, loss_data, nbins=50)
    ylims_margin = (0, maximum(h.weights) * 1.1)

    p = histogram(loss_data, bins=50, legend=false, alpha=0.7, color=:blue, title=txt.dist_title, xlabel=txt.xlabel, plot_title=txt.main_title, ylims=ylims_margin, size=(800, 400), top_margin=10Plots.px)
    savefig(p, joinpath(results_dir, "hist_L_$(model_name)_$(scenario_name)_$(lang).pdf"))
end

"""
    plot_loss_comparison(lang, scenario_name, data_current, data_forward, results_dir)
"""
function plot_loss_comparison(lang, scenario_name, data_current, data_forward, results_dir)
    scenario_map = Dict("1_Technology" => Dict("EN" => "Technology Shock", "ES" => "Shock de Tecnología"), "2_Demand" => Dict("EN" => "Demand Shock", "ES" => "Shock de Demanda"), "3_Both" => Dict("EN" => "Both Shocks", "ES" => "Ambos Shocks"))
    pretty_scenario = scenario_map[scenario_name][lang]

    labels = Dict(
        "EN" => (main_title = "Welfare Loss Distribution: $pretty_scenario", title_current = "Current-Looking Rule", title_forward = "Forward-Looking Rule", xlabel = "Loss (L)"),
        "ES" => (main_title = "Distribución de Pérdida de Bienestar: $pretty_scenario", title_current = "Regla Contemporánea", title_forward = "Regla Forward-Looking", xlabel = "Pérdida (L)")
    )
    txt = labels[lang]

    p = plot(title=txt.main_title, xlabel=txt.xlabel, ylabel=lang=="EN" ? "Density" : "Densidad", legend=:topright, size=(600, 400), top_margin=10Plots.px)
    histogram!(p, data_current, normalize=:pdf, bins=50, alpha=0.6, color=:dodgerblue, label=txt.title_current)
    histogram!(p, data_forward, normalize=:pdf, bins=50, alpha=0.6, color=:salmon, label=txt.title_forward)
    savefig(p, joinpath(results_dir, "hist_comparison_$(scenario_name)_$(lang).pdf"))
end

"""
    plot_statistic_histogram(lang, model_id, stat_name, stat_data, us_value, results_dir)
"""
function plot_statistic_histogram(lang, model_id, stat_name, stat_data, us_value, results_dir)
    stat_labels = Dict(
        "sigma_y" => ("Volatility of Output (σ_y)", "Volatilidad del Producto (σ_y)"),
        "rel_sigma_c" => ("Relative Volatility Consumption (σ_c/σ_y)", "Volatilidad Relativa Consumo (σ_c/σ_y)"),
        "rel_sigma_i" => ("Relative Volatility Investment (σ_i/σ_y)", "Volatilidad Relativa Inversión (σ_i/σ_y)"),
        "rel_sigma_h" => ("Relative Volatility Hours (σ_h/σ_y)", "Volatilidad Relativa Horas (σ_h/σ_y)"),
        "rel_sigma_p" => ("Relative Volatility Productivity (σ_p/σ_y)", "Volatilidad Relativa Productividad (σ_p/σ_y)"),
        "rel_sigma_h_p" => ("Rel. Vol. Hours vs Prod (σ_h/σ_p)", "Vol. Rel. Horas vs Prod (σ_h/σ_p)"),
        "corr_h_p" => ("Correlation (Hours, Productivity)", "Correlación (Horas, Productividad)")
    )
    labels = Dict("EN" => (model_dist="Model Distribution", us_data="U.S. Data"), "ES" => (model_dist="Distribución del Modelo", us_data="Dato EE.UU."))
    txt = labels[lang]
    plot_title = lang == "EN" ? stat_labels[stat_name][1] : stat_labels[stat_name][2]

    p = histogram(stat_data, normalize=:pdf, label=txt.model_dist, title=plot_title, color=:dodgerblue, alpha=0.7, legend=:topright, size=(600, 400))
    vline!([us_value], label=txt.us_data, color=:red, linewidth=2)
    
    plot_path = joinpath(results_dir, "plots")
    mkpath(plot_path)
    savefig(p, joinpath(plot_path, "hist_$(stat_name)_$(lang).pdf"))
end


"""
    plot_simulation_timeseries(lang, model_id, df_sim, results_dir)
"""
function plot_simulation_timeseries(lang, model_id, df_sim, results_dir)
    var_labels = Dict(
        "y" => ("Output (y)", "Producto (y)"), "c" => ("Consumption (c)", "Consumo (c)"),
        "invest" => ("Investment (i)", "Inversión (i)"), "k" => ("Capital (k)", "Capital (k)"),
        "h" => ("Hours (h)", "Horas (h)"), "lambda" => ("TFP (λ)", "PTF (λ)"),
        "productivity" => ("Productivity (y/h)", "Productividad (y/h)")
    )
    labels = Dict(
        "EN" => (main_title="Model $model_id: Single Simulation (200 periods)", xlabel="Period"),
        "ES" => (main_title="Modelo $model_id: Simulación Única (200 periodos)", xlabel="Periodo")
    )
    txt = labels[lang]

    num_vars = ncol(df_sim)
    layout_cols = 2
    layout_rows = ceil(Int, num_vars / layout_cols)
    
    p = plot(layout=(layout_rows, layout_cols), size=(layout_cols*400, layout_rows*250), legend=false, plot_title=txt.main_title)

    for (i, col_name) in enumerate(names(df_sim))
        plot_title = haskey(var_labels, col_name) ? (lang=="EN" ? var_labels[col_name][1] : var_labels[col_name][2]) : ""
        plot!(p[i], df_sim[!, col_name], title=plot_title, xlabel=txt.xlabel)
    end
    for i in (num_vars + 1):(layout_rows * layout_cols)
        plot!(p[i], framestyle=:none)
    end

    plot_path = joinpath(results_dir, "plots")
    mkpath(plot_path)
    savefig(p, joinpath(plot_path, "timeseries_simulation_$(lang).pdf"))
end


"""
    plot_combined_histograms(lang, data_dict, output_dir)

Genera una figura con subplots (3 filas x 2 columnas) comparando las DENSIDADES.
Incluye una leyenda compartida única en la parte inferior.
"""
function plot_combined_histograms(lang, data_dict, output_dir)
    # 1. Variables a Graficar
    vars_config = [
        ("sigma_y",       "Output Volatility (σ_y)", "Volatilidad Producto (σ_y)"),
        ("rel_sigma_c",   "Rel. Vol. Cons. (σ_c/σ_y)", "Vol. Rel. Consumo (σ_c/σ_y)"),
        ("rel_sigma_i",   "Rel. Vol. Inv. (σ_i/σ_y)", "Vol. Rel. Inversión (σ_i/σ_y)"),
        ("rel_sigma_h",   "Rel. Vol. Hours (σ_h/σ_y)", "Vol. Rel. Horas (σ_h/σ_y)"),
        ("rel_sigma_h_p", "Rel. Vol. H/P (σ_h/σ_p)", "Vol. Rel. H/P (σ_h/σ_p)"),
        ("corr_h_p",      "Corr(Hours, Prod)", "Corr(Horas, Prod)")
    ]

    models_list = sort(collect(keys(data_dict))) 
    colors = [:black, :blue, :green, :orange, :red] 
    txt_legend = lang == "EN" ? "Model" : "Modelo"
    
    # 2. Crear los 6 Subplots de Datos (SIN leyenda)
    subplots = []
    
    for (var_code, title_en, title_es) in vars_config
        p = plot(title = (lang == "EN" ? title_en : title_es))
        
        # Calcular límites eje X
        all_values = Float64[]
        for m in models_list
            append!(all_values, data_dict[m][!, var_code])
        end
        lo, hi = quantile(all_values, [0.005, 0.995])
        span = hi - lo
        xlims_calc = (lo - 0.1*span, hi + 0.1*span)

        # Plotear Densidades
        for (idx, m) in enumerate(models_list)
            data = data_dict[m][!, var_code]
            
            density!(p, data, 
                label = "", # Sin etiqueta aquí (usaremos la compartida)
                linewidth = 2.5,
                linecolor = colors[idx],
                color = colors[idx],
                fill = false,
                alpha = 0.9
            )
        end
        
        # Ajustes del subplot
        plot!(p, 
            xlims=xlims_calc, 
            ylabel = (lang == "EN" ? "Density" : "Densidad"),
            xlabel = "",
            legend = false # <--- Desactivamos leyenda individual
        )
        push!(subplots, p)
    end

    # 3. Crear el Gráfico de Leyenda Compartida (Dummy Plot)
    # Este gráfico está vacío de datos pero contiene las etiquetas para la leyenda
    legend_plot = plot(framestyle=:none, grid=false, showaxis=false, 
                       legend=:top, legend_columns=5, # 5 columnas para ponerlos en fila horizontal
                       top_margin=0Plots.mm, bottom_margin=0Plots.mm)
    
    for (idx, m) in enumerate(models_list)
        # Líneas invisibles o fuera de rango solo para generar la entrada en la leyenda
        plot!(legend_plot, [0], [0], 
              label="$txt_legend $m", 
              linewidth=2.5, 
              linecolor=colors[idx], 
              color=colors[idx])
    end

    # 4. Definir Layout y Combinar
    # layout: Grid de 3x2 arriba, y la leyenda (dummy) ocupando el 5% de altura abajo
    l = @layout [
        grid(3, 2)
        a{0.1h}  # <-- AUMENTADO: Darle 10% de altura a la leyenda
    ]

    final_plot = plot(subplots..., legend_plot, 
        layout = l, 
        size = (800, 900),
        margin = 5Plots.mm
    )

    # 5. Guardar
    fname = joinpath(output_dir, "densities_comparison_$(lang).pdf")
    savefig(final_plot, fname)
    println("    -> Gráfico de densidades guardado: $fname")
end

function plot_scatter_hp(lang, h_data, p_data, model_id, output_dir)
    labels = Dict(
        "EN" => (title = "Model $model_id: Hours vs Productivity", xlabel = "Hours (%)", ylabel = "Productivity (%)"),
        "ES" => (title = "Modelo $model_id: Horas vs Productividad", xlabel = "Horas (%)", ylabel = "Productividad (%)")
    )
    txt = labels[lang]
    p = scatter(h_data, p_data, title=txt.title, xlabel=txt.xlabel, ylabel=txt.ylabel, legend=false,
        color=:black, markersize=2, markerstrokewidth=0, alpha=0.6)
    hline!(p, [0], color=:grey, linestyle=:dash, alpha=0.5)
    vline!(p, [0], color=:grey, linestyle=:dash, alpha=0.5)
    savefig(p, joinpath(output_dir, "scatter_h_p_$(lang).pdf"))
end

"""
    plot_loss_comparison(lang, scenario_name, data_current, data_forward, output_dir)
    
    Genera histograma individual para un escenario.
"""
function plot_loss_comparison(lang, scenario_name, data_current, data_forward, output_dir)
    titles = Dict(
        "1_Technology" => Dict("EN" => "Technology Shock", "ES" => "Shock Tecnológico"),
        "2_Demand"     => Dict("EN" => "Demand Shock", "ES" => "Shock de Demanda"),
        "3_Both"       => Dict("EN" => "Both Shocks", "ES" => "Ambos Shocks")
    )
    
    labels = Dict(
        "EN" => (title="Welfare Loss Distribution", xlabel="Loss (L)", m1="Current-Looking", m2="Forward-Looking"),
        "ES" => (title="Distribución de Pérdida de Bienestar", xlabel="Pérdida (L)", m1="Regla Contemporánea", m2="Regla Forward-Looking")
    )
    
    scen_title = get(titles, scenario_name, Dict("EN"=>scenario_name, "ES"=>scenario_name))[lang]
    txt = labels[lang]

    p = plot(title="$(txt.title): $scen_title", xlabel=txt.xlabel, ylabel=(lang=="EN" ? "Density" : "Densidad"))
    
    density!(p, data_current, label=txt.m1, color=:dodgerblue, linewidth=2.5, fill=true, alpha=0.3)
    density!(p, data_forward, label=txt.m2, color=:orange, linewidth=2.5, fill=true, alpha=0.3)
    
    fname = joinpath(output_dir, "hist_comparison_$(scenario_name)_$(lang).pdf")
    savefig(p, fname)
    println("    -> Gráfico individual guardado: $fname")
end

"""
    plot_p3_combined_histograms(lang, all_data, scenarios_list, output_dir)

Genera una figura combinada (1 fila x 3 columnas) con LEYENDA COMPARTIDA.
CORREGIDO: Ajuste de altura para evitar error 'Plot height too small' en PGFPlots.
"""
function plot_p3_combined_histograms(lang, all_data, scenarios_list, output_dir)
    titles_map = Dict(
        "1_Technology" => Dict("EN" => "Technology Shock", "ES" => "Shock Tecnológico"),
        "2_Demand"     => Dict("EN" => "Demand Shock", "ES" => "Shock de Demanda"),
        "3_Both"       => Dict("EN" => "Both Shocks", "ES" => "Ambos Shocks")
    )
    
    model_labels = Dict(
        "gali_current" => Dict("EN" => "Current-Looking", "ES" => "Regla Contemporánea"),
        "gali_forward" => Dict("EN" => "Forward-Looking", "ES" => "Regla Forward-Looking")
    )

    colors = Dict("gali_current" => :dodgerblue, "gali_forward" => :orange)
    subplots = []

    # 1. Generar los 3 Subplots (SIN LEYENDA)
    for (scen_id, scen_key) in scenarios_list
        t = titles_map[scen_key][lang]
        
        # legend=false para no repetir la caja en cada gráfico
        p = plot(title = t, titlefontsize = 11, legend = false) 
        
        scen_data = get(all_data, scen_id, Dict())
        
        for m in ["gali_current", "gali_forward"]
            vals = get(scen_data, m, Float64[])
            if !isempty(vals)
                density!(p, vals, 
                    label = model_labels[m][lang], 
                    color = colors[m], 
                    linewidth = 2.5, 
                    alpha = 0.4,
                    fill = true 
                )
            end
        end
        
        plot!(p, xlabel=(lang=="EN" ? "Loss (L)" : "Pérdida (L)"), yticks=:auto, ylabel="")
        push!(subplots, p)
    end

    # 2. Crear Gráfico "Fantasma" para la Leyenda
    # CORRECCIÓN: axis=false, ticks=false explícitos para evitar cálculos de PGFPlots
    legend_plot = plot(framestyle=:none, grid=false, axis=false, ticks=false,
                       legend=:top, legend_columns=2, label="",
                       top_margin=0Plots.mm, bottom_margin=0Plots.mm)
    
    # Líneas dummy para generar la leyenda
    for m in ["gali_current", "gali_forward"]
        plot!(legend_plot, [0], [0], 
              label=model_labels[m][lang], 
              color=colors[m], 
              linewidth=2.5, 
              fill=true, alpha=0.4) 
    end

    # 3. Combinar con Layout Ajustado
    l = @layout [
        grid(1, 3)
        a{0.15h}  
    ]

    # CORRECCIÓN: Aumentamos altura total a 550px
    final_plot = plot(subplots..., legend_plot, 
        layout = l, 
        size = (1200, 550), 
        margin = 5Plots.mm
    )
    
    fname = joinpath(output_dir, "p3_combined_histograms_$(lang).pdf")
    savefig(final_plot, fname)
    println("    -> Gráfico combinado guardado: $fname")
end

# Función Scatter P1 (Mantenida por compatibilidad)
function plot_scatter_hp(lang, h_data, p_data, model_id, output_dir)
    labels = Dict(
        "EN" => (title = "Model $model_id: Hours vs Productivity", xlabel = "Hours (%)", ylabel = "Productivity (%)"),
        "ES" => (title = "Modelo $model_id: Horas vs Productividad", xlabel = "Horas (%)", ylabel = "Productividad (%)")
    )
    txt = labels[lang]
    p = scatter(h_data, p_data, title=txt.title, xlabel=txt.xlabel, ylabel=txt.ylabel, legend=false,
        color=:black, markersize=2, markerstrokewidth=0, alpha=0.6)
    hline!(p, [0], color=:grey, linestyle=:dash, alpha=0.5)
    vline!(p, [0], color=:grey, linestyle=:dash, alpha=0.5)
    savefig(p, joinpath(output_dir, "scatter_h_p_$(lang).pdf"))
end

end # module