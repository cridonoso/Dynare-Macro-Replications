function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 7
    @assert length(y) == 7
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
    residual[1] = (1/y[2]) - (1/y[2]*params[1]*(params[3]*exp(y[6])*y[3]^(params[3]-1)*y[5]^(1-params[3])+1-params[2]));
    residual[2] = (y[2]*params[6]/(1-y[5])) - (exp(y[6])*(1-params[3])*y[3]^params[3]*y[5]^(-params[3]));
    residual[3] = (y[2]+y[3]-y[3]*(1-params[2])) - (y[5]^(1-params[3])*exp(y[6])*y[3]^params[3]);
    residual[4] = (y[1]) - (y[5]^(1-params[3])*exp(y[6])*y[3]^params[3]);
    residual[5] = (y[4]) - (y[1]-y[2]);
    residual[6] = (y[6]) - (y[6]*params[4]+x[1]);
    residual[7] = (y[7]) - (y[1]/y[5]);
end
    return nothing
end

