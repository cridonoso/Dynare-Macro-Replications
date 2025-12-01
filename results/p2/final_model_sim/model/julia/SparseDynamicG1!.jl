function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 32
    @assert length(y) == 27
    @assert length(x) == 2
    @assert length(params) == 8
@inbounds begin
g1_v[1]=(-(100*(-(1/y[1]))));
g1_v[2]=(-(params[1]*1/(y[20]*exp(y[24]))*(-(params[2]*y[19]))/(y[3]*y[3])));
g1_v[3]=(1-params[3])*exp((-y[15]));
g1_v[4]=(-(y[13]^(1-params[2])*exp((-y[15]))*get_power_deriv(y[3]*exp((-y[15])),params[2],1)));
g1_v[5]=(-(params[6]*1/y[5]));
g1_v[6]=1;
g1_v[7]=1;
g1_v[8]=(-((1-params[2])/y[13]));
g1_v[9]=(-(100*1/y[10]));
g1_v[10]=(-1)/(y[11]*y[11]);
g1_v[11]=(-1);
g1_v[12]=params[4]/(params[5]-y[13]);
g1_v[13]=(-1);
g1_v[14]=(-((y[3]*exp((-y[15])))^params[2]*get_power_deriv(y[13],1-params[2],1)));
g1_v[15]=(-((-(y[10]*(1-params[2])))/(y[13]*y[13])));
g1_v[16]=y[11]*params[4]/((params[5]-y[13])*(params[5]-y[13]));
g1_v[17]=(-(1/y[13]));
g1_v[18]=(-1);
g1_v[19]=1/y[14];
g1_v[20]=y[3]*(1-params[3])*(-exp((-y[15])));
g1_v[21]=(-(y[13]^(1-params[2])*get_power_deriv(y[3]*exp((-y[15])),params[2],1)*y[3]*(-exp((-y[15])))));
g1_v[22]=1;
g1_v[23]=(-100);
g1_v[24]=1;
g1_v[25]=1;
g1_v[26]=1;
g1_v[27]=(-1);
g1_v[28]=(-(params[1]*1/(y[20]*exp(y[24]))*params[2]/y[3]));
g1_v[29]=(-((params[2]*y[19]/y[3]+1-params[3])*params[1]*(-exp(y[24]))/(y[20]*exp(y[24])*y[20]*exp(y[24]))));
g1_v[30]=(-((params[2]*y[19]/y[3]+1-params[3])*params[1]*(-(y[20]*exp(y[24])))/(y[20]*exp(y[24])*y[20]*exp(y[24]))));
g1_v[31]=(-1);
g1_v[32]=(-1);
end
    return nothing
end

