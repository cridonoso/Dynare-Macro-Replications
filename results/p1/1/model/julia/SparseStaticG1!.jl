function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 23
    @assert length(y) == 7
    @assert length(x) == 1
    @assert length(params) == 6
@inbounds begin
g1_v[1]=1;
g1_v[2]=(-1);
g1_v[3]=(-(1/y[5]));
g1_v[4]=(-1)/(y[2]*y[2])-(params[3]*exp(y[6])*y[3]^(params[3]-1)*y[5]^(1-params[3])+1-params[2])*params[1]*(-1)/(y[2]*y[2]);
g1_v[5]=params[6]/(1-y[5]);
g1_v[6]=1;
g1_v[7]=1;
g1_v[8]=(-(1/y[2]*params[1]*y[5]^(1-params[3])*params[3]*exp(y[6])*get_power_deriv(y[3],params[3]-1,1)));
g1_v[9]=(-(y[5]^(-params[3])*exp(y[6])*(1-params[3])*get_power_deriv(y[3],params[3],1)));
g1_v[10]=1-(1-params[2])-y[5]^(1-params[3])*exp(y[6])*get_power_deriv(y[3],params[3],1);
g1_v[11]=(-(y[5]^(1-params[3])*exp(y[6])*get_power_deriv(y[3],params[3],1)));
g1_v[12]=1;
g1_v[13]=(-(1/y[2]*params[1]*params[3]*exp(y[6])*y[3]^(params[3]-1)*get_power_deriv(y[5],1-params[3],1)));
g1_v[14]=y[2]*params[6]/((1-y[5])*(1-y[5]))-exp(y[6])*(1-params[3])*y[3]^params[3]*get_power_deriv(y[5],(-params[3]),1);
g1_v[15]=(-(exp(y[6])*y[3]^params[3]*get_power_deriv(y[5],1-params[3],1)));
g1_v[16]=(-(exp(y[6])*y[3]^params[3]*get_power_deriv(y[5],1-params[3],1)));
g1_v[17]=(-((-y[1])/(y[5]*y[5])));
g1_v[18]=(-(1/y[2]*params[1]*params[3]*exp(y[6])*y[3]^(params[3]-1)*y[5]^(1-params[3])));
g1_v[19]=(-(exp(y[6])*(1-params[3])*y[3]^params[3]*y[5]^(-params[3])));
g1_v[20]=(-(y[5]^(1-params[3])*exp(y[6])*y[3]^params[3]));
g1_v[21]=(-(y[5]^(1-params[3])*exp(y[6])*y[3]^params[3]));
g1_v[22]=1-params[4];
g1_v[23]=1;
end
    return nothing
end

