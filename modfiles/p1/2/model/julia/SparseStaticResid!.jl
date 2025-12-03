function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 10
    @assert length(y) == 10
    @assert length(x) == 1
    @assert length(params) == 9
@inbounds begin
    residual[1] = (1/y[1]) - (params[1]*1/y[1]*(params[3]*y[2]/y[4]+1-params[2]));
    residual[2] = (1/y[1]*(1-params[3])*y[2]/y[3]) - (params[5]*params[9]/y[8]+y[10]);
    residual[3] = (y[10]) - (params[1]*(params[5]*params[8]*(1-params[9])/y[8]+y[10]*(1-params[8])));
    residual[4] = (y[8]) - (params[9]*(1-y[3])+params[8]*(1-params[9])*y[9]);
    residual[5] = (y[9]) - (1-y[3]+(1-params[8])*y[9]);
    residual[6] = (y[2]) - (y[6]*y[4]^params[3]*y[3]^(1-params[3]));
    residual[7] = (y[1]) - (y[2]+y[4]*(1-params[2])-y[4]);
    residual[8] = (y[4]) - (y[4]*(1-params[2])+y[5]);
    residual[9] = (y[7]) - (y[2]/y[3]);
    residual[10] = (log(y[6])) - (log(y[6])*params[4]+x[1]);
end
    return nothing
end

