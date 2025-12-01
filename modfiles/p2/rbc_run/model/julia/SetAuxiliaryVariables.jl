function set_auxiliary_variables!(y, x, params)
#
# Computes auxiliary variables of the static model
#
@inbounds begin
y[8]=1/y[2]*params[1]*exp((-(params[8]+x[1])))*(1+y[1]*params[3]/y[3]-params[2]);
end
end
