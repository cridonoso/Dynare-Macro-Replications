function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 49
    @assert length(y) == 36
    @assert length(x) == 2
    @assert length(params) == 13
@inbounds begin
g1_v[1]=(-(y[17]^(1-params[3])*exp(y[23])*params[10]*get_power_deriv(params[10]*y[2],params[3],1)));
g1_v[2]=(-(y[18]^(1-params[4])*exp(y[24])*(1-params[10])*get_power_deriv((1-params[10])*y[2],params[4],1)));
g1_v[3]=(-(1-params[2]));
g1_v[4]=(-params[5]);
g1_v[5]=(-params[6]);
g1_v[6]=1;
g1_v[7]=1/y[13]*params[9]*y[19]^(params[7]-1)*get_power_deriv(y[13],1-params[7],1)+params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*(-1)/(y[13]*y[13]);
g1_v[8]=y[21]/y[17]*(1-params[3])*params[9]*y[19]^(params[7]-1)*get_power_deriv(y[13],1-params[7],1)-y[22]/y[18]*(1-params[4])*(1-params[9])*y[20]^(params[7]-1)*get_power_deriv(y[13],1-params[7],1);
g1_v[9]=(-(((1-params[3])*params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*y[21]/y[17]+(1-params[4])*y[13]^(1-params[7])*(1-params[9])*y[20]^(params[7]-1)*y[22]/y[18])*(-2)/(2*y[13]*2*y[13])+1/(2*y[13])*(y[21]/y[17]*(1-params[3])*params[9]*y[19]^(params[7]-1)*get_power_deriv(y[13],1-params[7],1)+y[22]/y[18]*(1-params[4])*(1-params[9])*y[20]^(params[7]-1)*get_power_deriv(y[13],1-params[7],1))));
g1_v[10]=1;
g1_v[11]=(-(params[1]*params[9]*y[31]^(params[7]-1)*y[25]^(1-params[7])*1/y[25]*params[3]*(-(params[10]*y[33]))/(params[10]*y[14]*params[10]*y[14])));
g1_v[12]=1;
g1_v[13]=(-1);
g1_v[14]=1;
g1_v[15]=(-params[8])/(y[16]*y[16]);
g1_v[16]=1;
g1_v[17]=(-(exp(y[23])*(params[10]*y[2])^params[3]*get_power_deriv(y[17],1-params[3],1)));
g1_v[18]=(1-params[3])*params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*(-y[21])/(y[17]*y[17]);
g1_v[19]=(-(1/(2*y[13])*(1-params[3])*params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*(-y[21])/(y[17]*y[17])));
g1_v[20]=1;
g1_v[21]=(-(exp(y[24])*((1-params[10])*y[2])^params[4]*get_power_deriv(y[18],1-params[4],1)));
g1_v[22]=(-((1-params[4])*y[13]^(1-params[7])*(1-params[9])*y[20]^(params[7]-1)*(-y[22])/(y[18]*y[18])));
g1_v[23]=(-(1/(2*y[13])*(1-params[4])*y[13]^(1-params[7])*(1-params[9])*y[20]^(params[7]-1)*(-y[22])/(y[18]*y[18])));
g1_v[24]=(-(params[9]*get_power_deriv(y[19],params[7],1)*get_power_deriv(params[9]*y[19]^params[7]+(1-params[9])*y[20]^params[7],1/params[7],1)));
g1_v[25]=1;
g1_v[26]=1/y[13]*y[13]^(1-params[7])*params[9]*get_power_deriv(y[19],params[7]-1,1);
g1_v[27]=y[21]/y[17]*(1-params[3])*y[13]^(1-params[7])*params[9]*get_power_deriv(y[19],params[7]-1,1);
g1_v[28]=(-(1/(2*y[13])*y[21]/y[17]*(1-params[3])*y[13]^(1-params[7])*params[9]*get_power_deriv(y[19],params[7]-1,1)));
g1_v[29]=(-(get_power_deriv(params[9]*y[19]^params[7]+(1-params[9])*y[20]^params[7],1/params[7],1)*(1-params[9])*get_power_deriv(y[20],params[7],1)));
g1_v[30]=1;
g1_v[31]=(-(y[22]/y[18]*(1-params[4])*y[13]^(1-params[7])*(1-params[9])*get_power_deriv(y[20],params[7]-1,1)));
g1_v[32]=(-(1/(2*y[13])*y[22]/y[18]*(1-params[4])*y[13]^(1-params[7])*(1-params[9])*get_power_deriv(y[20],params[7]-1,1)));
g1_v[33]=1;
g1_v[34]=(-1);
g1_v[35]=(1-params[3])*params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*1/y[17];
g1_v[36]=(-(1/(2*y[13])*(1-params[3])*params[9]*y[19]^(params[7]-1)*y[13]^(1-params[7])*1/y[17]));
g1_v[37]=1;
g1_v[38]=(-1);
g1_v[39]=(-((1-params[4])*y[13]^(1-params[7])*(1-params[9])*y[20]^(params[7]-1)*1/y[18]));
g1_v[40]=(-(1/(2*y[13])*(1-params[4])*y[13]^(1-params[7])*(1-params[9])*y[20]^(params[7]-1)*1/y[18]));
g1_v[41]=(-(y[17]^(1-params[3])*exp(y[23])*(params[10]*y[2])^params[3]));
g1_v[42]=1;
g1_v[43]=(-(y[18]^(1-params[4])*exp(y[24])*((1-params[10])*y[2])^params[4]));
g1_v[44]=1;
g1_v[45]=(-((1-params[2]+params[3]*y[33]/(params[10]*y[14]))*params[1]*(1/y[25]*params[9]*y[31]^(params[7]-1)*get_power_deriv(y[25],1-params[7],1)+params[9]*y[31]^(params[7]-1)*y[25]^(1-params[7])*(-1)/(y[25]*y[25]))));
g1_v[46]=(-((1-params[2]+params[3]*y[33]/(params[10]*y[14]))*params[1]*1/y[25]*y[25]^(1-params[7])*params[9]*get_power_deriv(y[31],params[7]-1,1)));
g1_v[47]=(-(params[1]*params[9]*y[31]^(params[7]-1)*y[25]^(1-params[7])*1/y[25]*params[3]*1/(params[10]*y[14])));
g1_v[48]=(-1);
g1_v[49]=(-1);
end
    return nothing
end

