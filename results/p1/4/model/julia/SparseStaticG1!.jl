function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 19
    @assert length(y) == 7
    @assert length(x) == 2
    @assert length(params) == 7
@inbounds begin
g1_v[1]=1;
g1_v[2]=(-1)/(y[1]*y[1])-(1+y[5]^(1-params[3])*exp(y[6])*params[3]*y[4]^(params[3]-1)-params[2])*params[1]*(-1)/(y[1]*y[1]);
g1_v[3]=(-(y[3]*(1-params[3])*(-1)/(y[1]*y[1])/y[5]));
g1_v[4]=1;
g1_v[5]=(-1);
g1_v[6]=1;
g1_v[7]=(-1);
g1_v[8]=(-((1-params[3])*1/y[1]/y[5]));
g1_v[9]=(-(y[5]^(1-params[3])*exp(y[6])*get_power_deriv(y[4],params[3],1)));
g1_v[10]=1-(1-params[2]);
g1_v[11]=(-(1/y[1]*params[1]*y[5]^(1-params[3])*exp(y[6])*params[3]*get_power_deriv(y[4],params[3]-1,1)));
g1_v[12]=(-(exp(y[6])*y[4]^params[3]*get_power_deriv(y[5],1-params[3],1)));
g1_v[13]=(-(1/y[1]*params[1]*exp(y[6])*params[3]*y[4]^(params[3]-1)*get_power_deriv(y[5],1-params[3],1)));
g1_v[14]=params[5]/((1-y[5])*(1-y[5]))-(-(y[3]*(1-params[3])*1/y[1]))/(y[5]*y[5]);
g1_v[15]=(-(exp(y[6])*y[4]^params[3]*y[5]^(1-params[3])));
g1_v[16]=1-params[4];
g1_v[17]=(-(1/y[1]*params[1]*y[5]^(1-params[3])*exp(y[6])*params[3]*y[4]^(params[3]-1)));
g1_v[18]=1;
g1_v[19]=1/y[7]-params[6]*1/y[7];
end
    return nothing
end

