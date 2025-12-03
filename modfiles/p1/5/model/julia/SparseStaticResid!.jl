function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 18
    @assert length(y) == 18
    @assert length(x) == 3
    @assert length(params) == 10
@inbounds begin
    residual[1] = (y[1]) - ((params[10]*y[9]^params[8]+(1-params[10])*y[10]^params[8])^(1/params[8]));
    residual[2] = (y[6]) - (1-y[7]-y[8]);
    residual[3] = (params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])/y[1]) - (params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])/y[1]*params[1]*(params[3]*y[11]/y[3]+1-params[2]));
    residual[4] = (params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])*(1-params[3])*y[11]/y[7]) - ((1-params[4])*y[12]/y[8]*y[1]^(1-params[8])*(1-params[10])*y[10]^(params[8]-1));
    residual[5] = (params[9]/y[6]) - (y[11]/y[7]*(1-params[3])*y[1]^(1-params[8])*y[9]^(params[8]-1)*params[10]*1/y[1]);
    residual[6] = (params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])*params[3]*y[11]/y[3]) - (y[1]^(1-params[8])*(1-params[10])*y[10]^(params[8]-1)*params[4]*y[12]/y[4]);
    residual[7] = (y[11]) - (exp(y[13])*y[3]^params[3]*y[7]^(1-params[3]));
    residual[8] = (y[12]) - (exp(y[14])*y[4]^params[4]*y[8]^(1-params[4]));
    residual[9] = (y[9]+y[5]+y[15]) - (y[11]);
    residual[10] = (y[10]) - (y[12]);
    residual[11] = (y[2]) - (y[5]+(1-params[2])*y[2]);
    residual[12] = (y[3]+y[4]) - (y[2]);
    residual[13] = (y[13]) - (y[13]*params[5]+x[1]);
    residual[14] = (y[14]) - (y[14]*params[6]+x[2]);
    residual[15] = (log(y[15])) - ((1-params[7])*log(y[11]*0.2)+log(y[15])*params[7]+x[3]);
    residual[16] = (y[16]) - (y[11]/y[7]);
    residual[17] = (y[17]) - (y[11]);
    residual[18] = (y[18]) - (y[7]);
end
    return nothing
end

