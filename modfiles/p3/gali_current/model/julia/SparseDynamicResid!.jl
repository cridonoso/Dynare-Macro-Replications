function SparseDynamicResid!(T::Vector{<: Real}, residual::AbstractVector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(residual) == 10
    @assert length(y) == 30
    @assert length(x) == 2
    @assert length(params) == 10
@inbounds begin
    residual[1] = (y[12]) - (y[22]-1/params[2]*(y[17]-y[21]-y[15]));
    residual[2] = (y[11]) - (params[1]*y[21]+y[12]*(params[2]+(params[4]+params[3])/(1-params[4]))*(1-params[4])/(1-params[4]+params[4]*params[5])*(1-params[6])*(1-params[6]*params[1])/params[6]);
    residual[3] = (y[17]) - (y[11]*params[9]+y[12]*params[10]);
    residual[4] = (y[15]) - ((1-params[8])*y[20]+y[19]*(1-params[7])*(1+params[3])/(params[4]+params[3]+(1-params[4])*params[2])*(-params[2]));
    residual[5] = (y[13]) - ((1+params[3])/(params[4]+params[3]+(1-params[4])*params[2])*y[19]);
    residual[6] = (y[14]) - (y[12]+y[13]);
    residual[7] = (y[18]) - ((y[14]-y[19])/(1-params[4]));
    residual[8] = (y[16]) - (y[17]-y[21]);
    residual[9] = (y[19]) - (params[7]*y[9]+x[1]);
    residual[10] = (y[20]) - (params[8]*y[10]+x[2]);
end
    return nothing
end

