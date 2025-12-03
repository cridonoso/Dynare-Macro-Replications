function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 7
    @assert length(y) == 21
    @assert length(x) == 1
    @assert length(params) == 8
@inbounds begin
    residual[1] = (1/y[8]) - (params[1]*1/y[15]*(params[3]*y[16]/y[11]+1-params[2]));
    residual[2] = ((1-params[3])*y[9]/y[10]) - (y[8]*params[8]);
    residual[3] = (y[9]) - (y[13]*y[4]^params[3]*y[10]^(1-params[3]));
    residual[4] = (y[8]) - (y[9]+(1-params[2])*y[4]-y[11]);
    residual[5] = (y[11]) - ((1-params[2])*y[4]+y[12]);
    residual[6] = (y[14]) - (y[9]/y[10]);
    residual[7] = (log(y[13])) - (params[4]*log(y[6])+x[1]);
end
    return nothing
end

