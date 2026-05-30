function T = static_resid_tt(T, y, x, params)
% function T = static_resid_tt(T, y, x, params)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%
% Output:
%   T         [#temp variables by 1]  double   vector of temporary terms
%

assert(length(T) >= 5);

T(1) = (y(34)/params(30))^params(48);
TEF_0 = Ftfct(y(28));
T(2) = TEF_0;
TEF_1 = Atfct(y(28));
T(3) = TEF_1;
T(4) = params(9)*y(19)^params(4);
T(5) = y(18)^(1-params(4));

end
