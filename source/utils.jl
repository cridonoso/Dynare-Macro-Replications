using LinearAlgebra
using Statistics
using Dynare # Asegúrate de que esté cargado


# Función HP Filter (Si no la tenías)
function hp_filter(y::Vector{Float64}, lambda::Float64=1600.0)
    n = length(y)
    if n < 3 return zeros(n) end
    I_mat = Matrix{Float64}(I, n, n)
    D = zeros(n-2, n)
    for i in 1:n-2
        D[i, i] = 1.0; D[i, i+1] = -2.0; D[i, i+2] = 1.0
    end
    A = I_mat + lambda * (D' * D)
    return y - (A \ y)
end