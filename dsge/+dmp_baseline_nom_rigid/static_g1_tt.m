function T = static_g1_tt(T, y, x, params)
% function T = static_g1_tt(T, y, x, params)
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

assert(length(T) >= 9);

T = dmp_baseline_nom_rigid.static_resid_tt(T, y, x, params);

T(6) = getPowerDeriv(y(2)/(1+params(8)*(params(3)-1)*y(6)),1-params(3),1);
T(7) = getPowerDeriv((1+params(8)*(params(3)-1)*y(6))/y(2),params(3),1);
TEFD_fdd_0_1 = jacob_element('Ftfct',1,{y(28)});
T(8) = TEFD_fdd_0_1;
TEFD_fdd_1_1 = jacob_element('Atfct',1,{y(28)});
T(9) = TEFD_fdd_1_1;

end
