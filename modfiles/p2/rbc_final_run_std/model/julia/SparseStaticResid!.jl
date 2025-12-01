function SparseStaticResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 8
    @assert length(y) == 8
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
    residual[1] = (1/params[1]) - (params[2]*y[3]/y[2]+(1-params[3])*exp((-y[6])));
    residual[2] = (y[2]+y[1]-exp((-y[6]))*y[2]*(1-params[3])) - (y[3]);
    residual[3] = (y[3]) - (y[4]^(1-params[2])*(y[2]*exp((-y[6])))^params[2]);
    residual[4] = (y[1]*params[4]/(params[5]-y[4])) - ((1-params[2])*y[3]/y[4]);
    residual[5] = (log(y[5])) - ((1-params[6])*log(params[7])+log(y[5])*params[6]+x[2]);
    residual[6] = (y[6]) - (params[8]+x[1]);
    residual[7] = (y[7]) - (y[6]*100);
    residual[8] = (y[8]) - (log(y[4])-log((y[4])));
end
    return nothing
end

