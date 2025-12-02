function SparseStaticG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 19
    @assert length(y) == 9
    @assert length(x) == 2
    @assert length(params) == 14
@inbounds begin
g1_v[1]=1-params[1];
g1_v[2]=(-(1/params[2]));
g1_v[3]=(-params[9]);
g1_v[4]=(-params[14]);
g1_v[5]=(-1);
g1_v[6]=(-params[10]);
g1_v[7]=1;
g1_v[8]=(-1);
g1_v[9]=1;
g1_v[10]=1;
g1_v[11]=1/params[2];
g1_v[12]=1;
g1_v[13]=(-(1/params[2]));
g1_v[14]=1;
g1_v[15]=(-((-params[2])*params[12]*(1-params[7])));
g1_v[16]=(-params[12]);
g1_v[17]=1-params[7];
g1_v[18]=(-(1-params[8]));
g1_v[19]=1-params[8];
end
    return nothing
end

