function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 5
    T = [T; NaN(5 - size(T, 1), 1)];
end
T(1) = (y(78)/params(30))^params(48);
TEF_0 = Ftfct(y(72));
T(2) = TEF_0;
TEF_1 = Atfct(y(72));
T(3) = TEF_1;
T(4) = params(9)*y(63)^params(4);
T(5) = y(62)^(1-params(4));
end
