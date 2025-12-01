function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 35
    @assert length(y) == 33
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
g1_v[1]=(-(y[16]^(-params[3])*(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],1)));
g1_v[2]=(-(1-params[2]))-y[16]^(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],1);
g1_v[3]=(-(y[16]^(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],1)));
g1_v[4]=(-params[4]);
g1_v[5]=1;
g1_v[6]=(-1);
g1_v[7]=(-(1/y[16]));
g1_v[8]=(-(1/y[12]));
g1_v[9]=(-1)/(y[13]*y[13]);
g1_v[10]=params[6]/(1-y[16]);
g1_v[11]=1;
g1_v[12]=1;
g1_v[13]=(-(1/y[13]));
g1_v[14]=(-(params[1]*1/y[24]*y[27]^(1-params[3])*params[3]*exp(y[28])*get_power_deriv(y[14],params[3]-1,1)));
g1_v[15]=1;
g1_v[16]=1;
g1_v[17]=(-(1/y[15]));
g1_v[18]=y[13]*params[6]/((1-y[16])*(1-y[16]))-(1-params[3])*exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],(-params[3]),1);
g1_v[19]=(-(exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],1-params[3],1)));
g1_v[20]=(-(exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],1-params[3],1)));
g1_v[21]=(-((-y[12])/(y[16]*y[16])));
g1_v[22]=(-(1/y[16]));
g1_v[23]=(-((1-params[3])*exp(y[17])*y[3]^params[3]*y[16]^(-params[3])));
g1_v[24]=(-(exp(y[17])*y[3]^params[3]*y[16]^(1-params[3])));
g1_v[25]=(-(exp(y[17])*y[3]^params[3]*y[16]^(1-params[3])));
g1_v[26]=1;
g1_v[27]=1;
g1_v[28]=1;
g1_v[29]=1;
g1_v[30]=1;
g1_v[31]=1;
g1_v[32]=(-((params[3]*exp(y[28])*y[14]^(params[3]-1)*y[27]^(1-params[3])+1-params[2])*params[1]*(-1)/(y[24]*y[24])));
g1_v[33]=(-(params[1]*1/y[24]*params[3]*exp(y[28])*y[14]^(params[3]-1)*get_power_deriv(y[27],1-params[3],1)));
g1_v[34]=(-(params[1]*1/y[24]*params[3]*exp(y[28])*y[14]^(params[3]-1)*y[27]^(1-params[3])));
g1_v[35]=(-1);
end
    return nothing
end

