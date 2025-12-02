function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 15
    @assert length(y) == 45
    @assert length(x) == 2
    @assert length(params) == 13
@inbounds begin
    residual[1] = (y[16]) - ((params[9]*y[22]^params[7]+(1-params[9])*y[23]^params[7])^(1/params[7]));
    residual[2] = (y[19]) - (1-y[20]-y[21]);
    residual[3] = (y[24]) - (y[20]^(1-params[3])*exp(y[26])*(params[10]*y[2])^params[3]);
    residual[4] = (y[25]) - (y[21]^(1-params[4])*exp(y[27])*((1-params[10])*y[2])^params[4]);
    residual[5] = (y[22]+y[18]) - (y[24]);
    residual[6] = (y[23]) - (y[25]);
    residual[7] = (y[17]) - (y[18]+(1-params[2])*y[2]);
    residual[8] = (y[26]) - (params[5]*y[11]+x[1]);
    residual[9] = (y[27]) - (params[6]*y[12]+x[2]);
    residual[10] = (params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*1/y[16]) - (params[1]*params[9]*y[37]^(params[7]-1)*y[31]^(1-params[7])*1/y[31]*(1-params[2]+params[3]*y[39]/(params[10]*y[17])));
    residual[11] = ((1-params[3])*params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*y[24]/y[20]) - ((1-params[4])*y[16]^(1-params[7])*(1-params[9])*y[23]^(params[7]-1)*y[25]/y[21]);
    residual[12] = (params[8]/y[19]) - (1/(2*y[16])*((1-params[3])*params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*y[24]/y[20]+(1-params[4])*y[16]^(1-params[7])*(1-params[9])*y[23]^(params[7]-1)*y[25]/y[21]));
    residual[13] = (y[28]) - (y[24]/y[20]);
    residual[14] = (y[29]) - (y[24]);
    residual[15] = (y[30]) - (y[20]);
end
    return nothing
end

