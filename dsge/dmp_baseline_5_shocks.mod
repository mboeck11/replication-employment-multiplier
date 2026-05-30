% =========================================================================
% dmp_baseline_5_shocks.mod  --  MODEL WITH FIVE STRUCTURAL SHOCKS
%
% Boeck, Crespo Cuaresma, and Glocker (2026):
% "Labor Market Institutions, Fiscal Multipliers, and
%  Macroeconomic Volatility"
%
% DMP model variant with five structural shocks: government spending,
% TFP, monetary policy, discount factor (preference), and matching
% efficiency. Used to assess variance decompositions and the model's
% ability to account for macroeconomic volatility across different LMI
% configurations (Section 3 / Appendix).
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
em
eA
eeta
ebetta
ekap
eatil
clog wlog ylog thetalog nlog glog ulog     % log variables to have IRFs in percentage deviations from the ss
;
%%
%%%%%%%%%%%%%%%%%%%%%% Exogenous Variables/Functions%%%%%%%%%%%%%%%%%%%%%%%
varexo 
vg           % public spending shock
vm           % matching shock
vA           % technology shock
veta         % bargaining power shock
vbetta       % time preference shock
vkap         % vacancy posting shock
vatil        % idiosyncratic job productivity shock = endog. job separation shock
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

gss thetass pss Tsss Ftss atss Atss rhotss % steady state values
 
rhog         % public spending persistence
const        % some constant to get steady state right
zeta         % = mrs/mpl
sh_A sh_G sh_betta sh_m sh_eta sh_kap sh_atil % vector of shock values


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

set_param_value ('sh_G',shock(1,1));
set_param_value ('sh_A',shock(2,1));
set_param_value ('sh_betta',shock(3,1));
set_param_value ('sh_m',shock(4,1));
set_param_value ('sh_eta',shock(5,1));
set_param_value ('sh_kap',shock(6,1));
set_param_value ('sh_atil',shock(7,1));

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
set_param_value ('rhotss',rhot);

%%
%%%%%%%%%%%%%%%%%%%%%% Non-Linear Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model;
% Households
1=Lambda*R;
Lambda=ebetta*betta*lambda(1)/lambda;
Hn=(1-tau)*w-bu-mrs+(1-rhot(1)-p(1))*Lambda*Hn(1);
mrs=-un/lambda;
un=-sigma*(phi+eeta)*(c/(1+(sigma-1)*phi*n))^(1-sigma); 
lambda=((1+(sigma-1)*phi*n)/c)^(sigma); 
%un=-phi*n^(3); 
%lambda=c^(-sigma); 

% Firms
y=tfp*n^(alpha)*At*eA;
Ft=Ftfct(at); % Ft=logncdf(at,mua,siga);
At=Atfct(at); % At=integral(@(x) x.*lognpdf(x,mua,siga),at,Inf)/(1-Ft);
(kappa+ekap)/q=Lambda*( (1-rhot(1))*Fn(1) - bs(1)*(1-rhob)*Ft(1) );
Fn=mpl-w+Lambda*( (1-rhot(1))*Fn(1) - bs(1)*(1-rhob)*Ft(1) );
%kappa/q= Lambda*( (1-rhot(1))*(mpl(1)-w(1)+kappa/q(1)) - bs(1)*(1-rhob)*Ft(1) );
%Fn=0;
mpl=alpha*y/n;
w=bs+(kappa+ekap)/q+mpl + const;

% Labor market
n=(1-rhot)*(n(-1)+q(-1)*v(-1));
rhot=(rhob+eatil)+(1-(rhob+eatil))*Ft;
u=1-n;
q=m/v;
p=m/u;
theta=v/u;
m=em*mbar*u^(gamma)*v^(1-gamma);

% Wage bargaining
w=(1-eta)*(mrs-bu)/(1-tau)+eta*( mpl+Lambda*( (kappa+ekap)*theta(1)-bs(1)*(1-rhob)*Ft(1) ) ); 
% w=(1-eta)*(mrs-2*bu)/(1-tau)+eta*( mpl+Lambda*( kappa*theta(1)-bs(1)*(1-rhob)*Ft(1) ) );

% Market clearing
y=c+g+(kappa+ekap)*v+Ft*(1-(rhob+eatil))*(n(-1)+v(-1)*q(-1))*bs;

% Gov. Budget Constraint and Fiscal Policy
tau*w*n+B=R(-1)*B(-1)+bu*u+Ts+g;
bu=varphi*w(-1);
% bu=varphi*w(0);
bs=varsigma*w(-1);
%g=(1-0.73)*gss+0.73*g(-1)+vg;
g=(1-0.26)*gss+0.26*g(-1)+vg;
Ts=Tsss-0.05*B;
 
% other shocks
eA=1-0.961 + 0.61*eA(-1)+vA;
ebetta=1-0.28 + 0.28*ebetta(-1)+vbetta;
em=1-0.4 + 0.4*em(-1)+vm;
eeta=(1-0.9)*0 + 0.9*eeta(-1)+veta; % "phi" shock to households u_n (and hence to the mrs) 
ekap=1-0.78 + 0.78*ekap(-1)+vkap;
eatil=(1-0.9)*0 + 0.9*eatil(-1)+vatil; % "rho" shock to exogenous job sep. prob.

% Auxiliary variables
S = Fn + Hn/(1-tau);

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
Lambda=betta;
B=( tau*w*n-Ts-bu*(1-n)-g)/(R-1);
eA=1;
ebetta=1;
em=1;
eeta=0;
ekap=1;
eatil=0;

clog=log(c); ylog=log(y); glog=log(g);
thetalog=log(theta); wlog=log(w); nlog=log(n); ulog=log(u);

end;

%steady;
steady(nocheck);
%steady(solve_algo = 1, maxit=50000);
check;

%% Shocks
shocks;
var vg;     stderr sh_G*1;
var vA;     stderr sh_A*1;
var vbetta; stderr sh_betta*24.78;
var vm;     stderr sh_m*1.2175;
var veta;   stderr sh_eta*5.974;
var vkap;   stderr sh_kap*0.851;
var vatil;  stderr sh_atil*4.949;
%var vg;     stderr sh_G;
%var vA;     stderr sh_A;
%var vbetta; stderr sh_betta; % time preference shock
%var vm;     stderr sh_m; % shock to matching technology
%var veta;   stderr sh_eta; % shock to labor supply preference
%var vkap;   stderr sh_kap; % shock to vacancy posting costs
%var vatil;  stderr sh_atil; % shock to job separation
end;

%% IRFs
%stoch_simul(irf=20);
stoch_simul(irf=20,order=1,nofunctions,nograph,nocorr,noprint) % hp_filter=1600,pruning, nomoments,nodecomposition
ylog u clog nlog thetalog wlog glog S mrs mpl Hn Fn ulog;


