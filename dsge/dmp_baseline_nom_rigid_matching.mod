% =========================================================================
% dmp_baseline_nom_rigid_matching.mod  --  IRF MATCHING MODEL
%
% Boeck, Crespo Cuaresma, and Glocker (2026):
% "Labor Market Institutions, Fiscal Multipliers, and
%  Macroeconomic Volatility"
%
% Extension of dmp_baseline_nom_rigid.mod for the IRF matching exercise
% in Section 4. The model is identical to the primary baseline except that
% it includes a structured optimization loop to match model-implied IRFs
% to empirical IRFs from the interacted panel VAR.
%
% Optimization: Uses CMA-ES (default) or csminwel (@#define CMAES=0)
% Objective function: IRF_matching_objective.m
% Empirical IRFs: read from IRF_emp_nov.xlsx (must be present in working
%   directory or update the path on the xlsread calls below)
%
% Optimized parameters: rhog, thetaP, gammaP, sigma, gamma, mua, siga,
%   zeta, alphaG  (see IRF_matching_objective.m for details)
% Target variables: g, y, n, w (glog, ylog, nlog, wlog)
% LMI combinations: 3 institutions x 2 levels (Low/High) = 6 estimates
%
% Steady-state solver: console_baseline.m
% External functions: Atfct.m, Ftfct.m
% =========================================================================

console_baseline;

@#define IRF_periods=21
@#define CMAES=1
@#define fgro=4

% list of endogenous variables
var
c             % Aggregate consumption 
cR            % consumption of Ricardians
cN            % consumption of non-Ricardians
g             % public spending
y             % output
n             % employment

R             % real interest rate
B             % government bonds
Ts            % government subsidies

bu            % unemployment benefit replacement
bs            % firing costs
w             % real wage rate
mpl           % marginal product of labor (employment)
mrs           % marginal rate of substitution between c and n

Lambda        % stochastic discount factor
lambda        % marginal utility of consumption (=u_c)
un            % marginal disutility of working: -marg.util = (marg.disutil)

v             % vacancy
u             % unemployment rate

p             % job finding probability
q             % vacancy filling probability
theta         % labor market tightness
m             % number of new matches

Fn            % value of employment to firm
Hn            % value of employment to household
S             % total surplus

Ft            % endogenous job separation rate/probability
at            % idiosyncratic job productivity
At            % conditional expectation of at
rhot          % overall job separation rate/probability

mc            % real marginal costs
pi            % inflation rate
i             % nominal rate of interest
kg            % public capital stock
yn            % labor productivity
ls            % labor share
tfp           % total factor producivity
clog wlog ylog thetalog nlog glog ulog     % log variables to have IRFs in percentage deviations from the ss
;

% Exogenous Variables/Functions%%%%%%%%%%%%%%%%%%%%%%%
varexo 
vg            % general shock [to be specified]
;  
   
external_function(name = Ftfct);    external_function(name = Atfct); 

%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters

betta        % discount factor [not "beta", which is a built in function]
alpha        % elasticity of production wrt labor
sigma        % CRRA of consumption | complementarity labor/consumption.
gamma        % elasticity of matches wrt unemployment
eta          % workers bargaining power
varsigma     % firing cost rate wrt previous wage
kappa        % vacancy cost
phi          % labor disutility
mbar         % efficiency of matching function
tau          % tax rate on labor income
varphi       % unemployment benefit replacement rate wrt previous wage
tfpss        % steady state technology parameter
rhob         % exogenous job separation rate/probability
mua          % mean of log(at)
siga         % std of log(at)
thetaP       % degree of price stickiness
phi_pi       % inflation sensitivity of nominal interest rate
phi_y        % output sensitivity of nominal interest rate
rho_i        % extent of interest rate smoothing 
gss thetass pss Tsss Ftss atss Atss rhotss iss mcss 
kgss yss Fnss Hnss mrsss wss % steady state values
mrscnst      % normalizing constant for mrs 
rhog         % public spending persistence
const        % some constant to get steady state right
constt
zeta         % = mrs/mpl
shockG shockA shockMP       % a shock vector G, A, MP, betta, m, eta, kap, atil
gammaP       % extension: inflation indexation of prices
rhorw        % extension: real wage rigidity
xi           % extension: share of ricardian households
FCBC         % extension: for firing costs in the budget constraint as revenues [1 / 0 parameter. if =1: ]
alphaG       % extension: for G bzw. public K in PF [in [0,1] - elasticity of public capital stock in production function]
;

load par_dmp_baseline;  % load mat file created in console
set_param_value ('betta',betta);    set_param_value ('alpha',alpha); 
set_param_value ('sigma',sigma);    set_param_value ('gamma',gamma);
set_param_value ('eta',eta);        set_param_value ('varsigma',varsigma); 
set_param_value ('kappa',kappa);    set_param_value ('phi',phi);
set_param_value ('mbar',mbar);      set_param_value ('tau',tau); 
set_param_value ('varphi',varphi);  set_param_value ('wss',wss);
set_param_value ('rhog',rhog);      set_param_value ('zeta',zeta);
set_param_value ('rhob',rhob);      set_param_value ('mua',mua);
set_param_value ('siga',siga);      set_param_value ('const',const);
set_param_value ('gss',g);          set_param_value ('thetass',theta); 
set_param_value ('Tsss',Ts);        set_param_value ('iss',iss); 
set_param_value ('mcss',mcss);      set_param_value ('pss',p); 
set_param_value ('Ftss',Ft);        set_param_value ('atss',at); 
set_param_value ('Atss',At);        set_param_value ('rhotss',rhot); 
set_param_value ('thetaP',thetaP);  set_param_value ('phi_pi',phi_pi);
set_param_value ('phi_y',phi_y);    set_param_value ('rho_i',rho_i);
set_param_value ('mrscnst',mrscnst);set_param_value ('mrsss',mrsss);
set_param_value ('Hnss',Hn);        set_param_value ('rhorw',rhorw);
set_param_value ('gammaP',gammaP);  set_param_value ('xi',xi);
set_param_value ('constt',constt);  set_param_value ('FCBC',FCBC);
set_param_value ('kgss',kgss);      set_param_value ('alphaG',alphaG);
set_param_value ('tfpss',tfpss);    set_param_value ('Hnss',Hn);
set_param_value ('Fnss',Fn);        set_param_value ('yss',y);
set_param_value ('shockG',shockG);  set_param_value ('shockA',shockA);
set_param_value ('shockMP',shockMP);
%%
%%%%%%%%%%%%%%%%%%%%%% Non-Linear Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model;
% Households
1=Lambda*R/(1+pi(1));
Lambda=betta*lambda(1)/lambda;
Hn=(1-tau)*w-bu-mrs+(1-rhot(1)-p(1))*Lambda*Hn(1);
mrs=mrscnst - un/lambda;
un=-sigma*phi*(cR/(1+(sigma-1)*phi*n))^(1-sigma); 
lambda=((1+(sigma-1)*phi*n)/cR)^(sigma); % lambda=uc (mind notation)

%c=(1-xi)*cR+xi*cN;
c=cR+cN;
cN=xi*((1-tau)*w*n + bu*u + Ts) + constt;

% Firms
y=tfp*n*At*(kg/kgss)^(alphaG);
Ft=Ftfct(at); % Ft=logncdf(at,mua,siga);
At=Atfct(at); % At=integral(@(x) x.*lognpdf(x,mua,siga),at,Inf)/(1-Ft);
kappa/q=Lambda*( (1-rhot(1))*Fn(1) - bs(1)*(1-rhob)*Ft(1) );
Fn=mpl*mc-w+Lambda*( (1-rhot(1))*Fn(1)-bs(1)*(1-rhob)*Ft(1) );
mpl=y/n;
w=bs+kappa/q+mpl*mc+const;
tfp=(1-rhog)*tfpss+rhog*tfp(-1) + vg*shockA;

% price rigidity, monetary policy and the shock (vg)
 %pi=betta*pi(+1) + (1-thetaP)*(1-thetaP*betta)/thetaP * log(mc/mcss); % no inflation indexation of prices
 pi=betta*pi(+1) + (1-thetaP)*(1-thetaP*betta)/thetaP * log(mc/mcss) + gammaP*(pi(-1)-thetaP*betta*pi); % with inflation indexation of prices
i=iss+rho_i*(i(-1)-iss)+(1-rho_i)*(phi_pi*pi + phi_y*log(y/yss)) + vg*shockMP; 
i-iss=log(R*betta);

% Labor market
n=(1-rhot)*(n(-1)+q(-1)*v(-1));
rhot=rhob+(1-rhob)*Ft;
u=1-n;
q=m/v;
p=m/u;
theta=v/u;
m=mbar*u^(gamma)*v^(1-gamma);

% Wage bargaining
    %w=(1-eta)*(mrs+bu)/(1-tau)+eta*( mpl*mc+Lambda*( kappa*theta(1)-bs(1)*(1-rhob)*Ft(1))); % no rwage rigidity
    w=rhorw*w(-1)+(1-rhorw)*((1-eta)*(mrs+bu)/(1-tau)+eta*(mpl*mc+Lambda*( kappa*theta(1)-bs(1)*(1-rhob)*Ft(1)))); % with rwage rigidity 
    %eta*Fn=(1-eta)*Hn;

% Market clearing
y=c+g+kappa*v*(0)+(1-FCBC)*Ft*(1-rhob)*(n(-1)+v(-1)*q(-1))*bs;

% Gov. Budget Constraint and Fiscal Policy
FCBC*Ft*(1-rhob)*(n(-1)+v(-1)*q(-1))*bs+tau*w*n+B=R(-1)*B(-1)+bu*u+Ts+g;
bu=0+varphi*w(-1);
bs=0+varsigma*w(-1);
g=(1-rhog)*gss+rhog*g(-1)+vg*shockG;
Ts=Tsss-0.15*B;
kg=(1-0.05)*kg(-1)+g; % public capital stock

% Auxiliary variables
S = Fn + Hn/(1-tau);
yn=y/n;
ls=w/yn;
  
% Log variables
clog=log(c); ylog=log(y); glog=log(g); 
thetalog=log(theta); wlog=log(w); nlog=log(n); ulog=log(u);

end;

%% Steady State

steady_state_model;                         
p=pss; theta=thetass; g=gss;
Ts=Tsss; Ft=Ftss; rhot=rhotss;
at=atss; At=Atss; mc=mcss; 
kg=kgss; pi=0; tfp=tfpss;

q=mbar*theta^(-gamma);
n=(1-rhot)*p/((1-rhot)*p+rhot);
u=1-n;                       
v=theta*u;                  
m=mbar*u^(gamma)*v^(1-gamma); 
              
R=1/betta; i=R; % because of zero ss inflation               
y=tfp*n*At;                            
mpl=y/n;           

w=wss;
Fn=Fnss; Hn=Hnss;                  
bu=varphi*w;
bs=varsigma*w;
mrs=mrsss;
c=y-g-kappa*v*(0)-(1-FCBC)*Ft*(1-rhob)*(n+v*q)*bs;               
cR=(1-xi)*c;
cN=xi*c;

lambda=((1+(sigma-1)*phi*n)/cR)^(sigma); 
un=-sigma*phi*(cR/(1+(sigma-1)*phi*n))^(1-sigma); 

mrscnst=mrs+un/lambda;
constt=cN-(xi*((1-tau)*w*n + bu*u + Ts));

S=Fn+Hn/(1-tau);
Lambda=betta;
B=(FCBC*Ft*(1-rhob)*(n+v*q)*bs+ tau*w*n-Ts-bu*(1-n)-g)/(R-1);
yn=y/n; ls=w/yn;

clog=log(c); ylog=log(y); glog=log(g);
thetalog=log(theta); wlog=log(w); nlog=log(n); ulog=log(u);
end; 
steady(nocheck); % check;

%% Shocks  and IRFs
shocks;
var vg; stderr 1;
end;

%%
%%%%%%%%%%%%% generate IRFs and compute model moments %%%%%%%%%%%%%%%%%%%%%

stoch_simul(order=1,irf=@{IRF_periods}) glog ylog nlog wlog w;

stoch_simul(irf=20,order=1,nofunctions,nocorr,nograph,noprint)
ylog nlog u wlog clog glog thetalog S ulog pi; % ylog clog nlog thetalog wlog mrs mpl Hn Fn ulog i pi R At q p v ls;

%% get empirical IRFs and weighting matrix
% [IRF_empirical,IRF_weighting,IRF_quantiles]=get_empirical_IRFs(@{IRF_periods})
LMI={'UD', 'BRR', 'EPL'};
for lh=1:2
    if lh==1 % LOW
        cod_irf='B2:E22'; cod_std='L2:O22'; % LOW LMI
    else
        cod_irf='G2:J22'; cod_std='Q2:T22'; % HIGH LMI
    end
    for i=1:size(LMI,2)
        % empirical IRFs
        IRF_emp(:,:,i,lh)=xlsread('./IRF_emp_.xlsx',LMI{i},cod_irf,'basic');
        % their variances
        IRF_var(:,:,i,lh)=xlsread('./IRF_emp_.xlsx',LMI{i},cod_std,'basic').^2;
    end
end

idx=0;
for prm=1:3 % choose LMI
    for lh=1:2 % Low and High
        % select variables 
        vsel=[1:4]; % selection of empirical variables for the matching
        LMIsel=prm; % selection of LMI
        IRF_empirical=IRF_emp(:,vsel,LMIsel,lh);
        IRF_variances=IRF_var(:,vsel,LMIsel,lh);

        IRF_weighting=inv(diag(IRF_variances(2:end)));
        IRF_weighting=eye(size(IRF_weighting,1)); % inv(diag(IRF_variances(2:end)));
        IRF_quantiles(:,:,1)=(IRF_emp(:,:,LMIsel)+2.*(IRF_var(:,:,LMIsel).^(0.5)))'; IRF_quantiles(:,:,2)=(IRF_emp(:,:,LMIsel)-2.*(IRF_var(:,:,LMIsel).^(0.5)))';
        txs = tic;

        % choose manually!
        if prm==1
            eta=xp(1,lh);
            varphi=xp(2,1);
            varsigma=xp(3,1);
        elseif prm==2
            eta=xp(1,1);
            varphi=xp(2,lh);
            varsigma=xp(3,1);
        elseif prm==3
            eta=xp(1,1);
            varphi=xp(2,1);
            varsigma=xp(3,lh);
        end

        x_start=[ rhog, thetaP, gammaP, gamma, mua, siga ]; % use calibration as starting point [rhorw xi]
        % make sure Dynare does not print out stuff during runs
        options_.nomoments=1;
        options_.nofunctions=1;
        options_.nograph=1;
        options_.verbosity=0;

        %set noprint option to suppress error messages within optimizer
        options_.noprint=1;

        @#if CMAES==0
            % set csminwel options
            H0 = 1e-2*eye(length(x_start)); %Initial Hessian 
            crit = 1e-16; %Tolerance
            nit = 1000000;  %Number of iterations

            [fhat,x_opt_hat] = csminwel(@IRF_matching_objective,x_start,H0,[],crit,nit,IRF_empirical,IRF_weighting,txs,20);
        @#else
            % set CMAES options
            H0=[]; 
            cmaesOptions = options_.cmaes;
            cmaesOptions.LBounds = [0.35; 0.55; 0.01; 0.52;-2.1; 2.3];
            cmaesOptions.UBounds = [0.49; 0.95; 0.62; 0.92; 2.1; 3.1];
            [x_opt_hat, fhat, COUNTEVAL, STOPFLAG, OUT, BESTEVER] = cmaes('IRF_matching_objective',x_start,H0,cmaesOptions,IRF_empirical,IRF_weighting,txs,20);
            x_opt_hat=BESTEVER.x;
        @#endif

        idx=idx+1;
        x_estim(:,idx)=x_opt_hat;
        disp('Parameter estimates:'); disp(x_opt_hat); disp(x_estim); disp('eta'); disp(eta);

        %get IRFs at the optimum and plot them
        [fval, IRF_model]=IRF_matching_objective(x_opt_hat,IRF_empirical,IRF_weighting);

        figure(idx)
        subplot(2,2,1)
        plot(1:options_.irf,IRF_empirical(:,1),1:options_.irf,IRF_model(:,1),1:options_.irf,IRF_quantiles(1,:,1),'r--',1:options_.irf,IRF_quantiles(1,:,2),'r--');
        title('G')
        subplot(2,2,2)
        plot(1:options_.irf,IRF_empirical(:,2),1:options_.irf,IRF_model(:,2),1:options_.irf,IRF_quantiles(2,:,1),'r--',1:options_.irf,IRF_quantiles(2,:,2),'r--');
        title('Y')

        subplot(2,2,3)
        plot(1:options_.irf,IRF_empirical(:,3),1:options_.irf,IRF_model(:,3),1:options_.irf,IRF_quantiles(3,:,1),'r--',1:options_.irf,IRF_quantiles(3,:,2),'r--');
        title('N')
        subplot(2,2,4)
        plot(1:options_.irf,IRF_empirical(:,4),1:options_.irf,IRF_model(:,4),1:options_.irf,IRF_quantiles(4,:,1),'r--',1:options_.irf,IRF_quantiles(4,:,2),'r--');
        title('RW')

        legend('Empirical','Model')
    end
end