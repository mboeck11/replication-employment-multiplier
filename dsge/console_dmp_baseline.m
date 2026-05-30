% =========================================================================
% console_dmp_baseline.m
%
% Steady-state solver for the auxiliary DMP model variants.
% Called at pre-processing time by:
%   dmp_baseline_nom_rigid_MP.mod
%   dmp_baseline_nom_rigid_nrh.mod
%   dmp_baseline_nrh.mod
%   dmp_baseline_all_frictions.mod
%   dmp_baseline_FirCos_in_GBC.mod
%   dmp_baseline_G_in_PF.mod
%   dmp_baseline_5_shocks.mod
%   dmp_baseline_rw_rigid.mod
%
% Solves the steady state analytically (no symbolic toolbox needed).
% Saves all steady-state values and calibrated parameters to
% par_dmp_baseline.mat.
%
% Parameter vector layout (22 elements):
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
%   x_(20) phi_pi     Taylor rule: inflation response       [NOTE: positions
%   x_(21) thetaP     Calvo price stickiness                 20-21 differ
%   x_(22) xi         share of non-Ricardian households      from console_baseline.m]
% =========================================================================

%% Structural Parameters (MONTHLY calibration)
     eta = x_(1);            % workers bargaining power
  varphi = x_(2);            % unemployment benefit replacement rate
varsigma = x_(3);            % job survival rate
     tau = x_(4);            % labor taxes

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

thetaP=x_(21);               % Calvo price stickiness
phi_pi=x_(20);               % Taylor rule parameter for inflation
xi=x_(22);                   % share of non-ricardian households

mbar=p/(theta^(1-gamma));    % efficiency of matching
q=mbar*theta^(-gamma);       % vacancy filling probability
n=p/(1+p-varsigma);          % employment rate
u=1-n;                       % unemployment rate
v=theta*u;                   % vacancy 
m=mbar*u^(gamma)*v^(1-gamma);% total matches
R=1/betta;                   % real interest rate
Ft=(rhot-rhob)/(1-rhob);     % Ftilde: endogenous job destruction rate/probability
at=logninv(Ft,mua,siga);     % atilde: idiosyncratic job productivity
At=integral(@(x) x.*lognpdf(x,mua,siga),at,Inf)/(1-logncdf(at,mua,siga)); % Atilde: conditional expectation of idiosyncratic job productivity

y=tfp*n*At;                  % output
g=gshare*y;                  % public spending
mpl= y/n;                    % marginal product of labor

b1=betta*((1-rhot)*(1+varsigma*(1-rhob)*Ft)/(1-betta*(1-rhot))+varsigma*(1-rhob)*Ft);
b2=betta*(1-rhot)/(1-betta*(1-rhot));
b3=1-(1)*varphi*(1-eta)/(1-tau)+eta*betta*varsigma*(1-rhob)*Ft;
b4=eta*betta*theta/b3 + 1/(b1*q);
kappa=(b2/b1-(zeta*(1-eta)+eta*(1-tau))/(b3*(1-tau))) * mpl/b4;
%kappaV=((1-eta)*(1-zeta)*mpl)/((1-betta*varsigma)/q+betta*eta*theta);

w=mpl*(zeta*(1-eta)+eta*(1-tau))/(b3*(1-tau)) + eta*betta*kappa*theta/b3;
Fn=(mpl-w*(1+varsigma*(1-rhot)*Ft))/(1-betta*(1-rhot));   % Fn
mrs=zeta*mpl;                % mrs

Ts=tau*w*n-varphi*w*(1-n)-g; % Ts
c=y-g-kappa*v-Ft*(1-rhot)*(n+q*v)*varsigma*w;               % consumption

kg=g/0.05;
%kg=(1-0.05)*kg(-1)+g;

%-------------------
% old
phi=mrs/(sigma*c-mrs*(sigma-1)*n);      % parameter for labor disutility 
lambda=((1+(sigma-1)*phi*n)/c)^(sigma); % marginal utility of consumption
un=-sigma*phi*(c/(1+(sigma-1)*phi*n))^(1-sigma); % marginal disutility of labor
Hn=((1-tau)*w-varphi*w-mrs)/((1-rhot-p)*betta);

%phi1=3;
% new
%phi=mrs/(n^phi1 * c^sigma);      % parameter for labor disutility 
%lambda=c^(-sigma); % marginal utility of consumption
%un=-phi*n^phi1; % marginal disutility of labor
%Hn=((1-tau)*w-varphi*w-mrs)/((1-rhot-p)*betta);
%-------------------
const = w-varsigma*w-kappa/q-y/n;

check_=kappa;     % 'check' should always be >0

pss=p; thetass=theta; gss=g; Tsss=Ts; Ftss=Ft; atss=at; Atss=At; rhotss=rhot; kgss=kg;

if check_>0
else
    disp('check condition: kappa>0 not satisfied'); stop
end

save par_dmp_baseline betta alpha tfp rhog sigma gamma eta varsigma varphi ...
    tau pss thetass zeta mbar kappa Tsss phi gss thetaP phi_pi rhorw rhob  ...
    mua siga Ftss atss Atss rhotss xi kgss shock   % save parameters to use them in Dynare

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