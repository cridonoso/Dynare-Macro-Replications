function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 20
    @assert length(y) == 8
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
g1_v[1]=1;
g1_v[2]=params[4]/(params[5]-y[4]);
g1_v[3]=(-((-(params[2]*y[3]))/(y[2]*y[2])));
g1_v[4]=1-(1-params[3])*exp((-y[6]));
g1_v[5]=(-(y[4]^(1-params[2])*exp((-y[6]))*get_power_deriv(exp((-y[6]))*y[2],params[2],1)));
g1_v[6]=(-(params[2]/y[2]));
g1_v[7]=(-1);
g1_v[8]=1;
g1_v[9]=(-((1-params[2])*1/y[4]));
g1_v[10]=(-((exp((-y[6]))*y[2])^params[2]*get_power_deriv(y[4],1-params[2],1)));
g1_v[11]=y[1]*params[4]/((params[5]-y[4])*(params[5]-y[4]))-(1-params[2])*(-y[3])/(y[4]*y[4]);
g1_v[12]=(-(1/y[4]-1/(y[4])));
g1_v[13]=1/y[5]-params[6]*1/y[5];
g1_v[14]=(-((1-params[3])*(-exp((-y[6])))));
g1_v[15]=(-((1-params[3])*y[2]*(-exp((-y[6])))));
g1_v[16]=(-(y[4]^(1-params[2])*get_power_deriv(exp((-y[6]))*y[2],params[2],1)*y[2]*(-exp((-y[6])))));
g1_v[17]=1;
g1_v[18]=(-100);
g1_v[19]=1;
g1_v[20]=1;
end
    return nothing
end

