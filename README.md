# Dynare Implementation of RBC/NK Models
## Macroeconomics II
### Computational Homework 2025

---

## 🚀 How to Run the Code

### 1. Prerequisites
Ensure you have **Julia** installed along with the required packages.
This project uses a **local Julia environment**. To install all dependencies with the exact versions used during development, run:
Open the Julia REPL (Read-Eval-Print Loop) and run:
```julia
using Pkg
Pkg.activate(".")    # Activate the environment
Pkg.instantiate()    # Download and Install all within Manifest.toml
```

In Julia, package management involves two distinct steps: installation and loading. 
You only need to install a package once (using Pkg.add), which downloads the files to your hard drive permanently. 
However, to use the package in a specific coding session, you must load it every time you restart your kernel or open the REPL. 
**This design keeps your active memory clean by not loading every installed tool automatically**.

### 2. Project Structure
```
/root
├── p1.jl                 # The main execution script
├── source/
│   └── simulation.jl     # The modular logic (extract_solution, simulate_model)
└── modfiles/
    └── p1/               # see README. on this folder
        ├── 1.mod         
```

## Authors 
- Cristobal Donoso 
- Roberto Flores
- Francisco Medina 
- Nicolas Moreno