% =========================================================================
% dmp_baseline_rw_rigid.mod  --  REAL WAGE RIGIDITY
%
% Boeck, Crespo Cuaresma, and Glocker (2026):
% "Labor Market Institutions, Fiscal Multipliers, and
%  Macroeconomic Volatility"
%
% DMP baseline model extended with real wage rigidity (rhorw > 0):
%   w_t = rhorw * w_{t-1} + (1-rhorw) * w^Nash_t
% This is the only additional friction relative to the DMP baseline.
% Used for Appendix B robustness (Figure B2): comparing fiscal multipliers
% under flexible vs. sticky real wages.
%
% Steady-state solver: console_dmp_baseline.m
% External functions: Atfct.m, Ftfct.m
% =========================================================================

console_dmp_baseline;

%%
%%%%%%%%%%%%%%%%%%%%%% Endogenous Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var

c             % consumption
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
un            % marginal disutility of working: marg.util = - (marg.disutil)

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

yn            % labor productivity
ls            % labor share
mu            % markup

clog wlog ylog thetalog nlog glog ulog     % log variables to have IRFs in percentage deviations from the ss
;
%%
%%%%%%%%%%%%%%%%%%%%%% Exogenous Variables/Functions%%%%%%%%%%%%%%%%%%%%%%%
varexo 
vg           % public spending shock
;  
   
external_function(name = Ftfct);    external_function(name = Atfct); 
%%
%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters

betta        % discount factor
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
tfp          % steady state technology parameter

rhob         % exogenous job separation rate/probability
mua          % mean of log(at)
siga         % std of log(at)

thetaP       % degree of price stickiness
phi_pi       % inflation sensitivity of nominal interest rate

gss thetass pss Tsss Ftss atss Atss rhotss % steady state values
 
rhog         % public spending persistence
const        % some constant to get steady state right
zeta         % = mrs/mpl
rhorw        % extent of real wage rigidity
;

load par_dmp_baseline;  % load mat file created in console
set_param_value ('betta',betta);
set_param_value ('alpha',alpha); 
set_param_value ('sigma',sigma);
set_param_value ('gamma',gamma);
set_param_value ('eta',eta);
set_param_value ('varsigma',varsigma); 
set_param_value ('kappa',kappa);
set_param_value ('phi',phi);
set_param_value ('mbar',mbar); 
set_param_value ('tau',tau); 
set_param_value ('varphi',varphi);
set_param_value ('tfp',tfp);  
set_param_value ('rhog',rhog);  
set_param_value ('zeta',zeta);

set_param_value ('rhob',rhob);
set_param_value ('mua',mua);
set_param_value ('siga',siga);
set_param_value ('const',const);

set_param_value ('gss',g); 
set_param_value ('thetass',theta);
set_param_value ('Tsss',Ts); 
set_param_value ('pss',p);
set_param_value ('Ftss',Ft);
set_param_value ('atss',at);
set_param_value ('Atss',At);
set_param_value ('rhorw',rhorw);
set_param_value ('rhotss',rhot);

set_param_value ('thetaP',thetaP);
set_param_value ('phi_pi',phi_pi);
%%
%%%%%%%%%%%%%%%%%%%%%% Non-Linear Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model;
% Households
1=Lambda*R;
Lambda=betta*lambda(1)/lambda;
Hn=(1-tau)*w-bu-mrs+(1-rhot(1)-p(1))*Lambda*Hn(1);
mrs=-un/lambda;
un=-sigma*phi*(c/(1+(sigma-1)*phi*n))^(1-sigma); 
lambda=((1+(sigma-1)*phi*n)/c)^(sigma); 

% Firms
y=tfp*n*At;
Ft=Ftfct(at); % Ft=logncdf(at,mua,siga);
At=Atfct(at); % At=integral(@(x) x.*lognpdf(x,mua,siga),at,Inf)/(1-Ft);
kappa/q=Lambda*( (1-rhot(1))*Fn(1) - bs(1)*(1-rhob)*Ft(1) );
Fn=mc*mpl-w+Lambda*( (1-rhot(1))*Fn(1) - bs(1)*(1-rhob)*Ft(1) );
mpl=y/n;
w=bs+kappa/q+mc*mpl + const;

