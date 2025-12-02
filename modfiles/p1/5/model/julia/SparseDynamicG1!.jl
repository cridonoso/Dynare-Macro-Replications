function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 68
    @assert length(y) == 54
    @assert length(x) == 3
    @assert length(params) == 10
@inbounds begin
g1_v[1]=(-(1-params[2]));
g1_v[2]=(-1);
g1_v[3]=(-params[5]);
g1_v[4]=(-params[6]);
g1_v[5]=(-(params[7]*1/y[15]));
g1_v[6]=1;
g1_v[7]=(y[19]*params[10]*y[27]^(params[8]-1)*get_power_deriv(y[19],1-params[8],1)-params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8]))/(y[19]*y[19]);
g1_v[8]=(1-params[3])*y[29]/y[25]*params[10]*y[27]^(params[8]-1)*get_power_deriv(y[19],1-params[8],1)-(1-params[4])*y[30]/y[26]*(1-params[10])*y[28]^(params[8]-1)*get_power_deriv(y[19],1-params[8],1);
g1_v[9]=(-(y[29]/y[25]*(1-params[3])*(y[27]^(params[8]-1)*params[10]*1/y[19]*get_power_deriv(y[19],1-params[8],1)+y[19]^(1-params[8])*y[27]^(params[8]-1)*params[10]*(-1)/(y[19]*y[19]))));
g1_v[10]=params[3]*y[29]/y[21]*params[10]*y[27]^(params[8]-1)*get_power_deriv(y[19],1-params[8],1)-params[4]*y[30]/y[22]*(1-params[10])*y[28]^(params[8]-1)*get_power_deriv(y[19],1-params[8],1);
g1_v[11]=1;
g1_v[12]=(-(y[25]^(1-params[3])*exp(y[31])*get_power_deriv(y[21],params[3],1)));
g1_v[13]=1;
g1_v[14]=params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8])*params[3]*(-y[29])/(y[21]*y[21]);
g1_v[15]=(-(y[26]^(1-params[4])*exp(y[32])*get_power_deriv(y[22],params[4],1)));
g1_v[16]=1;
g1_v[17]=(-(y[19]^(1-params[8])*(1-params[10])*y[28]^(params[8]-1)*params[4]*(-y[30])/(y[22]*y[22])));
g1_v[18]=1;
g1_v[19]=(-1);
g1_v[20]=1;
g1_v[21]=(-params[9])/(y[24]*y[24]);
g1_v[22]=1;
g1_v[23]=(-(exp(y[31])*y[21]^params[3]*get_power_deriv(y[25],1-params[3],1)));
g1_v[24]=params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8])*(1-params[3])*(-y[29])/(y[25]*y[25]);
g1_v[25]=(-((1-params[3])*y[19]^(1-params[8])*y[27]^(params[8]-1)*params[10]*1/y[19]*(-y[29])/(y[25]*y[25])));
g1_v[26]=(-((-y[29])/(y[25]*y[25])));
g1_v[27]=(-1);
g1_v[28]=1;
g1_v[29]=(-(exp(y[32])*y[22]^params[4]*get_power_deriv(y[26],1-params[4],1)));
g1_v[30]=(-(y[19]^(1-params[8])*(1-params[10])*y[28]^(params[8]-1)*(1-params[4])*(-y[30])/(y[26]*y[26])));
g1_v[31]=(-(params[10]*get_power_deriv(y[27],params[8],1)*get_power_deriv(params[10]*y[27]^params[8]+(1-params[10])*y[28]^params[8],1/params[8],1)));
g1_v[32]=1;
g1_v[33]=y[19]^(1-params[8])*params[10]*get_power_deriv(y[27],params[8]-1,1)/y[19];
g1_v[34]=(1-params[3])*y[29]/y[25]*y[19]^(1-params[8])*params[10]*get_power_deriv(y[27],params[8]-1,1);
g1_v[35]=(-(y[29]/y[25]*(1-params[3])*y[19]^(1-params[8])*params[10]*1/y[19]*get_power_deriv(y[27],params[8]-1,1)));
g1_v[36]=params[3]*y[29]/y[21]*y[19]^(1-params[8])*params[10]*get_power_deriv(y[27],params[8]-1,1);
g1_v[37]=(-(get_power_deriv(params[10]*y[27]^params[8]+(1-params[10])*y[28]^params[8],1/params[8],1)*(1-params[10])*get_power_deriv(y[28],params[8],1)));
g1_v[38]=1;
g1_v[39]=(-((1-params[4])*y[30]/y[26]*y[19]^(1-params[8])*(1-params[10])*get_power_deriv(y[28],params[8]-1,1)));
g1_v[40]=(-(params[4]*y[30]/y[22]*y[19]^(1-params[8])*(1-params[10])*get_power_deriv(y[28],params[8]-1,1)));
g1_v[41]=1;
g1_v[42]=(-1);
g1_v[43]=(-((1-params[7])*0.2/(y[29]*0.2)));
g1_v[44]=params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8])*(1-params[3])*1/y[25];
g1_v[45]=(-((1-params[3])*y[19]^(1-params[8])*y[27]^(params[8]-1)*params[10]*1/y[19]*1/y[25]));
g1_v[46]=params[10]*y[27]^(params[8]-1)*y[19]^(1-params[8])*params[3]*1/y[21];
g1_v[47]=(-(1/y[25]));
g1_v[48]=(-1);
g1_v[49]=1;
g1_v[50]=(-1);
g1_v[51]=(-(y[19]^(1-params[8])*(1-params[10])*y[28]^(params[8]-1)*(1-params[4])*1/y[26]));
g1_v[52]=(-(y[19]^(1-params[8])*(1-params[10])*y[28]^(params[8]-1)*params[4]*1/y[22]));
g1_v[53]=(-(exp(y[31])*y[21]^params[3]*y[25]^(1-params[3])));
g1_v[54]=1;
g1_v[55]=(-(exp(y[32])*y[22]^params[4]*y[26]^(1-params[4])));
g1_v[56]=1;
g1_v[57]=1;
g1_v[58]=1/y[33];
g1_v[59]=1;
g1_v[60]=1;
g1_v[61]=1;
g1_v[62]=(-((1-params[2]+params[3]*y[47]/y[39])*params[1]*(y[37]*params[10]*y[45]^(params[8]-1)*get_power_deriv(y[37],1-params[8],1)-params[10]*y[45]^(params[8]-1)*y[37]^(1-params[8]))/(y[37]*y[37])));
g1_v[63]=(-(params[1]*params[10]*y[45]^(params[8]-1)*y[37]^(1-params[8])/y[37]*params[3]*(-y[47])/(y[39]*y[39])));
g1_v[64]=(-((1-params[2]+params[3]*y[47]/y[39])*params[1]*y[37]^(1-params[8])*params[10]*get_power_deriv(y[45],params[8]-1,1)/y[37]));
g1_v[65]=(-(params[1]*params[10]*y[45]^(params[8]-1)*y[37]^(1-params[8])/y[37]*params[3]*1/y[39]));
g1_v[66]=(-1);
g1_v[67]=(-1);
g1_v[68]=(-1);
end
    return nothing
end

