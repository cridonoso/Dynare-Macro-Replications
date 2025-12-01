function SparseDynamicG1!(T::Vector{<: Real}, g1_v::Vector{<: Real}, y::Vector{<: Real}, x::Vector{<: Real}, params::Vector{<: Real}, steady_state::Vector{<: Real})
    @assert length(T) >= 0
    @assert length(g1_v) == 27
    @assert length(y) == 27
    @assert length(x) == 2
    @assert length(params) == 14
@inbounds begin
g1_v[1]=(-params[7]);
g1_v[2]=(-params[8]);
g1_v[3]=1;
g1_v[4]=(-params[9]);
g1_v[5]=(-params[14]);
g1_v[6]=1;
g1_v[7]=(-1);
g1_v[8]=(-params[10]);
g1_v[9]=1;
g1_v[10]=(-1);
g1_v[11]=1;
g1_v[12]=(-1);
g1_v[13]=1;
g1_v[14]=1/params[2];
g1_v[15]=1;
g1_v[16]=(-(1/params[2]));
g1_v[17]=1;
g1_v[18]=(-((-params[2])*params[12]*(1-params[7])));
g1_v[19]=(-params[12]);
g1_v[20]=1;
g1_v[21]=(-(1-params[8]));
g1_v[22]=1;
g1_v[23]=(-params[1]);
g1_v[24]=(-(1/params[2]));
g1_v[25]=(-1);
g1_v[26]=(-1);
g1_v[27]=(-1);
end
    return nothing
end