% price rigidity and monetary policy
pi=betta*pi(+1) + (1-thetaP)*(1-thetaP*betta)/thetaP * log(mc);
i=0.2*i(-1) + (1-0.2)*(phi_pi * pi + 0.4 * log(y));
R = i-pi(+1);

% Labor market
n=(1-rhot)*(n(-1)+q(-1)*v(-1));
rhot=rhob+(1-rhob)*Ft;
u=1-n;
q=m/v;
p=m/u;
theta=v/u;
m=mbar*u^(gamma)*v^(1-gamma);

% Wage bargaining
% w=(1-eta)*(mrs+bu)/(1-tau)+eta*( mpl+Lambda*( kappa*theta(1)-bs(1)*(1-rhob)*Ft(1) ) ); 
w=rhorw*w(-1) + (1-rhorw)*( (1-eta)*(mrs+bu)/(1-tau)+eta*( mpl+Lambda*( kappa*theta(1)-bs(1)*(1-rhob)*Ft(1) ) ));

% Market clearing
y=c+g+kappa*v+Ft*(1-rhob)*(n(-1)+v(-1)*q(-1))*bs;

% Gov. Budget Constraint and Fiscal Policy
tau*w*n+B=R(-1)*B(-1)+bu*u+Ts+g;
bu=varphi*w(-1);
bs=varsigma*w(-1);
g=(1-rhog)*gss+rhog*g(-1)+vg;
Ts=Tsss-0.05*B;
 
% Auxiliary variables
S = Fn + Hn/(1-tau);
yn=y/n;
ls=w/yn;
mu=1/mc;
  
% Log variables
clog=log(c); ylog=log(y); glog=log(g);
thetalog=log(theta); wlog=log(w); nlog=log(n); ulog=log(u);

end;

%% Steady State

steady_state_model;                         
p=pss;  
theta=thetass;
g=gss;
Ts=Tsss;
Ft=Ftss;
rhot=rhotss;
at=atss;
At=Atss;

q=mbar*theta^(-gamma);
n=p/(1+p-varsigma);
u=1-n;                       
v=theta*u;                  
m=mbar*u^(gamma)*v^(1-gamma); 
              
R=1/betta;                   
y=tfp*n*At;                            
mpl=y/n;           

% const = w-varsigma*w-kappa/q-y/n;
w=(kappa/q+y/n+const)/(1-varsigma);
Fn=(mpl-w*(1+varsigma*(1-rhot)*Ft))/(1-betta*(1-rhot));                  
% w=(mpl-Fn*(1-betta*(1-rhot)*Fn))/(1+betta*varsigma*(1-rhob)*Ft);
bu=varphi*w;
bs=varsigma*w;
mrs=zeta*mpl;                
c=y-g-kappa*v-Ft*(1-rhob)*(n+v*q)*bs;               
  
lambda=((1+(sigma-1)*phi*n)/c)^(sigma); 
un=-sigma*phi*(c/(1+(sigma-1)*phi*n))^(1-sigma); 
Hn=((1-tau)*w-varphi*w-mrs)/((1-rhot-p)*betta);

S=Fn+Hn/(1-tau);
yn=y/n;
ls=w/yn;

Lambda=betta;
B=( tau*w*n-Ts-bu*(1-n)-g)/(R-1);

clog=log(c); ylog=log(y); glog=log(g);
thetalog=log(theta); wlog=log(w); nlog=log(n); ulog=log(u);
mu=1; mc=1;
end;

%steady;
steady(nocheck);
%steady(solve_algo = 1, maxit=50000);
%check;

%% Shocks
shocks;
var vg; stderr 1;
end;

%% IRFs
%stoch_simul(irf=20);
stoch_simul(irf=20,order=1,nofunctions,nograph,nocorr,noprint) % hp_filter=1600,pruning,
ylog u clog nlog thetalog wlog glog S mrs mpl Hn Fn ulog pi;


