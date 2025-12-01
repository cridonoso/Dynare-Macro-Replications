function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 9
    @assert length(y) == 27
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
    residual[1] = (1/y[11]) - (params[1]*1/(y[20]*exp(y[24]))*(params[2]*y[19]/y[3]+1-params[3]));
    residual[2] = (y[10]) - (y[11]+y[12]-y[3]*(1-params[3])*exp((-y[15]))+y[14]);
    residual[3] = (y[10]) - ((y[3]*exp((-y[15])))^params[2]*y[13]^(1-params[2]));
    residual[4] = (y[18]) - (y[10]*(1-params[2])/y[13]);
    residual[5] = (y[11]*params[4]/(params[5]-y[13])) - (y[18]);
    residual[6] = (log(y[14])) - ((1-params[6])*log(params[7])+params[6]*log(y[5])+x[2]);
    residual[7] = (y[15]) - (params[8]+x[1]);
    residual[8] = (y[16]) - ((y[15]+log(y[10])-log(y[1]))*100);
    residual[9] = (y[17]) - (log(y[13]));
end
    return nothing
end

