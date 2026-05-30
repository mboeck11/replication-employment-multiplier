% =========================================================================
% console_baseline.m
%
% Steady-state solver for the main NK-DMP model.
% Called at pre-processing time by:
%   dmp_baseline_nom_rigid.mod
%   dmp_baseline_nom_rigid_matching.mod
%   dmp_baseline_nom_rigid_alt_main_res.mod
%
% Receives the 28-element parameter vector x_ and the shock selector
% vector (shock) from the calling Dynare script. Solves a linear 5x5
% system symbolically (using MATLAB's Symbolic Math Toolbox) for the
% endogenous steady-state variables: firm value of employment (Fn),
% wage (w), vacancy cost (kappa), household value of employment (Hn),
% and marginal rate of substitution (mrs). Saves all steady-state values
% and calibrated parameters to par_dmp_baseline.mat.
%
% Parameter vector layout (28 elements):
%   x_(1)  eta        workers' bargaining power
%   x_(2)  varphi     unemployment benefit replacement rate
%   x_(3)  varsigma   firing cost rate (employment protection)
%   x_(4)  tau        labor income tax rate
%   x_(5)  betta      discount factor
%   x_(6)  alpha      elasticity of production w.r.t. labor
%   x_(7)  gshare     government spending share in steady state
%   x_(8)  tfp        TFP level in steady state
%   x_(9)  rhog       AR(1) persistence of government spending shock
%   x_(10) sigma      consumption-leisure complementarity parameter
%   x_(11) gamma      elasticity of matches w.r.t. unemployment
%   x_(12) p          job-finding probability in steady state
%   x_(13) theta      labor market tightness in steady state
%   x_(14) zeta       ratio of MRS to MPL in steady state
%   x_(15) rhorw      degree of real wage rigidity
%   x_(16) rhob       exogenous job separation rate
%   x_(17) mua        mean of log-normal idiosyncratic productivity
%   x_(18) siga       std. dev. of log-normal idiosyncratic productivity
%   x_(19) rhot       overall job separation rate in steady state
%   x_(20) thetaP     Calvo price stickiness
%   x_(21) phi_pi     Taylor rule: inflation response
%   x_(22) phi_y      Taylor rule: output response
%   x_(23) rho_i      interest rate smoothing
%   x_(24) xi         share of non-Ricardian households
%   x_(25) hb         habit formation
%   x_(26) gammaP     inflation indexation of prices
%   x_(27) FCBC       firing costs in gov. budget constraint (0/1)
%   x_(28) alphaG     elasticity of public capital in production
% =========================================================================

%% Structural Parameters (MONTHLY calibration)
eta=x_(1); % workers bargaining power
varphi=x_(2); % unemployment benefit replacement rate
varsigma=x_(3); % job survival rate
tau=x_(4); % labor taxes

betta=x_(5);                 % discount factor
alpha=x_(6);                 % elasticity of production wrt labor
gshare=x_(7);                % share of public spending in ss
tfp=x_(8);                   % TFP in SS = Abar        
rhog=x_(9);                  % AR(1) coefficient for gov spending shock
sigma=x_(10);                % complementarity parameter: if 1, consumption and labor are separable
gamma=x_(11);                % elasticity of matches wrt unemployment 
p=x_(12);                    % job finding probability
theta=x_(13);                % labor market tightness
zeta=x_(14);                 % mrs/mpl 
rhorw=x_(15);                % extent of real wage rigidity
rhob=x_(16);                 % exogenous job destruction
global mua siga

mua=x_(17);                  % mean of log(a) with a: idiosyncratic job productivity
siga=x_(18);                 % sigma of log(a) with a: idiosyncratic job productivity

rhot=x_(19);                 % rhotilde: job separation rate (endo+exo)

thetaP=x_(20);               % Calvo price stickiness
phi_pi=x_(21);               % Taylor rule parameter for inflation
phi_y=x_(22);                % Taylor rule parameter for output
rho_i=x_(23);                % extent of interest rate smoothing
xi=x_(24);                   % share of non-ricardian households
hb=x_(25);                   % extent of habit formation by private HH  
gammaP=x_(26);               % extent of infltion indexation of prices (gammaP)
FCBC=x_(27);                 % 1 / 0 parameter. if =1: firing costs are in the budget constraint as revenues
alphaG=x_(28);               % elasticity of public capital stock in production function

mbar=p/(theta^(1-gamma));    % efficiency of matching
q=mbar*theta^(-gamma);       % vacancy filling probability
n=(1-rhot)*p/((1-rhot)*p+rhot);       % employment rate (old)
u=1-n;                       % unemployment rate
v=theta*u;                   % vacancy 
m=mbar*u^(gamma)*v^(1-gamma);% total matches
R=1/betta;                   % real interest rate
Ft=(rhot-rhob)/(1-rhob);     % Ftilde: endogenous job destruction rate/probability
at=logninv(Ft,mua,siga);     % atilde: idiosyncratic job productivity
At=integral(@(x) x.*lognpdf(x,mua,siga),at,Inf)/(1-logncdf(at,mua,siga));

y=tfp*n*At;                  % output
g=gshare*y;                  % public spending
mpl=y/n;                    % marginal product of labor
mc=2/(2-1);                 % markup in ss

syms x_Fn x_w x_kappa x_Hn x_mrs
eqn1=x_Fn==mc*mpl-x_w+betta*((1-rhot)*x_Fn-(0+varsigma*x_w)*(1-rhob)*Ft);
eqn2=x_kappa/q==betta*((1-rhot)*x_Fn-(0+varsigma*x_w)*(1-rhob)*Ft);
eqn3=x_w==(1-eta)*(x_mrs+0+varphi*x_w)/(1-tau)+eta*(mc*mpl+betta*(x_kappa*theta-(0+varsigma*x_w)*(1-rhob)*Ft));
eqn4=x_Hn==(1-tau)*x_w-(0+varphi*x_w)-x_mrs+betta*(1-rhot-p)*x_Hn;
eqn5=x_mrs==zeta*mpl;
eqns = [eqn1 eqn2 eqn3 eqn4 eqn5];
S = solve(eqns,[x_Fn x_w x_kappa x_Hn x_mrs],ReturnConditions=true);

Fn=double(S.x_Fn); Fnss=Fn;
w=double(S.x_w); wss=w;
kappa=double(S.x_kappa);
Hn=double(S.x_Hn); Hnss=Hn;
mrs=double(S.x_mrs); mrsss=mrs;     

Ts=tau*w*n-varphi*w*(1-n)-g; Tsss=Ts;
c=y-g-kappa*v*(0)-(1-FCBC)*Ft*(1-rhot)*(n+q*v)*varsigma*w;
cR=(1-xi)*c;
cN=xi*c;
iss=R;

phi=mrs/(sigma*cR-mrs*(sigma-1)*n);      % parameter for labor disutility 
lambda=((1+(sigma-1)*phi*n)/cR)^(sigma); % marginal utility of consumption
un=-sigma*phi*(cR/(1+(sigma-1)*phi*n))^(1-sigma); % marginal disutility of labor
mrscnst=mrs+un/lambda;

bu=varphi*w;
bs=varsigma*w;

kg=g/0.05; kgss=kg;
const=w-(varsigma*w+kappa/q+mpl*mc);
constt=cN-(xi*((1-tau)*w*n + bu*u + Ts));

check_=kappa;     % 'check' should always be >0
shockG=shock(1); shockA=shock(2); shockMP=shock(3);

pss=p; thetass=theta; gss=g;  Ftss=Ft; atss=at; Atss=At; rhotss=rhot; tfpss=tfp;
mcss=mc; yss=y;

if check_>0
else
    disp('check condition: kappa>0 not satisfied'); stop
end

save par_dmp_baseline betta alpha tfpss rhog sigma gamma eta varsigma varphi rho_i ...
    tau pss thetass zeta mbar kappa Tsss phi gss thetaP phi_pi phi_y rhorw rhob  ...
    mua siga Ftss atss Atss rhotss xi kgss iss mcss yss Fnss wss Hnss mrscnst mrsss ...
    gammaP hb constt FCBC alphaG shockG shockA shockMP % save parameters to use them in Dynare

kontrolle_ss = [{'c/y'},{c/y}; ...
    {'g/y'},{g/y}; ...
    {'kappa v/y'},{kappa*v/y}; ...
    {'mpl'},{mpl}; ...
    {'mrs'},{mrs}; ...
    {'kappa'},{kappa}; ...
    {'check'},{check_}; ...
    {'Fn'},{Fn}; ...
    {'q'},{q}; ...
    {'p'},{p}; ...
    {'m'},{m}; ...
    {'theta'},{theta}; ...
    {'w'},{w}; ...
    {'Ts/y'},{Ts/y}; ...
    {'wn/y'},{w*n/y}; ...
    {'varphi w u/y'},{varphi*w*u/y}; ...
    {'y'},{y}; ...
    {'n'},{n};...
    {'Hn'},{Hn};...
    {'un'},{un};...
    {'phi'},{phi};...
    {'lambda'},{lambda};...
    {'-un/lambda'},{-un/lambda}
    {'Ft'},{Ft};...
    {'at'},{at};...
    {'At'},{At}; ...
    {'const'},{const};...
    {'FiCo/y'},{Ft*(1-rhot)*(n+q*v)*varsigma*w/y}]; 
 %disp(kontrolle_ss);
 %stop