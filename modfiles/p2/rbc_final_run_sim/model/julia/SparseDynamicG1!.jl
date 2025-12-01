function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 28
    @assert length(y) == 24
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
g1_v[1]=(-((1-params[3])*exp((-y[14]))));
g1_v[2]=(-(y[12]^(1-params[2])*exp((-y[14]))*get_power_deriv(exp((-y[14]))*y[2],params[2],1)));
g1_v[3]=(-(100*(-(1/y[3]))));
g1_v[4]=(-(params[6]*1/y[5]));
g1_v[5]=(-(((1-params[3])*exp((-y[22]))+params[2]*y[19]/y[10])*1/y[17]));
g1_v[6]=1;
g1_v[7]=params[4]/(params[5]-y[12]);
g1_v[8]=(-(y[9]/y[17]*(-(params[2]*y[19]))/(y[10]*y[10])));
g1_v[9]=1;
g1_v[10]=(-1);
g1_v[11]=1;
g1_v[12]=(-((1-params[2])*1/y[12]));
g1_v[13]=(-(100*1/y[11]));
g1_v[14]=(-((exp((-y[14]))*y[2])^params[2]*get_power_deriv(y[12],1-params[2],1)));
g1_v[15]=y[9]*params[4]/((params[5]-y[12])*(params[5]-y[12]))-(1-params[2])*(-y[11])/(y[12]*y[12]);
g1_v[16]=(-(1/y[12]));
g1_v[17]=1/y[13];
g1_v[18]=(-((1-params[3])*y[2]*(-exp((-y[14])))));
g1_v[19]=(-(y[12]^(1-params[2])*get_power_deriv(exp((-y[14]))*y[2],params[2],1)*y[2]*(-exp((-y[14])))));
g1_v[20]=1;
g1_v[21]=(-100);
g1_v[22]=1;
g1_v[23]=1;
g1_v[24]=(-(((1-params[3])*exp((-y[22]))+params[2]*y[19]/y[10])*(-y[9])/(y[17]*y[17])));
g1_v[25]=(-(y[9]/y[17]*params[2]/y[10]));
g1_v[26]=(-(y[9]/y[17]*(1-params[3])*(-exp((-y[22])))));
g1_v[27]=(-1);
g1_v[28]=(-1);
end
    return nothing
end

