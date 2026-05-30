function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 5
    T = [T; NaN(5 - size(T, 1), 1)];
end
T(1) = (y(34)/params(30))^params(48);
TEF_0 = Ftfct(y(28));
T(2) = TEF_0;
TEF_1 = Atfct(y(28));
T(3) = TEF_1;
T(4) = params(9)*y(19)^params(4);
T(5) = y(18)^(1-params(4));
end
