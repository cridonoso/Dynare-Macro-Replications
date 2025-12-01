function SparseDynamicG2!(T::Vector{<: Real}, g2_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g2_v) == 36
    @assert length(y) == 33
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
g2_v[1]=(y[13]+y[13])/(y[13]*y[13]*y[13]*y[13]);
g2_v[2]=(-((params[3]*exp(y[28])*y[14]^(params[3]-1)*y[27]^(1-params[3])+1-params[2])*params[1]*(y[24]+y[24])/(y[24]*y[24]*y[24]*y[24])));
g2_v[3]=(-(params[1]*(-1)/(y[24]*y[24])*y[27]^(1-params[3])*params[3]*exp(y[28])*get_power_deriv(y[14],params[3]-1,1)));
g2_v[4]=(-(params[1]*(-1)/(y[24]*y[24])*params[3]*exp(y[28])*y[14]^(params[3]-1)*get_power_deriv(y[27],1-params[3],1)));
g2_v[5]=(-(params[3]*exp(y[28])*y[14]^(params[3]-1)*y[27]^(1-params[3])*params[1]*(-1)/(y[24]*y[24])));
g2_v[6]=(-(params[1]*1/y[24]*y[27]^(1-params[3])*params[3]*exp(y[28])*get_power_deriv(y[14],params[3]-1,2)));
g2_v[7]=(-(params[1]*1/y[24]*params[3]*exp(y[28])*get_power_deriv(y[14],params[3]-1,1)*get_power_deriv(y[27],1-params[3],1)));
g2_v[8]=(-(params[1]*1/y[24]*y[27]^(1-params[3])*params[3]*exp(y[28])*get_power_deriv(y[14],params[3]-1,1)));
g2_v[9]=(-(params[1]*1/y[24]*params[3]*exp(y[28])*y[14]^(params[3]-1)*get_power_deriv(y[27],1-params[3],2)));
g2_v[10]=(-(params[1]*1/y[24]*params[3]*exp(y[28])*y[14]^(params[3]-1)*get_power_deriv(y[27],1-params[3],1)));
g2_v[11]=(-(params[1]*1/y[24]*params[3]*exp(y[28])*y[14]^(params[3]-1)*y[27]^(1-params[3])));
g2_v[12]=params[6]/((1-y[16])*(1-y[16]));
g2_v[13]=(-(y[16]^(-params[3])*(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],2)));
g2_v[14]=(-((1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],1)*get_power_deriv(y[16],(-params[3]),1)));
g2_v[15]=(-(y[16]^(-params[3])*(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],1)));
g2_v[16]=y[13]*(-(params[6]*((-(1-y[16]))-(1-y[16]))))/((1-y[16])*(1-y[16])*(1-y[16])*(1-y[16]))-(1-params[3])*exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],(-params[3]),2);
g2_v[17]=(-((1-params[3])*exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],(-params[3]),1)));
g2_v[18]=(-((1-params[3])*exp(y[17])*y[3]^params[3]*y[16]^(-params[3])));
g2_v[19]=(-(y[16]^(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],2)));
g2_v[20]=(-(exp(y[17])*get_power_deriv(y[3],params[3],1)*get_power_deriv(y[16],1-params[3],1)));
g2_v[21]=(-(y[16]^(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],1)));
g2_v[22]=(-(exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],1-params[3],2)));
g2_v[23]=(-(exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],1-params[3],1)));
g2_v[24]=(-(exp(y[17])*y[3]^params[3]*y[16]^(1-params[3])));
g2_v[25]=(-(y[16]^(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],2)));
g2_v[26]=(-(exp(y[17])*get_power_deriv(y[3],params[3],1)*get_power_deriv(y[16],1-params[3],1)));
g2_v[27]=(-(y[16]^(1-params[3])*exp(y[17])*get_power_deriv(y[3],params[3],1)));
g2_v[28]=(-(exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],1-params[3],2)));
g2_v[29]=(-(exp(y[17])*y[3]^params[3]*get_power_deriv(y[16],1-params[3],1)));
g2_v[30]=(-(exp(y[17])*y[3]^params[3]*y[16]^(1-params[3])));
g2_v[31]=(-((-1)/(y[16]*y[16])));
g2_v[32]=(-((-((-y[12])*(y[16]+y[16])))/(y[16]*y[16]*y[16]*y[16])));
g2_v[33]=(-((-1)/(y[12]*y[12])));
g2_v[34]=(-((-1)/(y[13]*y[13])));
g2_v[35]=(-((-1)/(y[15]*y[15])));
g2_v[36]=(-((-1)/(y[16]*y[16])));
end
    return nothing
end

