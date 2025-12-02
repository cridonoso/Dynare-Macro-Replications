function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 8
    @assert length(y) == 8
    @assert length(x) == 2
    @assert length(params) == 7
@inbounds begin
    residual[1] = (y[3]) - (exp(y[6])*y[4]^params[3]*y[5]^(1-params[3]));
    residual[2] = (y[1]+y[2]+y[7]) - (y[3]);
    residual[3] = (y[4]) - (y[2]+y[4]*(1-params[2]));
    residual[4] = (y[6]) - (y[6]*params[4]+x[1]);
    residual[5] = (log(y[7])) - ((1-params[6])*log(params[7])+log(y[7])*params[6]+x[2]);
    residual[6] = (1/y[1]) - (1/y[1]*params[1]*(1+y[5]^(1-params[3])*exp(y[6])*params[3]*y[4]^(params[3]-1)-params[2]));
    residual[7] = (params[5]/(1-y[5])) - (y[3]*(1-params[3])*1/y[1]/y[5]);
    residual[8] = (y[8]) - (y[3]/y[5]);
end
    return nothing
end

