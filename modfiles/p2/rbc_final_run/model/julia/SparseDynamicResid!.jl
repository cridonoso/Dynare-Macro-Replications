function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 8
    @assert length(y) == 24
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
    residual[1] = (1/params[1]) - (y[9]/y[17]*((1-params[3])*exp((-y[22]))+params[2]*y[19]/y[10]));
    residual[2] = (y[9]+y[10]-exp((-y[14]))*(1-params[3])*y[2]) - (y[11]);
    residual[3] = (y[11]) - (y[12]^(1-params[2])*(exp((-y[14]))*y[2])^params[2]);
    residual[4] = (y[9]*params[4]/(params[5]-y[12])) - ((1-params[2])*y[11]/y[12]);
    residual[5] = (log(y[13])) - ((1-params[6])*log(params[7])+params[6]*log(y[5])+x[2]);
    residual[6] = (y[14]) - (params[8]+x[1]);
    residual[7] = (y[15]) - ((y[14]+log(y[11])-log(y[3]))*100);
    residual[8] = (y[16]) - (log(y[12])-log((steady_state[4])));
end
    return nothing
end

