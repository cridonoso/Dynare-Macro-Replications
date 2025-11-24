function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 13
    @assert length(y) == 39
    @assert length(x) == 2
    @assert length(params) == 13
@inbounds begin
    residual[1] = (y[14]) - ((params[9]*y[20]^params[7]+(1-params[9])*y[21]^params[7])^(1/params[7]));
    residual[2] = (y[17]) - (1-y[18]-y[19]);
    residual[3] = (y[22]) - (y[18]^(1-params[3])*exp(y[24])*(params[10]*y[2])^params[3]);
    residual[4] = (y[23]) - (y[19]^(1-params[4])*exp(y[25])*((1-params[10])*y[2])^params[4]);
    residual[5] = (y[20]+y[16]) - (y[22]);
    residual[6] = (y[21]) - (y[23]);
    residual[7] = (y[15]) - (y[16]+(1-params[2])*y[2]);
    residual[8] = (y[24]) - (params[5]*y[11]+x[1]);
    residual[9] = (y[25]) - (params[6]*y[12]+x[2]);
    residual[10] = (params[9]*y[20]^(params[7]-1)*y[14]^(1-params[7])*1/y[14]) - (params[1]*params[9]*y[33]^(params[7]-1)*y[27]^(1-params[7])*1/y[27]*(1-params[2]+params[3]*y[35]/(params[10]*y[15])));
    residual[11] = ((1-params[3])*params[9]*y[20]^(params[7]-1)*y[14]^(1-params[7])*y[22]/y[18]) - ((1-params[4])*y[14]^(1-params[7])*(1-params[9])*y[21]^(params[7]-1)*y[23]/y[19]);
    residual[12] = (params[8]/y[17]) - (1/(2*y[14])*((1-params[3])*params[9]*y[20]^(params[7]-1)*y[14]^(1-params[7])*y[22]/y[18]+(1-params[4])*y[14]^(1-params[7])*(1-params[9])*y[21]^(params[7]-1)*y[23]/y[19]));
    residual[13] = (y[26]) - (y[22]/y[18]);
end
    return nothing
end

