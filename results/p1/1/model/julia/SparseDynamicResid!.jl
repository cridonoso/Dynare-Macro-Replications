function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 7
    @assert length(y) == 21
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
    residual[1] = (1/y[9]) - (params[1]*1/y[16]*(params[3]*y[15]/y[10]+1-params[2]));
    residual[2] = (params[6]/(1-y[12])) - (1/y[9]*(1-params[3])*y[8]/y[12]);
    residual[3] = (y[9]+y[11]) - (y[8]);
    residual[4] = (y[8]) - (y[13]*y[3]^params[3]*y[12]^(1-params[3]));
    residual[5] = (y[10]) - (y[11]+(1-params[2])*y[3]);
    residual[6] = (log(y[13])) - (params[4]*log(y[6])+x[1]);
    residual[7] = (y[14]) - (y[8]/y[12]);
end
    return nothing
end

