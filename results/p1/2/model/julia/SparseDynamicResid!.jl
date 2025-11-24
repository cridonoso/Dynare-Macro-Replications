function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 10
    @assert length(y) == 30
    @assert length(x) == 1
    @assert length(params) == 9
@inbounds begin
    residual[1] = (1/y[11]) - (params[1]*1/y[21]*(params[3]*y[22]/y[14]+1-params[2]));
    residual[2] = (1/y[11]*(1-params[3])*y[12]/y[13]) - (params[5]*params[9]/y[18]+y[20]);
    residual[3] = (y[20]) - (params[1]*(params[5]*params[8]*(1-params[9])/y[28]+y[30]*(1-params[8])));
    residual[4] = (y[18]) - (params[9]*(1-y[13])+params[8]*(1-params[9])*y[9]);
    residual[5] = (y[19]) - (1-y[13]+(1-params[8])*y[9]);
    residual[6] = (y[11]) - (y[12]+(1-params[2])*y[4]-y[14]);
    residual[7] = (y[14]) - ((1-params[2])*y[4]+y[15]);
    residual[8] = (y[12]) - (y[16]*y[4]^params[3]*y[13]^(1-params[3]));
    residual[9] = (log(y[16])) - (params[4]*log(y[6])+x[1]);
    residual[10] = (y[17]) - (y[12]/y[13]);
end
    return nothing
end

