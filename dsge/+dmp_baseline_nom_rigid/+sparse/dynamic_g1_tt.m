function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = dmp_baseline_nom_rigid.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 9
    T = [T; NaN(9 - size(T, 1), 1)];
end
T(6) = getPowerDeriv(y(46)/(1+params(8)*(params(3)-1)*y(50)),1-params(3),1);
T(7) = getPowerDeriv((1+params(8)*(params(3)-1)*y(50))/y(46),params(3),1);
TEFD_fdd_0_1 = jacob_element('Ftfct',1,{y(72)});
T(8) = TEFD_fdd_0_1;
TEFD_fdd_1_1 = jacob_element('Atfct',1,{y(72)});
T(9) = TEFD_fdd_1_1;
end
