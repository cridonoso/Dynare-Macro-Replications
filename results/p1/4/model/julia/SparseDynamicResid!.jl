function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 7
    @assert length(y) == 21
    @assert length(x) == 2
    @assert length(params) == 7
@inbounds begin
    residual[1] = (y[10]) - (exp(y[13])*y[4]^params[3]*y[12]^(1-params[3]));
    residual[2] = (y[8]+y[9]+y[14]) - (y[10]);
    residual[3] = (y[11]) - (y[9]+y[4]*(1-params[2]));
    residual[4] = (y[13]) - (params[4]*y[6]+x[1]);
    residual[5] = (log(y[14])) - ((1-params[6])*log(params[7])+params[6]*log(y[7])+x[2]);
    residual[6] = (1/y[8]) - (params[1]*1/y[15]*(1+params[3]*exp(y[20])*y[11]^(params[3]-1)*y[19]^(1-params[3])-params[2]));
    residual[7] = (params[5]/(1-y[12])) - (y[10]*(1-params[3])*1/y[8]/y[12]);
end
    return nothing
end

