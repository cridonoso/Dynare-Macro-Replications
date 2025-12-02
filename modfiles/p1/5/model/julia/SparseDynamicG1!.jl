function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 56
    @assert length(y) == 45
    @assert length(x) == 2
    @assert length(params) == 13
@inbounds begin
g1_v[1]=(-(y[20]^(1-params[3])*exp(y[26])*params[10]*get_power_deriv(params[10]*y[2],params[3],1)));
g1_v[2]=(-(y[21]^(1-params[4])*exp(y[27])*(1-params[10])*get_power_deriv((1-params[10])*y[2],params[4],1)));
g1_v[3]=(-(1-params[2]));
g1_v[4]=(-params[5]);
g1_v[5]=(-params[6]);
g1_v[6]=1;
g1_v[7]=1/y[16]*params[9]*y[22]^(params[7]-1)*get_power_deriv(y[16],1-params[7],1)+params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*(-1)/(y[16]*y[16]);
g1_v[8]=y[24]/y[20]*(1-params[3])*params[9]*y[22]^(params[7]-1)*get_power_deriv(y[16],1-params[7],1)-y[25]/y[21]*(1-params[4])*(1-params[9])*y[23]^(params[7]-1)*get_power_deriv(y[16],1-params[7],1);
g1_v[9]=(-(((1-params[3])*params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*y[24]/y[20]+(1-params[4])*y[16]^(1-params[7])*(1-params[9])*y[23]^(params[7]-1)*y[25]/y[21])*(-2)/(2*y[16]*2*y[16])+1/(2*y[16])*(y[24]/y[20]*(1-params[3])*params[9]*y[22]^(params[7]-1)*get_power_deriv(y[16],1-params[7],1)+y[25]/y[21]*(1-params[4])*(1-params[9])*y[23]^(params[7]-1)*get_power_deriv(y[16],1-params[7],1))));
g1_v[10]=1;
g1_v[11]=(-(params[1]*params[9]*y[37]^(params[7]-1)*y[31]^(1-params[7])*1/y[31]*params[3]*(-(params[10]*y[39]))/(params[10]*y[17]*params[10]*y[17])));
g1_v[12]=1;
g1_v[13]=(-1);
g1_v[14]=1;
g1_v[15]=(-params[8])/(y[19]*y[19]);
g1_v[16]=1;
g1_v[17]=(-(exp(y[26])*(params[10]*y[2])^params[3]*get_power_deriv(y[20],1-params[3],1)));
g1_v[18]=(1-params[3])*params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*(-y[24])/(y[20]*y[20]);
g1_v[19]=(-(1/(2*y[16])*(1-params[3])*params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*(-y[24])/(y[20]*y[20])));
g1_v[20]=(-((-y[24])/(y[20]*y[20])));
g1_v[21]=(-1);
g1_v[22]=1;
g1_v[23]=(-(exp(y[27])*((1-params[10])*y[2])^params[4]*get_power_deriv(y[21],1-params[4],1)));
g1_v[24]=(-((1-params[4])*y[16]^(1-params[7])*(1-params[9])*y[23]^(params[7]-1)*(-y[25])/(y[21]*y[21])));
g1_v[25]=(-(1/(2*y[16])*(1-params[4])*y[16]^(1-params[7])*(1-params[9])*y[23]^(params[7]-1)*(-y[25])/(y[21]*y[21])));
g1_v[26]=(-(params[9]*get_power_deriv(y[22],params[7],1)*get_power_deriv(params[9]*y[22]^params[7]+(1-params[9])*y[23]^params[7],1/params[7],1)));
g1_v[27]=1;
g1_v[28]=1/y[16]*y[16]^(1-params[7])*params[9]*get_power_deriv(y[22],params[7]-1,1);
g1_v[29]=y[24]/y[20]*(1-params[3])*y[16]^(1-params[7])*params[9]*get_power_deriv(y[22],params[7]-1,1);
g1_v[30]=(-(1/(2*y[16])*y[24]/y[20]*(1-params[3])*y[16]^(1-params[7])*params[9]*get_power_deriv(y[22],params[7]-1,1)));
g1_v[31]=(-(get_power_deriv(params[9]*y[22]^params[7]+(1-params[9])*y[23]^params[7],1/params[7],1)*(1-params[9])*get_power_deriv(y[23],params[7],1)));
g1_v[32]=1;
g1_v[33]=(-(y[25]/y[21]*(1-params[4])*y[16]^(1-params[7])*(1-params[9])*get_power_deriv(y[23],params[7]-1,1)));
g1_v[34]=(-(1/(2*y[16])*y[25]/y[21]*(1-params[4])*y[16]^(1-params[7])*(1-params[9])*get_power_deriv(y[23],params[7]-1,1)));
g1_v[35]=1;
g1_v[36]=(-1);
g1_v[37]=(1-params[3])*params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*1/y[20];
g1_v[38]=(-(1/(2*y[16])*(1-params[3])*params[9]*y[22]^(params[7]-1)*y[16]^(1-params[7])*1/y[20]));
g1_v[39]=(-(1/y[20]));
g1_v[40]=(-1);
g1_v[41]=1;
g1_v[42]=(-1);
g1_v[43]=(-((1-params[4])*y[16]^(1-params[7])*(1-params[9])*y[23]^(params[7]-1)*1/y[21]));
g1_v[44]=(-(1/(2*y[16])*(1-params[4])*y[16]^(1-params[7])*(1-params[9])*y[23]^(params[7]-1)*1/y[21]));
g1_v[45]=(-(y[20]^(1-params[3])*exp(y[26])*(params[10]*y[2])^params[3]));
g1_v[46]=1;
g1_v[47]=(-(y[21]^(1-params[4])*exp(y[27])*((1-params[10])*y[2])^params[4]));
g1_v[48]=1;
g1_v[49]=1;
g1_v[50]=1;
g1_v[51]=1;
g1_v[52]=(-((1-params[2]+params[3]*y[39]/(params[10]*y[17]))*params[1]*(1/y[31]*params[9]*y[37]^(params[7]-1)*get_power_deriv(y[31],1-params[7],1)+params[9]*y[37]^(params[7]-1)*y[31]^(1-params[7])*(-1)/(y[31]*y[31]))));
g1_v[53]=(-((1-params[2]+params[3]*y[39]/(params[10]*y[17]))*params[1]*1/y[31]*y[31]^(1-params[7])*params[9]*get_power_deriv(y[37],params[7]-1,1)));
g1_v[54]=(-(params[1]*params[9]*y[37]^(params[7]-1)*y[31]^(1-params[7])*1/y[31]*params[3]*1/(params[10]*y[17])));
g1_v[55]=(-1);
g1_v[56]=(-1);
end
    return nothing
end

