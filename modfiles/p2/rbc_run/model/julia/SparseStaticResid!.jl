function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 8
    @assert length(y) == 8
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
    residual[1] = (y[1]) - (y[3]^params[3]*y[5]^(1-params[3]));
    residual[2] = (y[3]*exp(params[8]+x[1])) - (y[3]*(1-params[2])+y[4]);
    residual[3] = (y[1]) - (y[4]+y[2]+y[6]);
    residual[4] = (1/y[2]) - (y[8]);
    residual[5] = (params[4]/(params[5]-y[5])) - (y[1]*(1-params[3])*1/y[2]/y[5]);
    residual[6] = (y[7]) - (x[1]);
    residual[7] = (log(y[6])) - ((1-params[6])*log(params[7])+log(y[6])*params[6]+x[2]);
    residual[8] = (y[8]) - (1/y[2]*params[1]*exp((-(params[8]+x[1])))*(1+y[1]*params[3]/y[3]-params[2]));
end
    return nothing
end

