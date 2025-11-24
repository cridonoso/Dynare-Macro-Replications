function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 27
    @assert length(y) == 21
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
g1_v[1]=(-(y[12]^(-params[3])*(1-params[3])*exp(y[13])*get_power_deriv(y[3],params[3],1)));
g1_v[2]=(-(1-params[2]))-y[12]^(1-params[3])*exp(y[13])*get_power_deriv(y[3],params[3],1);
g1_v[3]=(-(y[12]^(1-params[3])*exp(y[13])*get_power_deriv(y[3],params[3],1)));
g1_v[4]=(-params[4]);
g1_v[5]=1;
g1_v[6]=(-1);
g1_v[7]=(-(1/y[12]));
g1_v[8]=(-1)/(y[9]*y[9]);
g1_v[9]=params[6]/(1-y[12]);
g1_v[10]=1;
g1_v[11]=1;
g1_v[12]=(-(params[1]*1/y[16]*y[19]^(1-params[3])*params[3]*exp(y[20])*get_power_deriv(y[10],params[3]-1,1)));
g1_v[13]=1;
g1_v[14]=1;
g1_v[15]=y[9]*params[6]/((1-y[12])*(1-y[12]))-(1-params[3])*exp(y[13])*y[3]^params[3]*get_power_deriv(y[12],(-params[3]),1);
g1_v[16]=(-(exp(y[13])*y[3]^params[3]*get_power_deriv(y[12],1-params[3],1)));
g1_v[17]=(-(exp(y[13])*y[3]^params[3]*get_power_deriv(y[12],1-params[3],1)));
g1_v[18]=(-((-y[8])/(y[12]*y[12])));
g1_v[19]=(-((1-params[3])*exp(y[13])*y[3]^params[3]*y[12]^(-params[3])));
g1_v[20]=(-(exp(y[13])*y[3]^params[3]*y[12]^(1-params[3])));
g1_v[21]=(-(exp(y[13])*y[3]^params[3]*y[12]^(1-params[3])));
g1_v[22]=1;
g1_v[23]=1;
g1_v[24]=(-((params[3]*exp(y[20])*y[10]^(params[3]-1)*y[19]^(1-params[3])+1-params[2])*params[1]*(-1)/(y[16]*y[16])));
g1_v[25]=(-(params[1]*1/y[16]*params[3]*exp(y[20])*y[10]^(params[3]-1)*get_power_deriv(y[19],1-params[3],1)));
g1_v[26]=(-(params[1]*1/y[16]*params[3]*exp(y[20])*y[10]^(params[3]-1)*y[19]^(1-params[3])));
g1_v[27]=(-1);
end
    return nothing
end

