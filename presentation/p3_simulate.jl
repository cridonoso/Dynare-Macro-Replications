# Nombre: p3_simulate.jl
# Tarea:  Ejecuta la simulación y genera los resultados para la Parte III del proyecto.

using Dynare
using Printf
using CSV
using DataFrames
using Statistics

# --- Configuration ---
project_root = joinpath(@__DIR__, "..")
source_dir   = joinpath(project_root, "source")
N_SIMULATIONS = 10000
T_PERIODS     = 200
siggma = 1.0  
alppha = 0.25
epsilon = 9.0 
theta = 0.75
LANGUAGE = "ES" # Options: "EN" or "ES"
MODELS = ["gali_current", "gali_forward"] 

# --- Load Utilities ---
include(joinpath(source_dir, "utils.jl"))
include(joinpath(source_dir, "simulation.jl"))
include(joinpath(source_dir, "loss.jl"))
include(joinpath(source_dir, "plots.jl"))
using .Plotting

"""
    generate_table_4_1(models, project_root, Wy, Wpi)

Ítem 2: Replica la Tabla 4.1 de Galí (2015) calculando los momentos teóricos.
"""
function generate_table_4_1(models, project_root, Wy, Wpi)
    println("\n--- [Ítem 2] Generando Tabla 4.1 (Momentos Teóricos) ---")
    results_path = joinpath(project_root, "results", "p3", "2")
    mkpath(results_path)

    table_data = []
    for model_name in models
        mod_path = joinpath(project_root, "modfiles", "p3", model_name * ".mod")
        if !isfile(mod_path) continue end

        context = eval(:(@dynare $mod_path))

        res = context.results.model_results[1]
        lre_sol = res.linearrationalexpectations
        var_matrix = lre_sol.endogenous_variance

        # Obtener los índices de las variables desde la tabla de símbolos
        sym = context.symboltable
        idx_ygap = sym["y_gap"].orderintype
        idx_pi = sym["pi"].orderintype

        var_y_gap = var_matrix[idx_ygap, idx_ygap]
        var_pi = var_matrix[idx_pi, idx_pi]
        
        # Calcular pérdida de bienestar teórica
        loss = 0.5 * (Wy * var_y_gap + Wpi * var_pi)
        
        push!(table_data, (model=model_name, sigma_y=sqrt(var_y_gap), sigma_pi=sqrt(var_pi), loss=loss))
    end

    # Generar tabla LaTeX (simplificada)
    latex_str = raw"""
    \begin{table}[h!]
    \centering
    \caption{Theoretical Moments and Welfare Loss}
    \label{tab:p3_table41}
    \begin{tabular}{l c c}
    \hline\hline
    & \textbf{Current-Looking} & \textbf{Forward-Looking} \\
    \hline
    $\sigma(\tilde{y})$ & """ * @sprintf("%.2f", table_data[1].sigma_y) * raw""" & """ * @sprintf("%.2f", table_data[2].sigma_y) * raw""" \\
    $\sigma(\pi)$ & """ * @sprintf("%.2f", table_data[1].sigma_pi) * raw""" & """ * @sprintf("%.2f", table_data[2].sigma_pi) * raw""" \\
    Welfare Loss & """ * @sprintf("%.4f", table_data[1].loss) * raw""" & """ * @sprintf("%.4f", table_data[2].loss) * raw""" \\
    \hline\hline
    \end{tabular}
    \end{table}
    """
    
    tex_path = joinpath(results_path, "table_4_1.tex")
    open(tex_path, "w") do f; write(f, latex_str); end
    println(">>> Tabla 4.1 (LaTeX) guardada en: $tex_path")
end

