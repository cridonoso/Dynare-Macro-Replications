function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 7
    @assert length(y) == 7
    @assert length(x) == 1
    @assert length(params) == 8
@inbounds begin
    residual[1] = (1/y[1]) - (params[1]*1/y[1]*(params[3]*y[2]/y[4]+1-params[2]));
    residual[2] = ((1-params[3])*y[2]/y[3]) - (y[1]*params[8]);
    residual[3] = (y[1]) - (y[2]+y[4]*(1-params[2])-y[4]);
    residual[4] = (y[4]) - (y[4]*(1-params[2])+y[5]);
    residual[5] = (y[2]) - (y[6]*y[4]^params[3]*y[3]^(1-params[3]));
    residual[6] = (log(y[6])) - (log(y[6])*params[4]+x[1]);
    residual[7] = (y[7]) - (y[2]/y[3]);
end
    return nothing
end

