function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 23
    @assert length(y) == 21
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
g1_v[1]=(-(y[12]^(1-params[3])*y[13]*get_power_deriv(y[3],params[3],1)));
g1_v[2]=(-(1-params[2]));
g1_v[3]=(-(params[4]*1/y[6]));
g1_v[4]=(-(1/y[9]*(1-params[3])/y[12]));
g1_v[5]=(-1);
g1_v[6]=1;
g1_v[7]=(-(1/y[12]));
g1_v[8]=(-1)/(y[9]*y[9]);
g1_v[9]=(-(y[8]*(1-params[3])*(-1)/(y[9]*y[9])/y[12]));
g1_v[10]=1;
g1_v[11]=(-(params[1]*1/y[16]*(-(params[3]*y[15]))/(y[10]*y[10])));
g1_v[12]=1;
g1_v[13]=1;
g1_v[14]=(-1);
g1_v[15]=params[6]/((1-y[12])*(1-y[12]))-(-(1/y[9]*(1-params[3])*y[8]))/(y[12]*y[12]);
g1_v[16]=(-(y[13]*y[3]^params[3]*get_power_deriv(y[12],1-params[3],1)));
g1_v[17]=(-((-y[8])/(y[12]*y[12])));
g1_v[18]=(-(y[3]^params[3]*y[12]^(1-params[3])));
g1_v[19]=1/y[13];
g1_v[20]=1;
g1_v[21]=(-(params[1]*1/y[16]*params[3]/y[10]));
g1_v[22]=(-((params[3]*y[15]/y[10]+1-params[2])*params[1]*(-1)/(y[16]*y[16])));
g1_v[23]=(-1);
end
    return nothing
end

