function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 25
    @assert length(y) == 21
    @assert length(x) == 2
    @assert length(params) == 7
@inbounds begin
g1_v[1]=(-(y[12]^(1-params[3])*exp(y[13])*get_power_deriv(y[4],params[3],1)));
g1_v[2]=(-(1-params[2]));
g1_v[3]=(-params[4]);
g1_v[4]=(-(params[6]*1/y[7]));
g1_v[5]=1;
g1_v[6]=(-1)/(y[8]*y[8]);
g1_v[7]=(-(y[10]*(1-params[3])*(-1)/(y[8]*y[8])/y[12]));
g1_v[8]=1;
g1_v[9]=(-1);
g1_v[10]=1;
g1_v[11]=(-1);
g1_v[12]=(-((1-params[3])*1/y[8]/y[12]));
g1_v[13]=1;
g1_v[14]=(-(params[1]*1/y[15]*y[19]^(1-params[3])*params[3]*exp(y[20])*get_power_deriv(y[11],params[3]-1,1)));
g1_v[15]=(-(exp(y[13])*y[4]^params[3]*get_power_deriv(y[12],1-params[3],1)));
g1_v[16]=params[5]/((1-y[12])*(1-y[12]))-(-(y[10]*(1-params[3])*1/y[8]))/(y[12]*y[12]);
g1_v[17]=(-(exp(y[13])*y[4]^params[3]*y[12]^(1-params[3])));
g1_v[18]=1;
g1_v[19]=1;
g1_v[20]=1/y[14];
g1_v[21]=(-((1+params[3]*exp(y[20])*y[11]^(params[3]-1)*y[19]^(1-params[3])-params[2])*params[1]*(-1)/(y[15]*y[15])));
g1_v[22]=(-(params[1]*1/y[15]*params[3]*exp(y[20])*y[11]^(params[3]-1)*get_power_deriv(y[19],1-params[3],1)));
g1_v[23]=(-(params[1]*1/y[15]*params[3]*exp(y[20])*y[11]^(params[3]-1)*y[19]^(1-params[3])));
g1_v[24]=(-1);
g1_v[25]=(-1);
end
    return nothing
end

