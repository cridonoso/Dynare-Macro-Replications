function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 45
    @assert length(y) == 13
    @assert length(x) == 2
    @assert length(params) == 13
@inbounds begin
g1_v[1]=1;
g1_v[2]=1/y[1]*params[9]*y[7]^(params[7]-1)*get_power_deriv(y[1],1-params[7],1)+params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*(-1)/(y[1]*y[1])-(1-params[2]+params[3]*y[9]/(params[10]*y[2]))*params[1]*(1/y[1]*params[9]*y[7]^(params[7]-1)*get_power_deriv(y[1],1-params[7],1)+params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*(-1)/(y[1]*y[1]));
g1_v[3]=y[9]/y[5]*(1-params[3])*params[9]*y[7]^(params[7]-1)*get_power_deriv(y[1],1-params[7],1)-y[10]/y[6]*(1-params[4])*(1-params[9])*y[8]^(params[7]-1)*get_power_deriv(y[1],1-params[7],1);
g1_v[4]=(-(((1-params[3])*params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*y[9]/y[5]+(1-params[4])*y[1]^(1-params[7])*(1-params[9])*y[8]^(params[7]-1)*y[10]/y[6])*(-2)/(2*y[1]*2*y[1])+1/(2*y[1])*(y[9]/y[5]*(1-params[3])*params[9]*y[7]^(params[7]-1)*get_power_deriv(y[1],1-params[7],1)+y[10]/y[6]*(1-params[4])*(1-params[9])*y[8]^(params[7]-1)*get_power_deriv(y[1],1-params[7],1))));
g1_v[5]=(-(y[5]^(1-params[3])*exp(y[11])*params[10]*get_power_deriv(params[10]*y[2],params[3],1)));
g1_v[6]=(-(y[6]^(1-params[4])*exp(y[12])*(1-params[10])*get_power_deriv(y[2]*(1-params[10]),params[4],1)));
g1_v[7]=1-(1-params[2]);
g1_v[8]=(-(params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*1/y[1]*params[1]*params[3]*(-(y[9]*params[10]))/(params[10]*y[2]*params[10]*y[2])));
g1_v[9]=1;
g1_v[10]=(-1);
g1_v[11]=1;
g1_v[12]=(-params[8])/(y[4]*y[4]);
g1_v[13]=1;
g1_v[14]=(-(exp(y[11])*(params[10]*y[2])^params[3]*get_power_deriv(y[5],1-params[3],1)));
g1_v[15]=(1-params[3])*params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*(-y[9])/(y[5]*y[5]);
g1_v[16]=(-(1/(2*y[1])*(1-params[3])*params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*(-y[9])/(y[5]*y[5])));
g1_v[17]=(-((-y[9])/(y[5]*y[5])));
g1_v[18]=1;
g1_v[19]=(-(exp(y[12])*(y[2]*(1-params[10]))^params[4]*get_power_deriv(y[6],1-params[4],1)));
g1_v[20]=(-((1-params[4])*y[1]^(1-params[7])*(1-params[9])*y[8]^(params[7]-1)*(-y[10])/(y[6]*y[6])));
g1_v[21]=(-(1/(2*y[1])*(1-params[4])*y[1]^(1-params[7])*(1-params[9])*y[8]^(params[7]-1)*(-y[10])/(y[6]*y[6])));
g1_v[22]=(-(params[9]*get_power_deriv(y[7],params[7],1)*get_power_deriv(params[9]*y[7]^params[7]+(1-params[9])*y[8]^params[7],1/params[7],1)));
g1_v[23]=1;
g1_v[24]=1/y[1]*y[1]^(1-params[7])*params[9]*get_power_deriv(y[7],params[7]-1,1)-(1-params[2]+params[3]*y[9]/(params[10]*y[2]))*params[1]*1/y[1]*y[1]^(1-params[7])*params[9]*get_power_deriv(y[7],params[7]-1,1);
g1_v[25]=y[9]/y[5]*(1-params[3])*y[1]^(1-params[7])*params[9]*get_power_deriv(y[7],params[7]-1,1);
g1_v[26]=(-(1/(2*y[1])*y[9]/y[5]*(1-params[3])*y[1]^(1-params[7])*params[9]*get_power_deriv(y[7],params[7]-1,1)));
g1_v[27]=(-(get_power_deriv(params[9]*y[7]^params[7]+(1-params[9])*y[8]^params[7],1/params[7],1)*(1-params[9])*get_power_deriv(y[8],params[7],1)));
g1_v[28]=1;
g1_v[29]=(-(y[10]/y[6]*(1-params[4])*y[1]^(1-params[7])*(1-params[9])*get_power_deriv(y[8],params[7]-1,1)));
g1_v[30]=(-(1/(2*y[1])*y[10]/y[6]*(1-params[4])*y[1]^(1-params[7])*(1-params[9])*get_power_deriv(y[8],params[7]-1,1)));
g1_v[31]=1;
g1_v[32]=(-1);
g1_v[33]=(-(params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*1/y[1]*params[1]*params[3]*1/(params[10]*y[2])));
g1_v[34]=(1-params[3])*params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*1/y[5];
g1_v[35]=(-(1/(2*y[1])*(1-params[3])*params[9]*y[7]^(params[7]-1)*y[1]^(1-params[7])*1/y[5]));
g1_v[36]=(-(1/y[5]));
g1_v[37]=1;
g1_v[38]=(-1);
g1_v[39]=(-((1-params[4])*y[1]^(1-params[7])*(1-params[9])*y[8]^(params[7]-1)*1/y[6]));
g1_v[40]=(-(1/(2*y[1])*(1-params[4])*y[1]^(1-params[7])*(1-params[9])*y[8]^(params[7]-1)*1/y[6]));
g1_v[41]=(-(y[5]^(1-params[3])*exp(y[11])*(params[10]*y[2])^params[3]));
g1_v[42]=1-params[5];
g1_v[43]=(-(y[6]^(1-params[4])*exp(y[12])*(y[2]*(1-params[10]))^params[4]));
g1_v[44]=1-params[6];
g1_v[45]=1;
end
    return nothing
end

