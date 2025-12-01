function dynamic_set_auxiliary_series!(ds, params)
#
# Computes auxiliary variables of the dynamic model
#
@inbounds begin
ds.AUX_EXO_LEAD_50 .=1 ./ds.c .*params[1] .*exp.((-(params[8] .+ds.e_a))) .*(1 .+ds.y .*params[3] ./lag(ds.k) .-params[2]);
end
end
