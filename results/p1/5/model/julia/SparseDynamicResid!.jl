function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 12
    @assert length(y) == 36
    @assert length(x) == 2
    @assert length(params) == 13
@inbounds begin
    residual[1] = (y[13]) - ((params[9]*y[19]^params[7]+(1-params[9])*y[20]^params[7])^(1/params[7]));
    residual[2] = (y[16]) - (1-y[17]-y[18]);
    residual[3] = (y[21]) - (y[17]^(1-params[3])*exp(y[23])*(params[10]*y[2])^params[3]);
    residual[4] = (y[22]) - (y[18]^(1-params[4])*exp(y[24])*((1-params[10])*y[2])^params[4]);
    residual[5] = (y[19]+y[15]) - (y[21]);
    residual[6] = (y[20]) - (y[22]);
    residual[7] = (y[14]) - (y[15]+(1-params[2])*y[2]);
    residual[8] = (y[23]) - (params[5]*y[11]+x[1]);
    residual[9] = (y[24]) - (params[6]*y[12]+x[2]);
    residual[10] = (params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*1/y[13]) - (params[1]*params[9]*y[31]^(params[7]-1)*y[25]^(1-params[7])*1/y[25]*(1-params[2]+params[3]*y[33]/(params[10]*y[14])));
    residual[11] = ((1-params[3])*params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*y[21]/y[17]) - ((1-params[4])*y[13]^(1-params[7])*(1-params[9])*y[20]^(params[7]-1)*y[22]/y[18]);
    residual[12] = (params[8]/y[16]) - (1/(2*y[13])*((1-params[3])*params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*y[21]/y[17]+(1-params[4])*y[13]^(1-params[7])*(1-params[9])*y[20]^(params[7]-1)*y[22]/y[18]));
end
    return nothing
end

