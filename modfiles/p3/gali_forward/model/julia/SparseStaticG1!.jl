function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 24
    @assert length(y) == 10
    @assert length(x) == 2
    @assert length(params) == 10
@inbounds begin
g1_v[1]=(-(1/params[2]));
g1_v[2]=1-params[1];
g1_v[3]=(-params[9]);
g1_v[4]=1;
g1_v[5]=(-((1-params[4])/(1-params[4]+params[4]*params[5])*(1-params[6])*(1-params[6]*params[1])/params[6]*(params[2]+(params[4]+params[3])/(1-params[4]))));
g1_v[6]=(-params[10]);
g1_v[7]=(-1);
g1_v[8]=1;
g1_v[9]=(-1);
g1_v[10]=1;
g1_v[11]=(-(1/(1-params[4])));
g1_v[12]=(-(1/params[2]));
g1_v[13]=1;
g1_v[14]=1;
g1_v[15]=1/params[2];
g1_v[16]=1;
g1_v[17]=(-1);
g1_v[18]=1;
g1_v[19]=(-((1-params[7])*(1+params[3])/(params[4]+params[3]+(1-params[4])*params[2])*(-params[2])));
g1_v[20]=(-((1+params[3])/(params[4]+params[3]+(1-params[4])*params[2])));
g1_v[21]=(-((-1)/(1-params[4])));
g1_v[22]=1-params[7];
g1_v[23]=(-(1-params[8]));
g1_v[24]=1-params[8];
end
    return nothing
end

