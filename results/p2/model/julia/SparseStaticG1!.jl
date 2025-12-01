function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 31
    @assert length(y) == 11
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
g1_v[1]=1;
g1_v[2]=(-1);
g1_v[3]=(-(1/y[5]));
g1_v[4]=(-(1/y[1]-1/(y[1])));
g1_v[5]=(-1)/(y[2]*y[2])-(params[3]*exp(y[6])*y[3]^(params[3]-1)*y[5]^(1-params[3])+1-params[2])*params[1]*(-1)/(y[2]*y[2]);
g1_v[6]=params[6]/(1-y[5]);
g1_v[7]=1;
g1_v[8]=1;
g1_v[9]=(-(1/y[2]-1/(y[2])));
g1_v[10]=(-(1/y[2]*params[1]*y[5]^(1-params[3])*params[3]*exp(y[6])*get_power_deriv(y[3],params[3]-1,1)));
g1_v[11]=(-(y[5]^(-params[3])*exp(y[6])*(1-params[3])*get_power_deriv(y[3],params[3],1)));
g1_v[12]=1-(1-params[2])-y[5]^(1-params[3])*exp(y[6])*get_power_deriv(y[3],params[3],1);
g1_v[13]=(-(y[5]^(1-params[3])*exp(y[6])*get_power_deriv(y[3],params[3],1)));
g1_v[14]=1;
g1_v[15]=(-(1/y[4]-1/(y[4])));
g1_v[16]=(-(1/y[2]*params[1]*params[3]*exp(y[6])*y[3]^(params[3]-1)*get_power_deriv(y[5],1-params[3],1)));
g1_v[17]=y[2]*params[6]/((1-y[5])*(1-y[5]))-exp(y[6])*(1-params[3])*y[3]^params[3]*get_power_deriv(y[5],(-params[3]),1);
g1_v[18]=(-(exp(y[6])*y[3]^params[3]*get_power_deriv(y[5],1-params[3],1)));
g1_v[19]=(-(exp(y[6])*y[3]^params[3]*get_power_deriv(y[5],1-params[3],1)));
g1_v[20]=(-((-y[1])/(y[5]*y[5])));
g1_v[21]=(-(1/y[5]-1/(y[5])));
g1_v[22]=(-(1/y[2]*params[1]*params[3]*exp(y[6])*y[3]^(params[3]-1)*y[5]^(1-params[3])));
g1_v[23]=(-(exp(y[6])*(1-params[3])*y[3]^params[3]*y[5]^(-params[3])));
g1_v[24]=(-(y[5]^(1-params[3])*exp(y[6])*y[3]^params[3]));
g1_v[25]=(-(y[5]^(1-params[3])*exp(y[6])*y[3]^params[3]));
g1_v[26]=1-params[4];
g1_v[27]=1;
g1_v[28]=1;
g1_v[29]=1;
g1_v[30]=1;
g1_v[31]=1;
end
    return nothing
end

