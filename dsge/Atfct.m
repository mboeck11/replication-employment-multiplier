function At=Atfct(at)
% Atfct  Conditional expectation of idiosyncratic job productivity.
%
%   At = Atfct(at) computes A(at) = E[a | a >= at], where a is
%   log-normally distributed with mean mua and std siga (in logs).
%   This corresponds to Eq. (3.4) in the paper.
%   Declared as an external_function in the Dynare model files.
%
%   Input:  at  -- endogenous separation threshold (scalar)
%   Output: At  -- conditional expectation of productivity above threshold
%   Globals: mua, siga (set in console_baseline.m / console_dmp_baseline.m)

global mua siga
At=integral(@(x) x.*lognpdf(x,mua,siga),at,Inf)/(1-logncdf(at,mua,siga));