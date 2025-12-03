function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 10
    @assert length(y) == 10
    @assert length(x) == 2
    @assert length(params) == 10
@inbounds begin
    residual[1] = (y[2]) - (y[2]-1/params[2]*(y[7]-y[1]-y[5]));
    residual[2] = (y[1]) - (params[1]*y[1]+(1-params[4])/(1-params[4]+params[4]*params[5])*(1-params[6])*(1-params[6]*params[1])/params[6]*(params[2]+(params[4]+params[3])/(1-params[4]))*y[2]);
    residual[3] = (y[7]) - (y[1]*params[9]+y[2]*params[10]);
    residual[4] = (y[5]) - ((1-params[8])*y[10]+y[9]*(1-params[7])*(1+params[3])/(params[4]+params[3]+(1-params[4])*params[2])*(-params[2]));
    residual[5] = (y[3]) - ((1+params[3])/(params[4]+params[3]+(1-params[4])*params[2])*y[9]);
    residual[6] = (y[4]) - (y[2]+y[3]);
    residual[7] = (y[8]) - ((y[4]-y[9])/(1-params[4]));
    residual[8] = (y[6]) - (y[7]-y[1]);
    residual[9] = (y[9]) - (y[9]*params[7]+x[1]);
    residual[10] = (y[10]) - (params[8]*y[10]+x[2]);
end
    return nothing
end

