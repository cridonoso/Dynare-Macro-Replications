function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 26
    @assert length(y) == 24
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
g1_v[1]=(-(y[13]^(1-params[3])*get_power_deriv(y[3],params[3],1)));
g1_v[2]=(-(1-params[2]));
g1_v[3]=(-(1/y[10]*params[1]*exp((-(params[8]+x[1])))*(-(y[9]*params[3]))/(y[3]*y[3])));
g1_v[4]=(-(params[6]*1/y[6]));
g1_v[5]=1;
g1_v[6]=1;
g1_v[7]=(-((1-params[3])*1/y[10]/y[13]));
g1_v[8]=(-(1/y[10]*params[1]*exp((-(params[8]+x[1])))*params[3]/y[3]));
g1_v[9]=(-1);
g1_v[10]=(-1)/(y[10]*y[10]);
g1_v[11]=(-(y[9]*(1-params[3])*(-1)/(y[10]*y[10])/y[13]));
g1_v[12]=(-((1+y[9]*params[3]/y[3]-params[2])*exp((-(params[8]+x[1])))*params[1]*(-1)/(y[10]*y[10])));
g1_v[13]=exp(params[8]+x[1]);
g1_v[14]=(-1);
g1_v[15]=(-1);
g1_v[16]=(-(y[3]^params[3]*get_power_deriv(y[13],1-params[3],1)));
g1_v[17]=params[4]/((params[5]-y[13])*(params[5]-y[13]))-(-(y[9]*(1-params[3])*1/y[10]))/(y[13]*y[13]);
g1_v[18]=(-1);
g1_v[19]=1/y[14];
g1_v[20]=1;
g1_v[21]=1;
g1_v[22]=(-1);
g1_v[23]=y[11]*exp(params[8]+x[1]);
g1_v[24]=(-1);
g1_v[25]=(-((1+y[9]*params[3]/y[3]-params[2])*1/y[10]*params[1]*(-exp((-(params[8]+x[1]))))));
g1_v[26]=(-1);
end
    return nothing
end

