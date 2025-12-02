function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 18
    @assert length(y) == 54
    @assert length(x) == 3
    @assert length(params) == 10
@inbounds begin
    residual[1] = (y[19]) - ((params[10]*y[27]^params[8]+(1-params[10])*y[28]^params[8])^(1/params[8]));
    residual[2] = (y[24]) - (1-y[25]-y[26]);
    residual[3] = (y[29]) - (exp(y[31])*y[21]^params[3]*y[25]^(1-params[3]));
    residual[4] = (y[30]) - (exp(y[32])*y[22]^params[4]*y[26]^(1-params[4]));
    residual[5] = (y[27]+y[23]+y[33]) - (y[29]);
    residual[6] = (y[28]) - (y[30]);
    residual[7] = (y[20]) - (y[23]+(1-params[2])*y[2]);
    residual[8] = (y[21]+y[22]) - (y[2]);
    residual[9] = (y[31]) - (params[5]*y[13]+x[1]);
    residual[10] = (y[32]) - (params[6]*y[14]+x[2]);
    residual[11] = (log(y[33])) - ((1-params[7])*log(y[29]*0.2)+params[7]*log(y[15])+x[3]);
    residual[12] = (params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8])/y[19]) - (params[1]*params[10]*y[45]^(params[8]-1)*y[37]^(1-params[8])/y[37]*(1-params[2]+params[3]*y[47]/y[39]));
    residual[13] = (params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8])*(1-params[3])*y[29]/y[25]) - ((1-params[4])*y[30]/y[26]*y[19]^(1-params[8])*(1-params[10])*y[28]^(params[8]-1));
    residual[14] = (params[9]/y[24]) - (y[29]/y[25]*(1-params[3])*y[19]^(1-params[8])*y[27]^(params[8]-1)*params[10]*1/y[19]);
    residual[15] = (params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8])*params[3]*y[29]/y[21]) - (y[19]^(1-params[8])*(1-params[10])*y[28]^(params[8]-1)*params[4]*y[30]/y[22]);
    residual[16] = (y[34]) - (y[29]/y[25]);
    residual[17] = (y[35]) - (y[29]);
    residual[18] = (y[36]) - (y[25]);
end
    return nothing
end

