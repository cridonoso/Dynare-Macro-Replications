function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 15
    @assert length(y) == 15
    @assert length(x) == 2
    @assert length(params) == 13
@inbounds begin
    residual[1] = (y[1]) - ((params[9]*y[7]^params[7]+(1-params[9])*y[8]^params[7])^(1/params[7]));
    residual[2] = (y[4]) - (1-y[5]-y[6]);
    residual[3] = (y[9]) - (y[5]^(1-params[3])*exp(y[11])*(params[10]*y[2])^params[3]);
    residual[4] = (y[10]) - (y[6]^(1-params[4])*exp(y[12])*(y[2]*(1-params[10]))^params[4]);
    residual[5] = (y[7]+y[3]) - (y[9]);
    residual[6] = (y[8]) - (y[10]);
    residual[7] = (y[2]) - (y[3]+y[2]*(1-params[2]));
    residual[8] = (y[11]) - (y[11]*params[5]+x[1]);
    residual[9] = (y[12]) - (y[12]*params[6]+x[2]);
    residual[10] = (params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*1/y[1]) - (params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*1/y[1]*params[1]*(1-params[2]+params[3]*y[9]/(params[10]*y[2])));
    residual[11] = ((1-params[3])*params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*y[9]/y[5]) - ((1-params[4])*y[1]^(1-params[7])*(1-params[9])*y[8]^(params[7]-1)*y[10]/y[6]);
    residual[12] = (params[8]/y[4]) - (1/(2*y[1])*((1-params[3])*params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*y[9]/y[5]+(1-params[4])*y[1]^(1-params[7])*(1-params[9])*y[8]^(params[7]-1)*y[10]/y[6]));
    residual[13] = (y[13]) - (y[9]/y[5]);
    residual[14] = (y[14]) - (y[9]);
    residual[15] = (y[15]) - (y[5]);
end
    return nothing
end