"""
    run_loss_simulations(models, project_root, Wy, Wpi, scenarios, plot_only)

Ítems 3, 4, 5: Ejecuta simulaciones de Monte Carlo para cada escenario de shock y
genera histogramas de la pérdida de bienestar.
"""
function run_loss_simulations(models, project_root, Wy, Wpi, scenarios, plot_only)
    println("\n--- [Ítems 3-5] Ejecutando Simulaciones de Pérdida de Bienestar ---")

    for (scen_id, scen_name, mask) in scenarios
        println("\n>>> Procesando Escenario: $scen_name")
        results_path = joinpath(project_root, "results", "p3", scen_id)
        mkpath(results_path)

        # Diccionario para almacenar los datos de pérdida de cada modelo
        loss_data_dict = Dict{String, Vector{Float64}}()

        for model_name in models
            mod_path = joinpath(project_root, "modfiles", "p3", model_name * ".mod")
            if !isfile(mod_path) continue end

            raw_data_path = joinpath(results_path, "raw_loss_$(model_name).csv")

            if !plot_only
                println("  -> Simulación para el modelo: $model_name")
                context = eval(:(@dynare $mod_path))
                sol = extract_solution(context)
                
                idx_ygap = findfirst(x -> x == "y_gap", sol.endo_names)
                idx_pi   = findfirst(x -> x == "pi", sol.endo_names)

                function calculate_loss(sim_dev, sim_lvl)
                    series_y = sim_dev[:, idx_ygap]
                    series_pi = sim_dev[:, idx_pi]
                    return 0.5 * (Wy * var(series_y) + Wpi * var(series_pi))
                end

                loss_results = monte_carlo_generic(sol, calculate_loss; 
                                                      N=N_SIMULATIONS, 
                                                      T=T_PERIODS, 
                                                      shock_mask=mask)
                
                losses = Float64.(loss_results)
                loss_data_dict[model_name] = losses
                CSV.write(raw_data_path, DataFrame(Loss=losses))
                println("     -> Datos de pérdida guardados en: $raw_data_path")
            end

            # Cargar datos si estamos en modo --plot-only
            if isfile(raw_data_path)
                df_raw = CSV.read(raw_data_path, DataFrame)
                loss_data_dict[model_name] = df_raw.Loss
            end
        end

        # --- Generar Gráfico Comparativo ---
        if haskey(loss_data_dict, "gali_current") && haskey(loss_data_dict, "gali_forward")
            println("  -> Generando gráfico comparativo para el escenario: $scen_name")
            Plotting.plot_loss_comparison(LANGUAGE, scen_name, loss_data_dict["gali_current"], loss_data_dict["gali_forward"], results_path)
        else
            println("     ERROR: Faltan datos para generar el gráfico comparativo. Ejecuta la simulación completa.")
        end
    end
end

"""
    generate_summary_table(models, project_root, scenarios)

Ítem 6: Genera una tabla LaTeX resumiendo la pérdida de bienestar promedio
en todos los escenarios.
"""
function generate_summary_table(models, project_root, scenarios)
    println("\n--- [Ítem 6] Generando Tabla Resumen de Pérdidas ---")
    results_path = joinpath(project_root, "results", "p3", "6")
    mkpath(results_path)

    summary_data = Dict()

    for (scen_id, scen_name, _) in scenarios
        scen_path = joinpath(project_root, "results", "p3", scen_id)
        for model_name in models
            raw_data_path = joinpath(scen_path, "raw_loss_$(model_name).csv")
            if isfile(raw_data_path)
                df = CSV.read(raw_data_path, DataFrame)
                mean_loss = mean(df.Loss)
                summary_data[(scen_name, model_name)] = mean_loss
            end
        end
    end

    # Generar tabla LaTeX
    latex_str = raw"""
    \begin{table}[h!]
    \centering
    \caption{Average Welfare Loss Across Shock Scenarios}
    \label{tab:p3_summary}
    \begin{tabular}{l c c}
    \hline\hline
    \textbf{Shock Scenario} & \textbf{Current-Looking Rule} & \textbf{Forward-Looking Rule} \\
    \hline
    """
    for (_, scen_name, _) in scenarios
        loss_current = summary_data[(scen_name, "gali_current")]
        loss_forward = summary_data[(scen_name, "gali_forward")]
        latex_str *= @sprintf("    %s & %.4f & %.4f \\\\\n", scen_name, loss_current, loss_forward)
    end
    latex_str *= raw"""
    \hline\hline
    \end{tabular}
    \end{table}
    """

    tex_path = joinpath(results_path, "summary_table.tex")
    open(tex_path, "w") do f; write(f, latex_str); end
    println(">>> Tabla resumen (LaTeX) guardada en: $tex_path")
end

# ==============================================================================
# --- SCRIPT PRINCIPAL ---
# ==============================================================================

function main()
    plot_only_mode = "--plot-only" in ARGS
    if plot_only_mode
        println("--- Ejecutando en MODO GRÁFICOS. Se omitirán las simulaciones. ---")
    end

    # Parámetros de Galí (2015)
    varphi = 5.0 # Usado para los pesos de la función de pérdida
    Wy, Wpi = get_weights(alppha, epsilon, theta, varphi)

    # Definición de escenarios
    scenarios = [
        ("3", "1_Technology", [1.0, 0.0]), # Ítem 3
        ("4", "2_Demand",     [0.0, 1.0]), # Ítem 4
        ("5", "3_Both",       [1.0, 1.0])  # Ítem 5
    ]

    # --- Ejecutar cada ítem ---
    if !plot_only_mode
        generate_table_4_1(MODELS, project_root, Wy, Wpi)
    end
    
    run_loss_simulations(MODELS, project_root, Wy, Wpi, scenarios, plot_only_mode)

    generate_summary_table(MODELS, project_root, scenarios)

    println("\n>>> Proceso de la Parte III completado.")
end

main()