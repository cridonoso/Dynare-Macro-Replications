# Dynare Implementation of RBC/NK Models
## Macroeconomics II
### Computational Homework 2025

---

## 🚀 How to Run the Code

### Prerequisites
Ensure you have **Julia** installed along with the required packages.
This project uses a **local Julia environment**. To install all dependencies with the exact versions used during development, follow these steps:

Open the Julia REPL (Read-Eval-Print Loop) in the project root directory and run:
```julia
using Pkg
Pkg.activate(".")    # Activate the environment
Pkg.instantiate()    # Download and Install all dependencies from Manifest.toml
```
**Note on Package Loading:** In Julia, you only need to install packages once (instantiate). However, they are loaded into memory when you run the scripts. This keeps the environment clean and efficient.

### Running the Code

#### Question 1
To run Dynare, perform the Monte Carlo simulations, and generate the histograms for a specific model, run the following command from your terminal:
```bash
# Syntax: julia --project=. presentation/run_project_p1.jl --model <ID>
julia --project=. presentation/run_project_p1.jl --model 1
```
- Arguments: Youn can change `--model` to `2`, `3`, `4`, or `5`
- Output: This creates a folder in `results/p1/<ID>/` containing the `.log`, `moments_summary.csv`, and `histogram.png` files.

##### Generate LaTeX Tables
To generate the formatted statistics table (replicating Table 3 from Hansen & Wright) based on the simulation results:
```bash
# Syntax: julia --project=. presentation/generate_table.jl --model <ID>
julia --project=. presentation/generate_table.jl --model 1
```
- Output: This prints the table to the console and saves a `.tex` file in the `/results` folder.

#### Question 2
TBD

#### Question 3
TBD

## Project Structure
```
/root
├── Manifest.toml            # Lockfile for exact package versions
├── Project.toml             # Main package dependencies
├── presentation/
│   ├── run_project_p1.jl    # Main script: Runs Dynare, simulations, and plots
│   └── generate_table.jl    # Helper script: Generates formatted LaTeX tables
├── source/
│   ├── simulation.jl        # Core logic: Solution extraction, HP filter, moments
│   └── utils.jl             # Utilities: File management and cleanup
├── modfiles/
│   └── p1/                  # Dynare model files (1.mod to 5.mod)
└── results/
    └── p1/                  # Generated output (Logs, CSVs, PNGs, TeX)
```

## Authors
- Cristobal Donoso
- Roberto Flores
- Francisco Medina
- Nicolas Moreno