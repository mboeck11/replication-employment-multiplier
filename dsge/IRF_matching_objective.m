function [fval, IRF_model]=IRF_matching_objective(xopt,IRF_target,weighting_matrix,txs,xlm)
% IRF_matching_objective  Objective function for the IRF matching exercise.
%
% Used in the IRF matching exercise of Section 4 (connecting the
% theoretical model to the empirical IPVAR evidence). Called from within
% the optimization loop in dmp_baseline_nom_rigid_matching.mod.
%
% IRF extraction has to be set according to Dynare version used. Was run
% under Dynare 4.6.1 version.
%
% Computes the quadratic deviation of the model-implied IRFs from the
% target (empirical) IRFs by calling stoch_simul from Dynare.
%
% Parameters optimized (xopt, 9 elements): [9 tried, only 6 finally used]
%   xopt(1) rhog    -- AR(1) persistence of government spending shock
%   xopt(2) thetaP  -- Calvo price stickiness
%   xopt(3) gammaP  -- inflation indexation of prices
%   xopt(4) sigma   -- consumption-leisure complementarity
%   xopt(5) gamma   -- matching function elasticity
%   xopt(6) mua     -- mean of log-normal idiosyncratic productivity
%   xopt(7) siga    -- std. dev. of log-normal idiosyncratic productivity
%   xopt(8) zeta    -- steady-state MRS/MPL ratio
%   xopt(9) alphaG  -- public capital elasticity in production function
%
% Target IRFs: government spending, output, employment, real wage
%   (variables glog, ylog, nlog, wlog from the model)
%
% Inputs:
%   xopt             [npar x 1]              parameter vector (current step)
%   IRF_target       [nperiods x nvars]      empirical target IRFs
%   weighting_matrix [nperiods*nvars x ...]  IRF weighting matrix
%
% Outputs:
%   fval             [scalar]                quadratic objective value
%   IRF_model        [nperiods x nvars]      model-implied IRFs at xopt
%
% Notes:
%   - options_.noprint must be set before calling to allow the optimizer
%     to handle solution failures via a penalty function.
%   - IRFs use an impulse size of 1%; the objective targets all periods.
%
% Based on code by Johannes Pfeifer (C) 2017, GNU GPL v3+.
% See <http://www.gnu.org/licenses/>.

global oo_ M_ options_ %required input structures for call to stoch_simul

%% set parameter for use in Dynare
set_param_value('rhog',    xopt(1)); % first estimated parameter
set_param_value('thetaP',  xopt(2)); % second estimated parameter
set_param_value('gammaP',  xopt(3)); % ... estimated parameter
%set_param_value('sigma',   xopt(4)); % ... estimated parameter
set_param_value('gamma',   xopt(4)); % ... estimated parameter
set_param_value('mua',     xopt(5)); % ... estimated parameter
set_param_value('siga',    xopt(6)); % ... estimated parameter
%set_param_value('zeta',    xopt(8)); % ... estimated parameter
%set_param_value('alphaG',  xopt(9)); % ... estimated parameter
%set_param_value('rhorw',   xopt(4)); % ... estimated parameter
%set_param_value('xi',      xopt(4)); % ... estimated parameter
%set_param_value('alpha',   xopt(5)); % ... estimated parameter
%set_param_value('gamP',    xopt(5)); % ... estimated parameter
%set_param_value('rhob',     xopt(5)); % ... estimated parameter

% if any(xopt<=-1) || any(xopt(1)>=1) % make sure roots are between 0 and 1
%     fval=10e6+sum([xopt].^2); %penalty function
%     return
% end
if toc(txs) > xlm
    % fval = 1e12 + sum(xopt.^2); 
    return
end

vsel=[1:4]; % empirical variable selection
var_list={'glog','ylog','nlog','wlog','w'};
[info, oo_, options_, M_] = stoch_simul(M_, options_, oo_, var_list); %run stoch_simul to generate IRFs with the options specified in the mod-file

if info %solution was not successful
    fval=10e6+sum([xopt].^2); %return with penalty 
else
    % choose according to Dynare version
    IRF_model=[glog_vg' ylog_vg' nlog_vg' w_vg']; % select desired IRFs
    % IRF_model=[oo_.irfs.glog_vg' oo_.irfs.ylog_vg' oo_.irfs.nlog_vg' oo_.irfs.w_vg']; % select desired IRFs    
    %IRF_model=[IRF_model(:,vsel), IRF_model(:,vsel), IRF_model(:,vsel)];
    % compute objective function (omitting the impact response of G as that is targeted with the shock size)
    % fval=(IRF_model(2:end)-IRF_target(2:end))*weighting_matrix*(IRF_model(2:end)-IRF_target(2:end))';  % start in the first period for g
    fval=(IRF_model(1:end)-IRF_target(1:end))*(IRF_model(1:end)-IRF_target(1:end))';  % start in the first period for g
end