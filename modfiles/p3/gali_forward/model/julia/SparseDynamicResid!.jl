function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 9
    @assert length(y) == 27
    @assert length(x) == 2
    @assert length(params) == 14
@inbounds begin
    residual[1] = (y[10]) - (params[1]*y[19]+params[14]*y[11]);
    residual[2] = (y[11]) - ((-(1/params[2]))*(y[15]-y[19]-y[16])+y[20]);
    residual[3] = (y[16]) - ((-params[2])*params[12]*(1-params[7])*y[17]+(1-params[8])*y[18]);
    residual[4] = (y[12]) - (params[12]*y[17]);
    residual[5] = (y[13]) - (y[11]+y[12]);
    residual[6] = (y[14]) - (y[13]-(steady_state[4]));
    residual[7] = (y[15]) - (0.0+y[19]*params[9]+y[20]*params[10]);
    residual[8] = (y[17]) - (params[7]*y[8]+x[1]);
    residual[9] = (y[18]) - (params[8]*y[9]+x[2]);
end
    return nothing
end

