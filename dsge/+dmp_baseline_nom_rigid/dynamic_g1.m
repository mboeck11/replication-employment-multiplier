function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
% function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
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
%   g1
%

if T_flag
    T = dmp_baseline_nom_rigid.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(44, 65);
g1(1,18)=(-(y(26)/(1+y(64))));
g1(1,26)=(-(y(18)/(1+y(64))));
g1(1,64)=(-((-(y(26)*y(18)))/((1+y(64))*(1+y(64)))));
g1(2,26)=1;
g1(2,27)=(-((-(params(1)*y(57)))/(y(27)*y(27))));
g1(2,57)=(-(params(1)/y(27)));
g1(3,21)=1;
g1(3,23)=(-(1-params(10)));
g1(3,25)=1;
g1(3,26)=(-((1-y(63)-y(58))*y(61)));
g1(3,58)=(-(y(61)*(-y(26))));
g1(3,36)=1;
g1(3,61)=(-(y(26)*(1-y(63)-y(58))));
g1(3,63)=(-(y(61)*(-y(26))));
g1(4,25)=1;
g1(4,27)=(-y(28))/(y(27)*y(27));
g1(4,28)=1/y(27);
g1(5,13)=(-((-params(3))*params(8)*1/(1+params(8)*(params(3)-1)*y(17))*T(6)));
g1(5,17)=(-((-params(3))*params(8)*T(6)*(-(y(13)*params(8)*(params(3)-1)))/((1+params(8)*(params(3)-1)*y(17))*(1+params(8)*(params(3)-1)*y(17)))));
g1(5,28)=1;
g1(6,13)=(-((-(1+params(8)*(params(3)-1)*y(17)))/(y(13)*y(13))*T(7)));
g1(6,17)=(-(T(7)*params(8)*(params(3)-1)/y(13)));
g1(6,27)=1;
g1(7,12)=1;
g1(7,13)=(-1);
g1(7,14)=(-1);
g1(8,14)=1;
g1(8,17)=(-((1-params(10))*y(23)*params(46)));
g1(8,20)=(-params(46));
g1(8,21)=(-(params(46)*y(30)));
g1(8,23)=(-(params(46)*(1-params(10))*y(17)));
g1(8,30)=(-(y(21)*params(46)));
g1(9,16)=1;
g1(9,17)=(-(T(1)*y(48)*y(40)));
g1(9,40)=(-(y(17)*y(48)*T(1)));
g1(9,45)=(-(y(17)*y(48)*y(40)*1/params(30)*getPowerDeriv(y(45)/params(30),params(48),1)));
g1(9,48)=(-(T(1)*y(17)*y(40)));
g1(10,38)=1;
g1(10,39)=(-T(8));
g1(11,39)=(-T(9));
g1(11,40)=1;
g1(12,56)=(-(y(26)*(-((1-params(13))*y(62)))));
g1(12,26)=(-((1-y(63))*y(60)-y(56)*(1-params(13))*y(62)));
g1(12,32)=(-params(7))/(y(32)*y(32));
g1(12,60)=(-(y(26)*(1-y(63))));
g1(12,62)=(-(y(26)*(-(y(56)*(1-params(13))))));
g1(12,63)=(-(y(26)*(-y(60))));
g1(13,56)=(-(y(26)*(-((1-params(13))*y(62)))));
g1(13,23)=1;
g1(13,24)=(-y(42));
g1(13,26)=(-((1-y(63))*y(60)-y(56)*(1-params(13))*y(62)));
g1(13,35)=1;
g1(13,60)=(-(y(26)*(1-y(63))));
g1(13,62)=(-(y(26)*(-(y(56)*(1-params(13))))));
g1(13,63)=(-(y(26)*(-y(60))));
g1(13,42)=(-y(24));
g1(14,16)=(-(1/y(17)));
g1(14,17)=(-((-y(16))/(y(17)*y(17))));
g1(14,24)=1;
g1(15,22)=(-1);
g1(15,23)=1;
g1(15,24)=(-y(42));
g1(15,32)=(-((-params(7))/(y(32)*y(32))));
g1(15,42)=(-y(24));
g1(16,11)=(-params(37));
g1(16,48)=1;
g1(16,65)=(-params(42));
g1(17,42)=(-((1-params(16))*(1-params(1)*params(16))/params(16)*1/params(29)/(y(42)/params(29))));
g1(17,8)=(-params(44));
g1(17,43)=1-params(44)*(-(params(1)*params(16)));
g1(17,64)=(-params(1));
g1(18,16)=(-((1-params(19))*params(18)*1/params(31)/(y(16)/params(31))));
g1(18,43)=(-((1-params(19))*params(17)));
g1(18,9)=(-params(19));
g1(18,44)=1;
g1(18,65)=(-params(43));
g1(19,18)=(-(params(1)/(y(18)*params(1))));
g1(19,44)=1;
g1(20,2)=(-(1-y(41)));
g1(20,17)=1;
g1(20,6)=(-((1-y(41))*y(7)));
g1(20,7)=(-((1-y(41))*y(6)));
g1(20,41)=y(2)+y(7)*y(6);
g1(21,38)=(-(1-params(13)));
g1(21,41)=1;
g1(22,17)=1;
g1(22,30)=1;
g1(23,29)=(-((-y(34))/(y(29)*y(29))));
g1(23,32)=1;
g1(23,34)=(-(1/y(29)));
g1(24,30)=(-((-y(34))/(y(30)*y(30))));
g1(24,31)=1;
g1(24,34)=(-(1/y(30)));
g1(25,29)=(-(1/y(30)));
g1(25,30)=(-((-y(29))/(y(30)*y(30))));
g1(25,33)=1;
g1(26,29)=(-(T(4)*getPowerDeriv(y(29),1-params(4),1)));
g1(26,30)=(-(T(5)*params(9)*getPowerDeriv(y(30),params(4),1)));
g1(26,34)=1;
g1(27,21)=(-((1-params(45))*(1-params(5))/(1-params(10))));
g1(27,56)=(-((1-params(45))*params(5)*y(26)*(-((1-params(13))*y(62)))));
g1(27,5)=(-params(45));
g1(27,23)=1;
g1(27,24)=(-((1-params(45))*y(42)*params(5)));
g1(27,25)=(-((1-params(45))*(1-params(5))/(1-params(10))));
g1(27,26)=(-((1-params(45))*params(5)*(params(7)*y(59)-y(56)*(1-params(13))*y(62))));
g1(27,59)=(-((1-params(45))*params(5)*y(26)*params(7)));
g1(27,62)=(-((1-params(45))*params(5)*y(26)*(-(y(56)*(1-params(13))))));
g1(27,42)=(-((1-params(45))*y(24)*params(5)));
g1(28,12)=(-1);
g1(28,15)=(-1);
g1(28,16)=1;
g1(28,2)=(-(y(22)*(1-params(13))*y(38)*(1-params(47))));
g1(28,22)=(-((y(2)+y(7)*y(6))*(1-params(13))*y(38)*(1-params(47))));
g1(28,6)=(-(y(22)*y(7)*(1-params(13))*y(38)*(1-params(47))));
g1(28,7)=(-(y(22)*y(6)*(1-params(13))*y(38)*(1-params(47))));
g1(28,38)=(-(y(22)*(y(2)+y(7)*y(6))*(1-params(13))*(1-params(47))));
g1(29,15)=(-1);
g1(29,2)=y(22)*(1-params(13))*y(38)*params(47);
g1(29,17)=params(10)*y(23);
g1(29,3)=(-y(4));
g1(29,4)=(-y(3));
g1(29,19)=1;
g1(29,20)=(-1);
g1(29,21)=(-y(30));
g1(29,22)=(y(2)+y(7)*y(6))*(1-params(13))*y(38)*params(47);
g1(29,23)=params(10)*y(17);
g1(29,6)=y(22)*y(7)*(1-params(13))*y(38)*params(47);
g1(29,30)=(-y(21));
g1(29,7)=y(22)*y(6)*(1-params(13))*y(38)*params(47);
g1(29,38)=y(22)*(y(2)+y(7)*y(6))*(1-params(13))*params(47);
g1(30,21)=1;
g1(30,5)=(-params(11));
g1(31,22)=1;
g1(31,5)=(-params(6));
g1(32,1)=(-params(37));
g1(32,15)=1;
g1(32,65)=(-params(41));
g1(33,19)=0.15;
g1(33,20)=1;
g1(34,15)=(-1);
g1(34,10)=(-0.95);
g1(34,45)=1;
g1(35,35)=(-1);
g1(35,36)=(-(1/(1-params(10))));
g1(35,37)=1;
g1(36,16)=(-(1/y(17)));
g1(36,17)=(-((-y(16))/(y(17)*y(17))));
g1(36,46)=1;
g1(37,23)=(-(1/y(46)));
g1(37,46)=(-((-y(23))/(y(46)*y(46))));
g1(37,47)=1;
g1(38,12)=(-(1/y(12)));
g1(38,49)=1;
g1(39,16)=(-(1/y(16)));
g1(39,51)=1;
g1(40,15)=(-(1/y(15)));
g1(40,54)=1;
g1(41,33)=(-(1/y(33)));
g1(41,52)=1;
g1(42,23)=(-(1/y(23)));
g1(42,50)=1;
g1(43,17)=(-(1/y(17)));
g1(43,53)=1;
g1(44,30)=(-(1/y(30)));
g1(44,55)=1;

end
