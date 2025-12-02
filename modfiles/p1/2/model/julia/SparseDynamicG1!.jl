function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 35
    @assert length(y) == 30
    @assert length(x) == 1
    @assert length(params) == 9
@inbounds begin
g1_v[1]=(-(1-params[2]));
g1_v[2]=(-(1-params[2]));
g1_v[3]=(-(y[13]^(1-params[3])*y[16]*get_power_deriv(y[4],params[3],1)));
g1_v[4]=(-(params[4]*1/y[6]));
g1_v[5]=(-(params[8]*(1-params[9])));
g1_v[6]=(-(1-params[8]));
g1_v[7]=(-1)/(y[11]*y[11]);
g1_v[8]=y[12]/y[13]*(1-params[3])*(-1)/(y[11]*y[11]);
g1_v[9]=1;
g1_v[10]=1/y[11]*(1-params[3])*1/y[13];
g1_v[11]=(-1);
g1_v[12]=1;
g1_v[13]=(-(1/y[13]));
g1_v[14]=1/y[11]*(1-params[3])*(-y[12])/(y[13]*y[13]);
g1_v[15]=params[9];
g1_v[16]=1;
g1_v[17]=(-(y[16]*y[4]^params[3]*get_power_deriv(y[13],1-params[3],1)));
g1_v[18]=(-((-y[12])/(y[13]*y[13])));
g1_v[19]=(-(params[1]*1/y[21]*params[3]*(-y[22])/(y[14]*y[14])));
g1_v[20]=1;
g1_v[21]=1;
g1_v[22]=(-1);
g1_v[23]=(-(y[4]^params[3]*y[13]^(1-params[3])));
g1_v[24]=1/y[16];
g1_v[25]=1;
g1_v[26]=(-((-(params[5]*params[9]))/(y[18]*y[18])));
g1_v[27]=1;
g1_v[28]=1;
g1_v[29]=(-1);
g1_v[30]=1;
g1_v[31]=(-(params[1]*(params[3]*y[22]/y[14]+1-params[2])*(-1)/(y[21]*y[21])));
g1_v[32]=(-(params[1]*1/y[21]*params[3]*1/y[14]));
g1_v[33]=(-(params[1]*(-(params[5]*params[8]*(1-params[9])))/(y[28]*y[28])));
g1_v[34]=(-(params[1]*(1-params[8])));
g1_v[35]=(-1);
end
    return nothing
end

