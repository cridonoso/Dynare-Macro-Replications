function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 59
    @assert length(y) == 18
    @assert length(x) == 3
    @assert length(params) == 10
@inbounds begin
g1_v[1]=1;
g1_v[2]=(y[1]*params[10]*y[9]^(params[8]-1)*get_power_deriv(y[1],1-params[8],1)-params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8]))/(y[1]*y[1])-(params[3]*y[11]/y[3]+1-params[2])*params[1]*(y[1]*params[10]*y[9]^(params[8]-1)*get_power_deriv(y[1],1-params[8],1)-params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8]))/(y[1]*y[1]);
g1_v[3]=(1-params[3])*y[11]/y[7]*params[10]*y[9]^(params[8]-1)*get_power_deriv(y[1],1-params[8],1)-(1-params[4])*y[12]/y[8]*(1-params[10])*y[10]^(params[8]-1)*get_power_deriv(y[1],1-params[8],1);
g1_v[4]=(-(y[11]/y[7]*(1-params[3])*(y[9]^(params[8]-1)*params[10]*1/y[1]*get_power_deriv(y[1],1-params[8],1)+y[1]^(1-params[8])*y[9]^(params[8]-1)*params[10]*(-1)/(y[1]*y[1]))));
g1_v[5]=params[3]*y[11]/y[3]*params[10]*y[9]^(params[8]-1)*get_power_deriv(y[1],1-params[8],1)-params[4]*y[12]/y[4]*(1-params[10])*y[10]^(params[8]-1)*get_power_deriv(y[1],1-params[8],1);
g1_v[6]=1-(1-params[2]);
g1_v[7]=(-1);
g1_v[8]=(-(params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])/y[1]*params[1]*params[3]*(-y[11])/(y[3]*y[3])));
g1_v[9]=params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])*params[3]*(-y[11])/(y[3]*y[3]);
g1_v[10]=(-(y[7]^(1-params[3])*exp(y[13])*get_power_deriv(y[3],params[3],1)));
g1_v[11]=1;
g1_v[12]=(-(y[1]^(1-params[8])*(1-params[10])*y[10]^(params[8]-1)*params[4]*(-y[12])/(y[4]*y[4])));
g1_v[13]=(-(y[8]^(1-params[4])*exp(y[14])*get_power_deriv(y[4],params[4],1)));
g1_v[14]=1;
g1_v[15]=1;
g1_v[16]=(-1);
g1_v[17]=1;
g1_v[18]=(-params[9])/(y[6]*y[6]);
g1_v[19]=1;
g1_v[20]=params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])*(1-params[3])*(-y[11])/(y[7]*y[7]);
g1_v[21]=(-((1-params[3])*y[1]^(1-params[8])*y[9]^(params[8]-1)*params[10]*1/y[1]*(-y[11])/(y[7]*y[7])));
g1_v[22]=(-(exp(y[13])*y[3]^params[3]*get_power_deriv(y[7],1-params[3],1)));
g1_v[23]=(-((-y[11])/(y[7]*y[7])));
g1_v[24]=(-1);
g1_v[25]=1;
g1_v[26]=(-(y[1]^(1-params[8])*(1-params[10])*y[10]^(params[8]-1)*(1-params[4])*(-y[12])/(y[8]*y[8])));
g1_v[27]=(-(exp(y[14])*y[4]^params[4]*get_power_deriv(y[8],1-params[4],1)));
g1_v[28]=(-(params[10]*get_power_deriv(y[9],params[8],1)*get_power_deriv(params[10]*y[9]^params[8]+(1-params[10])*y[10]^params[8],1/params[8],1)));
g1_v[29]=y[1]^(1-params[8])*params[10]*get_power_deriv(y[9],params[8]-1,1)/y[1]-(params[3]*y[11]/y[3]+1-params[2])*params[1]*y[1]^(1-params[8])*params[10]*get_power_deriv(y[9],params[8]-1,1)/y[1];
g1_v[30]=(1-params[3])*y[11]/y[7]*y[1]^(1-params[8])*params[10]*get_power_deriv(y[9],params[8]-1,1);
g1_v[31]=(-(y[11]/y[7]*(1-params[3])*y[1]^(1-params[8])*params[10]*1/y[1]*get_power_deriv(y[9],params[8]-1,1)));
g1_v[32]=params[3]*y[11]/y[3]*y[1]^(1-params[8])*params[10]*get_power_deriv(y[9],params[8]-1,1);
g1_v[33]=1;
g1_v[34]=(-(get_power_deriv(params[10]*y[9]^params[8]+(1-params[10])*y[10]^params[8],1/params[8],1)*(1-params[10])*get_power_deriv(y[10],params[8],1)));
g1_v[35]=(-((1-params[4])*y[12]/y[8]*y[1]^(1-params[8])*(1-params[10])*get_power_deriv(y[10],params[8]-1,1)));
g1_v[36]=(-(params[4]*y[12]/y[4]*y[1]^(1-params[8])*(1-params[10])*get_power_deriv(y[10],params[8]-1,1)));
g1_v[37]=1;
g1_v[38]=(-(params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])/y[1]*params[1]*params[3]*1/y[3]));
g1_v[39]=params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])*(1-params[3])*1/y[7];
g1_v[40]=(-((1-params[3])*y[1]^(1-params[8])*y[9]^(params[8]-1)*params[10]*1/y[1]*1/y[7]));
g1_v[41]=params[10]*y[9]^(params[8]-1)*y[1]^(1-params[8])*params[3]*1/y[3];
g1_v[42]=1;
g1_v[43]=(-1);
g1_v[44]=(-((1-params[7])*0.2/(y[11]*0.2)));
g1_v[45]=(-(1/y[7]));
g1_v[46]=(-1);
g1_v[47]=(-(y[1]^(1-params[8])*(1-params[10])*y[10]^(params[8]-1)*(1-params[4])*1/y[8]));
g1_v[48]=(-(y[1]^(1-params[8])*(1-params[10])*y[10]^(params[8]-1)*params[4]*1/y[4]));
g1_v[49]=1;
g1_v[50]=(-1);
g1_v[51]=(-(exp(y[13])*y[3]^params[3]*y[7]^(1-params[3])));
g1_v[52]=1-params[5];
g1_v[53]=(-(exp(y[14])*y[4]^params[4]*y[8]^(1-params[4])));
g1_v[54]=1-params[6];
g1_v[55]=1;
g1_v[56]=1/y[15]-params[7]*1/y[15];
g1_v[57]=1;
g1_v[58]=1;
g1_v[59]=1;
end
    return nothing
end

