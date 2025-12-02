function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 8
    @assert length(y) == 24
    @assert length(x) == 2
    @assert length(params) == 7
@inbounds begin
    residual[1] = (y[11]) - (exp(y[14])*y[4]^params[3]*y[13]^(1-params[3]));
    residual[2] = (y[9]+y[10]+y[15]) - (y[11]);
    residual[3] = (y[12]) - (y[10]+y[4]*(1-params[2]));
    residual[4] = (y[14]) - (params[4]*y[6]+x[1]);
    residual[5] = (log(y[15])) - ((1-params[6])*log(params[7])+params[6]*log(y[7])+x[2]);
    residual[6] = (1/y[9]) - (params[1]*1/y[17]*(1+params[3]*exp(y[22])*y[12]^(params[3]-1)*y[21]^(1-params[3])-params[2]));
    residual[7] = (params[5]/(1-y[13])) - (y[11]*(1-params[3])*1/y[9]/y[13]);
    residual[8] = (y[16]) - (y[11]/y[13]);
end
    return nothing
end

