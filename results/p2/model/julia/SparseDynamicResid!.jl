function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 11
    @assert length(y) == 33
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
    residual[1] = (1/y[13]) - (params[1]*1/y[24]*(params[3]*exp(y[28])*y[14]^(params[3]-1)*y[27]^(1-params[3])+1-params[2]));
    residual[2] = (y[13]*params[6]/(1-y[16])) - ((1-params[3])*exp(y[17])*y[3]^params[3]*y[16]^(-params[3]));
    residual[3] = (y[13]+y[14]-(1-params[2])*y[3]) - (exp(y[17])*y[3]^params[3]*y[16]^(1-params[3]));
    residual[4] = (y[12]) - (exp(y[17])*y[3]^params[3]*y[16]^(1-params[3]));
    residual[5] = (y[15]) - (y[12]-y[13]);
    residual[6] = (y[17]) - (params[4]*y[6]+x[1]);
    residual[7] = (y[18]) - (y[12]/y[16]);
    residual[8] = (y[19]) - (log(y[12])-log((steady_state[1])));
    residual[9] = (y[20]) - (log(y[13])-log((steady_state[2])));
    residual[10] = (y[21]) - (log(y[15])-log((steady_state[4])));
    residual[11] = (y[22]) - (log(y[16])-log((steady_state[5])));
end
    return nothing
end

