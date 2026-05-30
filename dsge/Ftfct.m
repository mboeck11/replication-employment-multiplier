function Ft=Ftfct(at)
% Ftfct  Endogenous job separation probability.
%
%   Ft = Ftfct(at) computes F(at) = Pr(a < at), the probability that a
%   match's idiosyncratic productivity a falls below the endogenous
%   separation threshold at. a is log-normally distributed with mean mua
%   and std siga (in logs). Enters the overall separation rate in Eq. (3.2)
%   of the paper. Declared as an external_function in Dynare model files.
%
%   Input:  at  -- endogenous separation threshold (scalar)
%   Output: Ft  -- endogenous job separation probability
%   Globals: mua, siga (set in console_baseline.m / console_dmp_baseline.m)

global mua siga
Ft = logncdf(at,mua,siga); 