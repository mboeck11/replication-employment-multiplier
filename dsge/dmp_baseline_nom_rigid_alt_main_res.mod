% =========================================================================
% dmp_baseline_nom_rigid_alt_main_res.mod  --  ALTERNATIVE SPECIFICATION
%
% Boeck, Crespo Cuaresma, and Glocker (2026):
% "Labor Market Institutions, Fiscal Multipliers, and
%  Macroeconomic Volatility"
%
% Alternative specification of the primary baseline model, used for
% robustness checks on the main results. Differences from
% dmp_baseline_nom_rigid.mod:
%   - Government spending shock enters directly (g = ... + vg) rather
%     than via a shock scaling factor (shockG)
%   - TFP is a fixed parameter (not a dynamic variable)
%   - Calvo parameter is rescaled (thetaP/0.77 in set_param_value)
%   - No monetary policy shock term in the Taylor rule
%
% Steady-state solver: console_baseline.m
% External functions: Atfct.m, Ftfct.m
% =========================================================================

console_baseline;
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
tfp          % steady state technology parameter
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

gammaP       % extension: inflation indexation of prices
rhorw        % extension: real wage rigidity
xi           % extension: share of ricardian households
FCBC         % extension: for firing costs in the budget constraint as revenues [1 / 0 parameter. if =1: ]
alphaG       % extension: for G bzw. public K in PF [in [0,1] - elasticity of public capital stock in production function]
;

load par_dmp_baseline;  % load mat file created in console
set_param_value ('betta',betta); set_param_value ('alpha',alpha); 
set_param_value ('sigma',sigma); set_param_value ('gamma',gamma);
set_param_value ('eta',eta); set_param_value ('varsigma',varsigma); 
set_param_value ('kappa',kappa); set_param_value ('phi',phi);
set_param_value ('mbar',mbar); set_param_value ('tau',tau); 
set_param_value ('varphi',varphi); set_param_value ('tfp',tfp);  
set_param_value ('rhog',rhog); set_param_value ('zeta',zeta);
set_param_value ('rhob',rhob); set_param_value ('mua',mua);
set_param_value ('siga',siga); set_param_value ('const',const);
set_param_value ('gss',g); set_param_value ('thetass',theta); 
set_param_value ('Tsss',Ts); set_param_value ('iss',iss); set_param_value ('Hnss',Hn);
set_param_value ('mcss',mcss); set_param_value ('pss',p); set_param_value ('Fnss',Fn);
set_param_value ('Ftss',Ft); set_param_value ('atss',at); set_param_value ('yss',y);
set_param_value ('Atss',At); set_param_value ('rhotss',rhot); set_param_value ('wss',w);
set_param_value ('thetaP',thetaP/0.77); set_param_value ('phi_pi',phi_pi);
set_param_value ('phi_y',phi_y); set_param_value ('rho_i',rho_i);
set_param_value ('mrscnst',mrscnst); set_param_value ('mrsss',mrsss);
set_param_value ('Hnss',Hn); set_param_value ('rhorw',rhorw);
set_param_value ('gammaP',gammaP); set_param_value ('xi',xi);
set_param_value ('constt',constt); set_param_value ('FCBC',FCBC);
set_param_value ('kgss',kgss); set_param_value ('alphaG',alphaG);
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

% price rigidity, monetary policy and the shock (vg)
 %pi=betta*pi(+1) + (1-thetaP)*(1-thetaP*betta)/thetaP * log(mc/mcss); % no inflation indexation of prices
 pi=betta*pi(+1) + (1-thetaP)*(1-thetaP*betta)/thetaP * log(mc/mcss) + gammaP*(pi(-1)-thetaP*betta*pi); % with inflation indexation of prices
i=iss+rho_i*(i(-1)-iss)+(1-rho_i)*(phi_pi*pi + phi_y*log(y/yss)); 
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
g=(1-rhog)*gss+rhog*g(-1)+vg;
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
kg=kgss; pi=0;

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
stoch_simul(irf=20,order=1,nofunctions,nocorr,nograph,noprint)
ylog nlog u wlog clog glog thetalog S ulog pi; % ylog clog nlog thetalog wlog mrs mpl Hn Fn ulog i pi R At q p v ls;



