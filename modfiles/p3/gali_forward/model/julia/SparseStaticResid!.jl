function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 9
    @assert length(y) == 9
    @assert length(x) == 2
    @assert length(params) == 14
@inbounds begin
    residual[1] = (y[1]) - (y[1]*params[1]+params[14]*y[2]);
    residual[2] = (y[2]) - (y[2]+(-(1/params[2]))*(y[6]-y[1]-y[7]));
    residual[3] = (y[7]) - ((-params[2])*params[12]*(1-params[7])*y[8]+(1-params[8])*y[9]);
    residual[4] = (y[3]) - (params[12]*y[8]);
    residual[5] = (y[4]) - (y[2]+y[3]);
    residual[6] = (y[5]) - (y[4]-(y[4]));
    residual[7] = (y[6]) - (y[1]*params[9]+y[2]*params[10]);
    residual[8] = (y[8]) - (params[7]*y[8]+x[1]);
    residual[9] = (y[9]) - (params[8]*y[9]+x[2]);
end
    return nothing
end

