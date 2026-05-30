function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = dmp_baseline_nom_rigid.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(44, 1);
    residual(1) = (1) - (y(26)*y(18)/(1+y(64)));
    residual(2) = (y(26)) - (params(1)*y(57)/y(27));
    residual(3) = (y(36)) - ((1-params(10))*y(23)-y(21)-y(25)+y(26)*(1-y(63)-y(58))*y(61));
    residual(4) = (y(25)) - (params(36)-y(28)/y(27));
    residual(5) = (y(28)) - ((-params(3))*params(8)*(y(13)/(1+params(8)*(params(3)-1)*y(17)))^(1-params(3)));
    residual(6) = (y(27)) - (((1+params(8)*(params(3)-1)*y(17))/y(13))^params(3));
    residual(7) = (y(12)) - (y(13)+y(14));
    residual(8) = (y(14)) - (params(46)*((1-params(10))*y(23)*y(17)+y(21)*y(30)+y(20))+params(39));
    residual(9) = (y(16)) - (y(17)*y(48)*y(40)*T(1));
    residual(10) = (y(38)) - (T(2));
    residual(11) = (y(40)) - (T(3));
    residual(12) = (params(7)/y(32)) - (y(26)*((1-y(63))*y(60)-y(56)*(1-params(13))*y(62)));
    residual(13) = (y(35)) - (y(26)*((1-y(63))*y(60)-y(56)*(1-params(13))*y(62))+y(24)*y(42)-y(23));
    residual(14) = (y(24)) - (y(16)/y(17));
    residual(15) = (y(23)) - (y(24)*y(42)+params(7)/y(32)+y(22)+params(38));
    residual(16) = (y(48)) - ((1-params(37))*params(12)+params(37)*y(11)+x(it_, 1)*params(42));
    residual(17) = (y(43)) - (y(64)*params(1)+(1-params(16))*(1-params(1)*params(16))/params(16)*log(y(42)/params(29))+params(44)*(y(8)-y(43)*params(1)*params(16)));
    residual(18) = (y(44)) - (params(28)+params(19)*(y(9)-params(28))+(1-params(19))*(y(43)*params(17)+params(18)*log(y(16)/params(31)))+x(it_, 1)*params(43));
    residual(19) = (y(44)-params(28)) - (log(y(18)*params(1)));
    residual(20) = (y(17)) - ((1-y(41))*(y(2)+y(7)*y(6)));
    residual(21) = (y(41)) - (params(13)+y(38)*(1-params(13)));
    residual(22) = (y(30)) - (1-y(17));
    residual(23) = (y(32)) - (y(34)/y(29));
    residual(24) = (y(31)) - (y(34)/y(30));
    residual(25) = (y(33)) - (y(29)/y(30));
    residual(26) = (y(34)) - (T(4)*T(5));
    residual(27) = (y(23)) - (params(45)*y(5)+(1-params(45))*((1-params(5))*(y(21)+y(25))/(1-params(10))+params(5)*(y(24)*y(42)+y(26)*(params(7)*y(59)-y(56)*(1-params(13))*y(62)))));
    residual(28) = (y(16)) - (y(12)+y(15)+y(22)*(y(2)+y(7)*y(6))*(1-params(13))*y(38)*(1-params(47)));
    residual(29) = (y(22)*(y(2)+y(7)*y(6))*(1-params(13))*y(38)*params(47)+y(17)*params(10)*y(23)+y(19)) - (y(15)+y(20)+y(21)*y(30)+y(3)*y(4));
    residual(30) = (y(21)) - (y(5)*params(11));
    residual(31) = (y(22)) - (y(5)*params(6));
    residual(32) = (y(15)) - ((1-params(37))*params(20)+params(37)*y(1)+x(it_, 1)*params(41));
    residual(33) = (y(20)) - (params(23)-y(19)*0.15);
    residual(34) = (y(45)) - (y(15)+0.95*y(10));
    residual(35) = (y(37)) - (y(35)+y(36)/(1-params(10)));
    residual(36) = (y(46)) - (y(16)/y(17));
    residual(37) = (y(47)) - (y(23)/y(46));
    residual(38) = (y(49)) - (log(y(12)));
    residual(39) = (y(51)) - (log(y(16)));
    residual(40) = (y(54)) - (log(y(15)));
    residual(41) = (y(52)) - (log(y(33)));
    residual(42) = (y(50)) - (log(y(23)));
    residual(43) = (y(53)) - (log(y(17)));
    residual(44) = (y(55)) - (log(y(30)));

end
