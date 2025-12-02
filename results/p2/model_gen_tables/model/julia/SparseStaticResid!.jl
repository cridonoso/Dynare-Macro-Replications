function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 9
    @assert length(y) == 9
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
    residual[1] = (1/y[2]) - (params[1]*1/(y[2]*exp(y[6]))*(params[2]*y[1]/y[3]+1-params[3]));
    residual[2] = (y[1]) - (y[2]+y[3]-y[3]*(1-params[3])*exp((-y[6]))+y[5]);
    residual[3] = (y[1]) - ((y[3]*exp((-y[6])))^params[2]*y[4]^(1-params[2]));
    residual[4] = (y[9]) - (y[1]*(1-params[2])/y[4]);
    residual[5] = (y[2]*params[4]/(params[5]-y[4])) - (y[9]);
    residual[6] = (log(y[5])) - ((1-params[6])*log(params[7])+log(y[5])*params[6]+x[2]);
    residual[7] = (y[6]) - (params[8]+x[1]);
    residual[8] = (y[7]) - (y[6]*100);
    residual[9] = (y[8]) - (log(y[4]));
end
    return nothing
end

