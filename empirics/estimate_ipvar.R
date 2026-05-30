#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Estimation of IPVAR                                            #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
# May 2026                                                                    #
#-----------------------------------------------------------------------------#
rm(list=setdiff(ls(),c("varspec","intspec","prior","plag","compute_irf_grid","compute_var_grid")))

# load packages
library(abind)
library(seasonal)
library(stringr)
library(xlsx)

# load functions
funs <- list.files("./empirics/functions", full.names=TRUE)
for(fun in funs) if(grepl("R$",fun)) source(fun)

# get data
load("./empirics/data_for_estimation.rda")
cN = names(data)

# country group: g7
cN_g7      = c("can","deu","fra","gbr","ita","jpn","usa")

# country groups according to consumption / gdp shares
cN_conshigh = c("can","fra","ita","jpn","prt","esp","usa","gbr")
cN_conslow  = c("aus","aut","bel","deu","dnk","fin","nld","swe")
cN_lmilow   = c("aus","can","deu","esp","fra","gbr","ita","jpn","usa")
cN_lmihigh  = c("aut","bel","dnk","fin","nld","prt","swe")

compute_mod  = FALSE                                                # re-compute model if already estimated and saved
compute_irf  = FALSE || compute_mod                                 # re-compute irfs if already estimated and saved OR model is new computed

# VAR settings (do not change here, but below)
vars         = c("rgovcpc", "rgdppc", "emprate", "rwage")           # endogenous variables
ivars        = c("ud","brr","epl")                                  # interaction variables
varNames     = c("Government Spending", "Real GDP",                 # variable names      
                 "Employment Rate", "Real Wage")                    
ivarNames    = c("Union Density",                                   # interaction variable names
                 "Unemployment Benefit Replacement Rate", 
                 "Employment Protection Legislation")                
exovars      = NULL                                                 # exogenous variables
exoNames     = NULL                                                 # exogenous variable names
tcode        = c(5,5,2,5)                                           # 1=level, 2=diff, 3=2nd diff, 4=log, 5=logdiff, 6=2nd logdiff
scode        = c(0,0,0,0)                                           # 0=no seas. adj; 1=seas adj.
cumul        = c(0,0,0,0)                                           # 0=no cumulation; 1=cumulation
tcode_lag    = c(4,4,4,4)                                           # number of lags for differences: 1=quarter-on-quarter; 4=year-on-year
freq         = 4                                                    # frequency of data: 4=quarterly; 12=monthly
int_eval     = matrix(c(.1,.5,.9),nrow=3,ncol=length(ivars),        # interaction variable evaluation
                      dimnames=list(c("low","med","high"),ivars))                  
int_scale    = TRUE                                                 # scaling of interaction variable (zero mean, unit standard deviation)
shock.idx    = grep("rgovc", vars)                                  # position of government spending in vars
shock.scale  = 1                                                    # scaling of shock
save_est     = TRUE                                                 # save estimation / irf results
save_plots   = TRUE                                                 # save plots
shorten_oxf  = FALSE                                                # shorten sample to availability of government spending forecasts (oxford economics)
shorten_oecd = FALSE                                                # shorten sample to availability of government spending forecasts (oecd economic outlook)
excl_covid   = FALSE                                                # exclude the covid period
comp_fm      = TRUE                                                 # compute fiscal multiplier

# VAR baseline settings
cons         = TRUE                                                 # logical for adding constant
trend        = FALSE                                                # logical for adding trend
qtrend       = FALSE                                                # logical for adding quadratic trend
SV           = FALSE                                                # logical for stochastic volatility specification
draws        = 20000                                                # number of saved draws
burnin       = 10000                                                # number of burnin draws
thin         = 4                                                    # number of thinned draws
thindraws    = draws/thin                                           # number of thinned posterior draws
nhor         = 21                                                   # impulse response horizon
emp_percs    = c(.05, .10, .16, .50, .84, .90, .95)                 # empirical quantiles
grid_size    = 100                                                  # grid size for marginal effects evaluation

# fileNames
dirName      = "./empirics/results/"
setting      = paste0(prior,"-",intspec,"-",varspec)
specName     = paste0("plag=",plag,"_draws=",draws,"_burnin=",burnin)

if(grepl("single",intspec)) idx_ivars = as.numeric(str_extract(intspec,"[0-9]"))
if(grepl("multi",intspec)) idx_ivars = 1:3
if(grepl("ud-brr",intspec)) idx_ivars = 1:2
if(grepl("ud-epl",intspec)) idx_ivars = c(1,3)

# other variable specification
if(grepl("tax",varspec)){
  vars          = c("rgovcpc","rtaxpc","rgdppc","emprate","rwage")
  varNames      = c("Government Spending", "Tax Revenue", "Real GDP", "Employment Rate", "Real Wage")
  tcode         = c(5,5,5,2,5)
  scode         = c(0,0,0,0,0)
  cumul         = c(0,0,0,0,0)
  tcode_lag     = c(4,4,4,4,4)
  shock.idx     = grep("rtaxpc", vars)
  shock.scale   = -1 
}
if(grepl("ht",varspec)){
  vars          = c("rgovcpc_ht","rgdppc_ht","emprate_ht","rwage_ht")
  tcode         = c(1,1,1,1)
  shock.idx     = grep("rgovcpc",vars)
}
if(grepl("level",varspec)){
  tcode         = c(4,4,1,4)
}
if(grepl("foresight",varspec)){
  if(grepl("oecd",varspec)){
    exovars     = "oxf_govf"
  }else if(grepl("oxf",varspec)){
    exovars     = "oecd_fcst1"
  }
  exoNames      = "Government Spending Forecast"
}
if(grepl("fe",varspec)){
  if(grepl("oecd",varspec)){
    vars        = c("rgovc_oecd_fe",vars)
  }else if(grepl("oxf",varspec)){
    vars        = c("rgovc_oxf_fe",vars)
  }
  varNames      = c("Forecast Error", varNames)
  tcode         = c(1,tcode)
  scode         = c(0,scode)
  cumul         = c(0,cumul)
  tcode_lag     = c(1,tcode_lag)
  shock.idx     = grep("rgovc_fe", vars)
}
if(grepl("fcst(-|$)",varspec)){
  if(grepl("oecd",varspec)){
    vars         = c("oecd_govf",vars)
  }else if(grepl("oxf",varspec)){
    vars         = c("oxf_govf",vars)
  }
  varNames       = c("Government Spending Forecast", varNames)
  tcode          = c(1,tcode)
  scode          = c(0,scode)
  cumul          = c(0,cumul)
  tcode_lag      = c(1,tcode_lag)
  shock.idx      = grep("rgovcpc", vars)
}
if(grepl("fcst2(-|$)",varspec)){ # based on Ilor, Paez-Farrell, and Thoenissen (2022, EER) or Born, Juessen, and Müller (2013, JEDC)
  if(grepl("oecd",varspec)){
    vars           = c(vars[1],"oecd_govf",vars[2:4])
  }else if(grepl("oxf",varspec)){
    vars           = c(vars[1],"oxf_govf",vars[2:4])
  }
  varNames       = c(varNames[1], "Government Spending Forecast", varNames[2:4])
  tcode          = c(tcode[1],1,tcode[2:4])
  scode          = c(scode[1],0,scode[2:4])
  cumul          = c(cumul[1],0,cumul[2:4])
  tcode_lag      = c(tcode_lag[1],1,tcode_lag[2:4])
  shock.idx      = grep("rgovc", vars)
}
if(grepl("stir",varspec)){
  vars           = c(vars, "int")
  varNames       = c(varNames, "Interest Rate")
  tcode          = c(tcode,1)
  scode          = c(scode,0)
  cumul          = c(cumul,0)
  tcode_lag      = c(tcode_lag,1)
}
# these have to come after foresight/fe/fcst
idx_rgdp       = grep("rgdp",vars)
idx_emprate    = grep("emprate",vars)
idx_rwage      = grep("rwage",vars)
if(grepl("emppc",varspec)){
  vars[idx_emprate]      = "emppc"
  varNames[idx_emprate]  = "Employment Pop Rate"
}
if(grepl("^unrate",varspec)){
  vars[idx_emprate]      = "unrate"
  varNames[idx_emprate]  = "Unemployment Rate"
}
if(grepl("^vu",varspec)){
  vars[idx_emprate]      = "vu"
  varNames[idx_emprate]  = "Labor Market Tigthness"
  tcode[idx_emprate]     = 2
  if(grepl("addemprate",varspec)){
    vars                 = c(vars,"emprate")
    varNames             = c(varNames,"Employment Rate")
    tcode                = c(tcode,2)
    scode                = c(scode,0)
    cumul                = c(cumul,0)
    tcode_lag            = c(tcode_lag,4)
  }
}
if(grepl("^vac(-|$)",varspec)){
  vars[idx_emprate]      = "vac"
  varNames[idx_emprate]  = "Vacancies"
  tcode[idx_emprate]     = 5
}
if(grepl("^vacrate",varspec)){
  vars[idx_emprate]      = "vacrate"
  varNames[idx_emprate]  = "Vacancy Rate"
}
if(grepl("rwagepc",varspec)){
  vars[idx_rwage]        = "rwagepc"
}
if(grepl("shortoxf",varspec)){
  shorten_oxf            = TRUE
}
if(grepl("shortoecd",varspec)){
  shorten_oecd           = TRUE
}
if(grepl("trend",varspec)){
  trend                  = TRUE
}
if(grepl("covid",varspec)){
  dumm_covid             = TRUE
}


if(grepl("conshigh",varspec)){
  cN = cN_conshigh
}else if(grepl("conslow",varspec)){
  cN = cN_conslow
}else if(grepl("lmilow",varspec)){
  cN = cN_lmilow
}else if(grepl("lmihigh",varspec)){
  cN = cN_lmihigh
}else if(grepl("g7",varspec)){
  cN = cN_g7
}

# dimensions
n = length(vars)
d = length(idx_ivars)
N = length(cN)

#---------------------------------------------------------------------------------------------------------------#
# Data Preparation                                                                                              #
#---------------------------------------------------------------------------------------------------------------#
Yraw = Draw = Exraw = Yratio = time = list()
for(cc in 1:N){
  # get country
  cntry       = cN[cc]
  
  if(grepl("vu",varspec) && cntry %in% c("can","ita")) next
  
  if(shorten_oxf){
    idx_sample = which(!apply(cbind(data[[cntry]][,c(vars,ivars[idx_ivars],exovars,"oxf_govf")]),1,function(x)any(is.na(x))))
  }else if(shorten_oecd){
    idx_sample = which(!apply(cbind(data[[cntry]][,c(vars,ivars[idx_ivars],exovars,"oecd_govf")]),1,function(x)any(is.na(x))))
  }else{
    idx_sample = which(!apply(cbind(data[[cntry]][,c(vars,ivars[idx_ivars],exovars)]),1,function(x)any(is.na(x))))
  }
  if(length(idx_sample)==0) next
  Yraw_cc       = data[[cntry]][idx_sample,vars,drop=FALSE]
  Draw_cc       = data[[cntry]][idx_sample,ivars[idx_ivars],drop=FALSE]
  Exraw_cc      = data[[cntry]][idx_sample,exovars,drop=FALSE]
  time_cc       = time(data[[cntry]])[idx_sample]
  starttime1    = get_starttime(time_cc)[[1]]
  starttime2    = get_starttime(time_cc)[[2]]
  if(is.null(exovars)) Exraw_cc = NULL
  
  Yratio[[cc]] = apply(Yraw_cc / Yraw_cc[,grepl("rgovcpc",vars)],2,mean)
  
  # de-seasonalize
  for(nn in 1:n){
    if(scode[nn] == 1) Yraw_cc[,nn] = final(seas(ts(Yraw_cc[,nn], start=starttime1, frequency=freq)))
  }
  
  # transform data
  for(nn in 1:n){
    Yraw_cc[,nn] = transx(Yraw_cc[,nn], tcode[nn], lag=tcode_lag[nn])
  }
  Yraw_cc  = ts(Yraw_cc[(max(tcode_lag)+1):nrow(Yraw_cc),,drop=FALSE],   start=starttime2, frequency=freq)
  if(!is.null(exovars)) Exraw_cc = ts(Exraw_cc[(max(tcode_lag)+1):nrow(Exraw_cc),,drop=FALSE], start=starttime2, frequency=freq)
  
  # get interaction variable
  if(int_scale) Draw_cc = apply(Draw_cc[(max(tcode_lag)+1):nrow(Draw_cc),,drop=FALSE],2,scale)
  Draw_cc = ts(Draw_cc, start=starttime2, frequency=freq)
  Draw_cc[,apply(Draw_cc,2,function(x)length(unique(x)))==1] = NA_real_
  #Draw_cc = ts(Draw_cc[(max(tcode_lag)+1):nrow(Draw_cc),,drop=FALSE], start=starttime2, frequency=freq)
  
  # get time
  time_cc = time_cc[(max(tcode_lag)+1):length(time_cc)]
  
  # exclude covid
  if(excl_covid){
    idx_covid = which(time_cc<2020)
    Yraw_cc  = Yraw_cc[idx_covid,,drop=FALSE]
    Draw_cc  = Draw_cc[idx_covid,,drop=FALSE]
    time_cc  = time_cc[idx_covid]
    if(!is.null(exovars)) Exraw_cc = Exraw_cc[idx_covid,,drop=FALSE]
  }
  plot.ts(cbind(Yraw_cc,Exraw_cc))
  
  # save data
  Yraw[[cc]]  = Yraw_cc
  Draw[[cc]]  = Draw_cc
  Exraw[[cc]] = Exraw_cc
  time[[cc]]  = time_cc
  
  rm(Yraw_cc, Exraw_cc, time_cc)
}
names(Yraw) = names(Draw) = names(time) = names(Yratio) = cN
if(length(Exraw)==0) Exraw = NULL else names(Exraw) = cN

# kill NULL in list
idx_list1 = !unlist(lapply(Yraw,is.null))
idx_list2 = !unlist(lapply(Draw,function(D)any(is.na(D))))
idx_list  = as.logical(idx_list1 * idx_list2)
Yraw = Yraw[idx_list]
Draw = Draw[idx_list]
time = time[idx_list]
if(!is.null(Exraw)) Exraw = Exraw[idx_list]
# in case of killing NULLS we have to adjust names and length
cN = names(Yraw)
N  = length(cN)

# build Dbig, Dbig_vals, Dbig_grid (for interaction analysis)
Dbig      = do.call("rbind",Draw)
Dbig_vals = sapply(1:d, function(dd)quantile(Dbig[,dd], int_eval[,dd])); dimnames(Dbig_vals)=list(rownames(int_eval), ivars[idx_ivars])
eval_grid = c("low","high")
Dbig_grid = matrix(NA_real_, grid_size, d, dimnames=list(NULL,ivars[idx_ivars]))
for(dd in 1:d){
  Dbig_grid[,dd] = seq(Dbig_vals["low",dd],Dbig_vals["high",dd], length.out=grid_size)
}
D_vals    = sapply(Draw, function(DD){
  mat = sapply(1:d, function(dd)quantile(DD[,dd], int_eval[,dd])); dimnames(mat)=list(rownames(int_eval), ivars[idx_ivars])
  return(mat)
}, simplify="array")
D_grid    = array(NA_real_, c(grid_size, d, N), dimnames=list(NULL, ivars[idx_ivars], cN))
for(cc in 1:N){for(dd in 1:d){
  D_grid[,dd,cc] = seq(D_vals["low",dd,cc],D_vals["high",dd,cc], length.out=grid_size)
}}

# Ymeans
sort(do.call("rbind",Yratio)[,grepl("rgdppc",vars)])
Yratio_mean = apply(do.call("rbind",Yratio),2,mean)
Yratio_range = apply(do.call("rbind",Yratio),2,range)
Yratio_mean

# save data for estimation
save(Yraw, Draw, Exraw, time, file=paste0(dirName,setting,"_data.rda"))

#---------------------------------------------------------------------------------------------------------------#
# Estimation of PVAR                                                                                            #
#---------------------------------------------------------------------------------------------------------------#
dirName_est = paste0(dirName,setting,"_mod_",specName,".rda")
if(!file.exists(dirName_est) || compute_mod){
  
  set.seed(571)
  args = list(draws=draws, burnin=burnin, thin=thin, cons=cons, trend=trend, qtrend=qtrend, Ex=Exraw, prmean=0)
  run = ipvar_cmp_ng(Yraw, Draw, plag, args)
  
  # save results
  A_store     = run$A
  alpha_store = run$alpha
  J_store     = run$J
  gamma_store = run$gamma
  sig2_store  = run$sig2
  if(save_est) save(A_store, alpha_store, J_store, gamma_store, sig2_store, file=dirName_est)
}else{
  load(dirName_est)
}

# coefficients
A_post     = apply(A_store,     c(2,3,4),   median) 
J_post     = apply(J_store,     c(2,3,4,5), median)
alph_post  = apply(alpha_store, c(2,3),     median)
gamma_post = apply(gamma_store, c(2,3,4),   median)
sig2_post  = apply(sig2_store,  c(2,3),     median)

rm(dirName_est)
#---------------------------------------------------------------------------------------------------------------#
# Computation of Impulse Response Functions                                                                     #
#---------------------------------------------------------------------------------------------------------------#
dirName_irf = paste0(dirName,setting,"_irf_",specName,".rda")
if(!file.exists(dirName_irf) || compute_irf){
  irf_store   = array(NA_real_, c(thindraws, n, d, nhor, 3), dimnames=list(NULL, vars, ivars[idx_ivars], NULL, c("low","high","diff")))
  irffm_store = array(NA_real_, c(thindraws, n, d, nhor, 3), dimnames=list(NULL, vars, ivars[idx_ivars], NULL, c("low","high","diff")))
  for(dd in 1:d){
    for(irep in 1:thindraws){
      # get index of D0 and DD
      idx0 = grep("^D0.*(?=lag)", dimnames(A_store)[[2]], perl=TRUE)
      idx1 = grep(paste0("^D",dd,".*(?=lag)"), dimnames(A_store)[[2]], perl=TRUE)
      
      g.low = g.high = diag(n)
      J.low = J.high = array(NA_real_, c(n, n, N))
      for(cc in 1:N){
        J.low[,,cc] = J.high[,,cc] = diag(n)
      }
      for(nn in 2:n){
        for(ii in 1:(nn-1)){
          g.low[nn,ii]  = gamma_store[irep,nn,ii,1] + gamma_store[irep,nn,ii,1+dd]*Dbig_vals["low",dd]
          g.high[nn,ii] = gamma_store[irep,nn,ii,1] + gamma_store[irep,nn,ii,1+dd]*Dbig_vals["high",dd]
          for(ddd in seq(d)[-dd]){
            g.low[nn,ii]  = g.low[nn,ii] + gamma_store[irep,nn,ii,1+ddd]*Dbig_vals["med",ddd]
            g.high[nn,ii] = g.high[nn,ii] + gamma_store[irep,nn,ii,1+ddd]*Dbig_vals["med",ddd]
          }
          for(cc in 1:N){
            J.low[nn,ii,cc]  = J_store[irep,nn,ii,1,cc] + J_store[irep,nn,ii,1+dd,cc]*D_vals["low",dd,cc]
            J.high[nn,ii,cc] = J_store[irep,nn,ii,1,cc] + J_store[irep,nn,ii,1+dd,cc]*D_vals["high",dd,cc]
            for(ddd in seq(d)[-dd]){
              J.low[nn,ii,cc]  = J.low[nn,ii,cc] + J_store[irep,nn,ii,1+ddd,cc]*D_vals["med",ddd,cc]
              J.high[nn,ii,cc] = J.high[nn,ii,cc] + J_store[irep,nn,ii,1+ddd,cc]*D_vals["med",ddd,cc]
            }
          } # END-for cc
        } # END-inner-for
      } # END-outer-for
      g.lowinv = try(solve(g.low),silent=TRUE); g.highinv = try(solve(g.high),silent=TRUE)
      J.lowinv = J.highinv = array(NA_real_, c(n, n, N))
      for(cc in 1:N){
        J.lowinv[,,cc]  = solve(J.low[,,cc])
        J.highinv[,,cc] = solve(J.high[,,cc])
      }
      if(is(g.lowinv,"try-error")) g.lowinv = MASS::ginv(g.low)
      if(is(g.highinv,"try-error")) g.highinv = MASS::ginv(g.high)
      
      # construct reduced-form coefficient matrices
      amat.low  = alpha_store[irep,idx0,]%*%t(g.lowinv)  + alpha_store[irep,idx1,]%*%t(g.lowinv)*Dbig_vals["low",dd]
      amat.high = alpha_store[irep,idx0,]%*%t(g.highinv) + alpha_store[irep,idx1,]%*%t(g.highinv)*Dbig_vals["high",dd]
      for(ddd in seq(d)[-dd]){
        amat.low  = amat.low  + alpha_store[irep,grep(paste0("^D",ddd,".*(?=lag)"), dimnames(alpha_store)[[2]], perl=TRUE),]%*%t(g.lowinv)*Dbig_vals["med",ddd]
        amat.high = amat.high + alpha_store[irep,grep(paste0("^D",ddd,".*(?=lag)"), dimnames(alpha_store)[[2]], perl=TRUE),]%*%t(g.highinv)*Dbig_vals["med",ddd]
      }
      
      # construct country-specific covariance matrix
      S.low = S.high = array(NA_real_, c(n, n, N))
      for(cc in 1:N){
        S.low[,,cc]  = J.lowinv[,,cc]  %*% diag(sig2_store[irep,,cc]) %*% t(J.lowinv[,,cc])
        S.high[,,cc] = J.highinv[,,cc] %*% diag(sig2_store[irep,,cc]) %*% t(J.highinv[,,cc])
      }
      S.low  = apply(S.low,  c(1,2), mean)
      S.high = apply(S.high, c(1,2), mean)
      
      # state low
      tmp.low = gen_compMat(amat.low, n, plag)
      Jm.low  = tmp.low$Jm
      Cm.low  = tmp.low$Cm
      
      # state high
      tmp.high = gen_compMat(amat.high, n, plag)
      Jm.high  = tmp.high$Jm
      Cm.high  = tmp.high$Cm
      
      # check eigenvalues
      if((max(abs(Re(eigen(Cm.low)$values))) > 1) || (max(abs(Re(eigen(Cm.high)$values))) > 1)){
        next
      }
      
      # identification
      shock.low = t(chol(S.low))
      diagonal  = diag(diag(shock.low))
      shock.low = solve(diagonal) %*% shock.low # unit initial shock
      
      shock.high = t(chol(S.high))
      diagonal   = diag(diag(shock.high))
      shock.high = solve(diagonal) %*% shock.high # unit initial shock
      
      compMati.low <- compMati.high <- diag(n*plag)
      for(ihor in 1:nhor){
        tmp.low                         = t(Jm.low) %*% compMati.low %*% Jm.low %*% shock.low
        tmp.high                        = t(Jm.high) %*% compMati.high %*% Jm.high %*% shock.high
        compMati.low                    = compMati.low %*% Cm.low
        compMati.high                   = compMati.high %*% Cm.high
        irf_store[irep,,dd,ihor,"low"]  = tmp.low[,shock.idx] * shock.scale
        irf_store[irep,,dd,ihor,"high"] = tmp.high[,shock.idx] * shock.scale
        irf_store[irep,,dd,ihor,"diff"] = (tmp.high-tmp.low)[,shock.idx]
      }
      
      # do this before taking cumulative sums!!!!
      if(comp_fm){
        for(nn in 1:n){
          for(kk in 1:2){ # for low/high
            if(tcode[shock.idx] %in% c(2,5)) denom_rgov = cumsum(irf_store[irep,shock.idx,dd,,kk]) else denom_rgov = irf_store[irep,shock.idx,dd,,kk]
            if(tcode[nn] %in% c(2,5)) tmp_sum = cumsum(irf_store[irep,nn,dd,,kk]) else tmp_sum = irf_store[irep,nn,dd,,kk]
            irffm_store[irep,nn,dd,,kk] = tmp_sum / denom_rgov
          }
          irffm_store[irep,nn,dd,,"diff"] = irffm_store[irep,nn,dd,,"high"] - irffm_store[irep,nn,dd,,"low"]
        }
      }
      
      # cumulative sum
      for(nn in 1:n){
        if(cumul[nn] == 1)
          irf_store[irep,nn,dd,,] = t(apply(irf_store[irep,nn,dd,,],1,cumsum))
      }
      
      if(irep%%50==0) cat(paste0("Round: ",irep,"/",thindraws," of interaction variable ", dd, "/", d,".\n"))
      rm(tmp.low, tmp.high, amat.low, amat.high, g.high, g.low, g.highinv, g.lowinv, J.high, J.low, J.highinv, J.lowinv,
         Jm.low, Jm.high, S.high, S.low, Cm.low, Cm.high, compMati.low, compMati.high, shock.low, shock.high, diagonal, tmp_sum)
    } # END-thindraws-for-loop
  } # END-dd
  
  # compute posterior quantities
  irf_post = apply(irf_store, c(2,3,4,5), quantile, emp_percs, na.rm=TRUE)
  if(comp_fm) irffm_post = apply(irffm_store, c(2,3,4,5), quantile, emp_percs, na.rm=TRUE) else irffm_post = NULL
  if(save_est) save(irf_post, irffm_post, file=dirName_irf)
  rm(irf_store, irffm_store)
}else{
  load(dirName_irf)
}
rm(dirName_irf)

#---------------------------------------------------------------------------------------------------------------#
# Computation of Impulse Response Functions Over Grid                                                           #
#---------------------------------------------------------------------------------------------------------------#
dirName_irfgrid = paste0(dirName,setting,"_irfgrid_",specName,".rda")
if((!file.exists(dirName_irfgrid) || compute_irf) & compute_irf_grid){
  irfgrid_store   = array(NA_real_, c(thindraws, n, d, nhor, grid_size), dimnames=list(NULL, vars, ivars[idx_ivars], NULL, NULL))
  irffmgrid_store = array(NA_real_, c(thindraws, n, d, nhor, grid_size), dimnames=list(NULL, vars, ivars[idx_ivars], NULL, NULL))
  vargrid_store   = array(NA_real_, c(thindraws, n, d, grid_size),       dimnames=list(NULL, vars, ivars[idx_ivars], NULL))
  sdgrid_store    = array(NA_real_, c(thindraws, n, d, grid_size),       dimnames=list(NULL, vars, ivars[idx_ivars], NULL))
  fevdgrid_store  = array(NA_real_, c(thindraws, n, d, nhor, grid_size), dimnames=list(NULL, vars, ivars[idx_ivars], NULL, NULL))
  for(gg in 1:grid_size){
    for(dd in 1:d){
      for(irep in 1:thindraws){
        
        # get index of D0 and DD
        idx0 = grep("^D0.*(?=lag)", dimnames(A_store)[[2]], perl=TRUE)
        idx1 = grep(paste0("^D",dd,".*(?=lag)"), dimnames(A_store)[[2]], perl=TRUE)
        
        g.gg = diag(n)
        J.gg = array(NA_real_, c(n, n, N))
        for(cc in 1:N){
          J.gg[,,cc] = diag(n)
        }
        for(nn in 2:n){
          for(ii in 1:(nn-1)){
            g.gg[nn,ii]  = gamma_store[irep,nn,ii,1] + gamma_store[irep,nn,ii,1+dd]*D_grid[gg,dd,cc]
            for(ddd in seq(d)[-dd]){
              g.gg[nn,ii]  = g.gg[nn,ii] + gamma_store[irep,nn,ii,1+ddd]*Dbig_vals["med",ddd]
            }
            for(cc in 1:N){
              J.gg[nn,ii,cc]  = J_store[irep,nn,ii,1,cc] + J_store[irep,nn,ii,1+dd,cc]*D_grid[gg,dd,cc]
              for(ddd in seq(d)[-dd]){
                J.gg[nn,ii,cc]  = J.gg[nn,ii,cc] + J_store[irep,nn,ii,1+ddd,cc]*D_vals["med",ddd,cc]
              }
            } # END-for cc
          } # END-inner-for
        } # END-outer-for
        g.gginv = solve(g.gg)
        J.gginv = array(NA_real_, c(n, n, N))
        for(cc in 1:N){
          J.gginv[,,cc]  = solve(J.gg[,,cc])
        }
        
        # construct reduced-form coefficient matrices
        Amat.gg = alpha_store[irep,idx0,]%*%t(g.gginv) + alpha_store[irep,idx1,]%*%t(g.gginv)*Dbig_grid[gg,dd]
        for(ddd in seq(d)[-dd]){
          Amat.gg = Amat.gg + alpha_store[irep,grep(paste0("^D",ddd,".*(?=lag)"), dimnames(alpha_store)[[2]], perl=TRUE),]%*%t(g.gginv)*Dbig_vals["med",ddd]
        }
        
        # construct country-specific covariance matrix
        S.gg = array(NA_real_, c(n, n, N))
        for(cc in 1:N){
          S.gg[,,cc]  = J.gginv[,,cc]  %*% diag(sig2_store[irep,,cc]) %*% t(J.gginv[,,cc])
        }
        S.gg  = apply(S.gg,  c(1,2), mean)
        
        # state low
        tmp.gg = gen_compMat(Amat.gg, n, plag)
        Jm.gg  = tmp.gg$Jm
        Cm.gg  = tmp.gg$Cm
        
        # check eigenvalues
        if(max(abs(Re(eigen(Cm.gg)$values))) > 1){
          next
        }
        
        # create dynamic multipliers
        PHI.gg  = array(NA_real_ , c(n, n, nhor)); dimnames(PHI.gg)[[1]] <- dimnames(PHI.gg)[[2]] <- vars
        Cmat.gg = diag(n*plag)
        for(ihor in 1:nhor){
          PHI.gg[,,ihor] = t(Jm.gg) %*% Cmat.gg %*% Jm.gg
          Cmat.gg        = Cmat.gg %*% Cm.gg
        }
        
        # identification
        shock.gg = t(chol(S.gg))
        diagonal = diag(diag(shock.gg))
        shock.gg = solve(diagonal) %*% shock.gg # unit initial shock
        
        for(ihor in 1:nhor){
          irfgrid_store[irep,,dd,ihor,gg] = (PHI.gg[,,ihor] %*% shock.gg)[,shock.idx]
        }
        
        # do this before taking cumulative sums!!!!
        if(comp_fm){
          for(nn in 1:n){
            if(tcode[nn] %in% c(2,5)) tmp_sum = cumsum(irfgrid_store[irep,nn,dd,,gg]) else tmp_sum = irfgrid_store[irep,nn,dd,,gg]
            irffmgrid_store[irep,nn,dd,,gg] = tmp_sum / cumsum(irfgrid_store[irep,shock.idx,dd,,gg])
          }
        }
        
        # cumulative sum
        for(nn in 1:n){
          if(cumul[nn] == 1)
            irfgrid_store[irep,nn,dd,,gg] = cumsum(irfgrid_store[irep,nn,dd,,gg])
        }
        
        #---------------------------------------------------
        # computing variance of y_t
        Am.gg                      = Cm.gg %x% Cm.gg
        Qm.gg                      = matrix(0, n*plag, n*plag)
        Qm.gg[1:n,1:nn]            = S.gg
        Sm.gg                      = matrix(solve(diag((n*plag)^2)-Am.gg)%*%as.vector(Qm.gg), n*plag, n*plag)
        vargrid_store[irep,,dd,gg] = diag(Sm.gg[1:n,1:n])
        sdgrid_store[irep,,dd,gg]  = sqrt(diag(Sm.gg[1:n,1:n]))
        
        #---------------------------------------------------
        # compute forecast error variance decomposition
        fevdres = array(NA_real_, dim=c(n, nhor), dimnames=list(vars, 1:nhor))
        R       = diag(n)
        gamma   = t(chol(S.gg))[,shock.idx,drop=FALSE]
        for(nn in 1:n){
          eslct = matrix(0,n,1); rownames(eslct) = vars
          eslct[vars[nn],1] = 1
          
          num = rep(0, nhor+1)
          den = rep(0, nhor+1)
          
          ihor = 1
          while(ihor<=nhor){
            num[ihor]        = num[ihor] + t((t(eslct)%*%R%*%PHI.gg[,,ihor]%*%gamma)^2)
            den[ihor]        = den[ihor] + (t(eslct)%*%R%*%PHI.gg[,,ihor]%*%S.gg%*%t(R%*%PHI.gg[,,ihor])%*%eslct)
            fevdres[nn,ihor] = num[ihor]/den[ihor]
            ihor      = ihor+1
            num[ihor] = num[ihor-1]
            den[ihor] = den[ihor-1]
          }
        }
        fevdgrid_store[irep,,dd,,gg] = fevdres
        
        if(irep%%50==0) cat(paste0("Round: ",irep,"/",thindraws," of interaction variable ", dd, "/", d," of grid element ", gg,"/",grid_size,".\n"))
        rm(tmp.gg, Amat.gg, g.gg, g.gginv, J.gg, J.gginv, Jm.gg, S.gg, Cm.gg, Cmat.gg, PHI.gg, shock.gg, Am.gg, Qm.gg, Sm.gg, fevdres, R, gamma, num, den, eslct)
      } # END-thindraws-for-loop
    } # END-dd
  } # END-gridsize
  
  # compute posterior quantities
  irfgrid_post  = apply(irfgrid_store,  c(2,3,4,5), quantile, emp_percs, na.rm=TRUE)
  vargrid_post  = apply(vargrid_store,  c(2,3,4),   quantile, emp_percs, na.rm=TRUE)
  sdgrid_post   = apply(sdgrid_store,   c(2,3,4),   quantile, emp_percs, na.rm=TRUE)
  fevdgrid_post = apply(fevdgrid_store, c(2,3,4,5), quantile, emp_percs, na.rm=TRUE)
  if(comp_fm) irffmgrid_post = apply(irffmgrid_store, c(2,3,4,5), quantile, emp_percs, na.rm=TRUE) else irffm_post = NULL
  if(save_est) save(irfgrid_post, irffmgrid_post, sdgrid_post, sdgrid_store, vargrid_post, fevdgrid_post, file=dirName_irfgrid)
  rm(irfgrid_store, irffmgrid_store, vargrid_store, fevdgrid_store)
}else{
  if(file.exists(dirName_irfgrid)) load(dirName_irfgrid)
}
rm(dirName_irfgrid)
#---------------------------------------------------------------------------------------------------------------#
# Variance Decomposition                                                                                        #
#---------------------------------------------------------------------------------------------------------------#
dirName_vardecompgrid = paste0(dirName,setting,"_vardecompgrid_",specName,".rda")
if((!file.exists(dirName_vardecompgrid) || compute_irf) & compute_var_grid){
  STEsd_store  = array(NA_real_, c(n, d, grid_size, length(eval_grid), thindraws), dimnames=list(vars, ivars[idx_ivars], NULL, NULL, NULL))
  SSEsd_store  = array(NA_real_, c(n, d, grid_size, length(eval_grid), thindraws), dimnames=list(vars, ivars[idx_ivars], NULL, NULL, NULL))
  for(irep in 1:thindraws){
    for(dd in 1:d){
      
      # get index of D0 and DD
      idx0 = grep("^D0.*(?=lag)", dimnames(A_store)[[2]], perl=TRUE)
      idx1 = grep(paste0("^D",dd,".*(?=lag)"), dimnames(A_store)[[2]], perl=TRUE)
      
      for(ee in 1:length(eval_grid)){
        g.eval = diag(n)
        J.eval = array(NA_real_, c(n, n, N))
        for(cc in 1:N){
          J.eval[,,cc] = diag(n)
        }
        
        for(nn in 2:n){
          for(ii in 1:(nn-1)){
            g.eval[nn,ii]  = gamma_store[irep,nn,ii,1] + gamma_store[irep,nn,ii,1+dd]*Dbig_vals[eval_grid[ee],dd]
            for(ddd in seq(d)[-dd]){
              g.eval[nn,ii]  = g.eval[nn,ii] + gamma_store[irep,nn,ii,1+ddd]*Dbig_vals["med",ddd]
            }
            for(cc in 1:N){
              J.eval[nn,ii,cc]  = J_store[irep,nn,ii,1,cc] + J_store[irep,nn,ii,1+dd,cc]*D_vals[eval_grid[ee],dd,cc]
              for(ddd in seq(d)[-dd]){
                J.eval[nn,ii,cc]  = J.eval[nn,ii,cc] + J_store[irep,nn,ii,1+ddd,cc]*D_vals["med",ddd,cc]
              }
            } # END-for cc
          } # END-inner-for
        } # END-outer-for
        g.evalinv = solve(g.eval)
        J.evalinv = array(NA_real_, c(n, n, N))
        for(cc in 1:N){
          J.evalinv[,,cc]  = solve(J.eval[,,cc])
        }
        
        # construct reduced-form coefficient matrices
        Amat.eval = alpha_store[irep,idx0,]%*%t(g.evalinv) + alpha_store[irep,idx1,]%*%t(g.evalinv)*Dbig_vals[eval_grid[ee],dd]
        for(ddd in seq(d)[-dd]){
          Amat.eval = Amat.eval + alpha_store[irep,grep(paste0("^D",ddd,".*(?=lag)"), dimnames(alpha_store)[[2]], perl=TRUE),]%*%t(g.evalinv)*Dbig_vals["med",ddd]
        }
        
        # construct country-specific covariance matrix
        S.eval = array(NA_real_, c(n, n, N))
        for(cc in 1:N){
          S.eval[,,cc]  = J.evalinv[,,cc]  %*% diag(sig2_store[irep,,cc]) %*% t(J.evalinv[,,cc])
        }
        S.eval  = apply(S.eval,  c(1,2), mean)
        
        # state eval
        temp.eval <- gen_compMat(Amat.eval, n, plag)
        Jm.eval   <- temp.eval$Jm
        Cm.eval   <- temp.eval$Cm
        
        # check eigenvalues
        if(max(abs(Re(eigen(Cm.eval)$values))) > 1){
          next
        }
        
        for(gg in 1:grid_size){
          g.gg = diag(n)
          J.gg = array(NA_real_, c(n, n, N))
          for(cc in 1:N){
            J.gg[,,cc] = diag(n)
          }
          for(nn in 2:n){
            for(ii in 1:(nn-1)){
              g.gg[nn,ii]  = gamma_store[irep,nn,ii,1] + gamma_store[irep,nn,ii,1+dd]*Dbig_grid[gg,dd]
              for(ddd in seq(d)[-dd]){
                g.gg[nn,ii]  = g.gg[nn,ii] + gamma_store[irep,nn,ii,1+ddd]*Dbig_vals["med",ddd]
              }
              for(cc in 1:N){
                J.gg[nn,ii,cc]  = J_store[irep,nn,ii,1,cc] + J_store[irep,nn,ii,1+dd,cc]*D_grid[gg,dd,cc]
                for(ddd in seq(d)[-dd]){
                  J.gg[nn,ii,cc]  = J.gg[nn,ii,cc] + J_store[irep,nn,ii,1+ddd,cc]*D_vals["med",ddd,cc]
                }
              } # END-for cc
            } # END-inner-for
          } # END-outer-for
          g.gginv = solve(g.gg)
          J.gginv = array(NA_real_, c(n, n, N))
          for(cc in 1:N){
            J.gginv[,,cc]  = solve(J.gg[,,cc])
          }
          
          # construct reduced-form coefficient matrices
          Amat.gg = alpha_store[irep,idx0,]%*%t(g.gginv) + alpha_store[irep,idx1,]%*%t(g.gginv)*Dbig_grid[gg,dd]
          for(ddd in seq(d)[-dd]){
            Amat.gg = Amat.gg + alpha_store[irep,grep(paste0("^D",ddd,".*(?=lag)"), dimnames(alpha_store)[[2]], perl=TRUE),]%*%t(g.gginv)*Dbig_vals["med",ddd]
          }
          
          # construct country-specific covariance matrix
          S.gg = array(NA_real_, c(n, n, N))
          for(cc in 1:N){
            S.gg[,,cc]  = J.gginv[,,cc]  %*% diag(sig2_store[irep,,cc]) %*% t(J.gginv[,,cc])
          }
          S.gg  = apply(S.gg,  c(1,2), mean)
          
          # state gg
          temp.gg <- gen_compMat(Amat.gg, n, plag)
          Jm.gg   <- temp.gg$Jm
          Cm.gg   <- temp.gg$Cm
          
          # check eigenvalues
          if(max(abs(Re(eigen(Cm.gg)$values))) > 1){
            next
          }
          
          #---------------------------------------------------
          # shock transmission effect - keep shock constant
          Am.gg            = Cm.gg %x% Cm.gg
          Qm.eval          = matrix(0,n*plag,n*plag)
          Qm.eval[1:n,1:n] = S.eval
          STEvar = matrix(solve(diag((n*plag)^2)-Am.gg)%*%as.vector(Qm.eval), n*plag, n*plag)
          STEsd_store[,dd,gg,ee,irep]  = sqrt(diag(STEvar[1:n,1:n]))
          
          #---------------------------------------------------
          # shock size effect - keep transmission constant
          Am.eval        = Cm.eval %x% Cm.eval
          Qm.gg          = matrix(0,n*plag,n*plag)
          Qm.gg[1:n,1:n] = S.gg
          SSEvar = matrix(solve(diag((n*plag)^2)-Am.eval)%*%as.vector(Qm.gg), n*plag, n*plag)
          SSEsd_store[,dd,gg,ee,irep]  = sqrt(diag(SSEvar[1:n,1:n]))
          
          if(gg %% grid_size == 0) cat(paste0("Round: ", irep," / ",thindraws,".\n"))
        } # END-grid-size
      } # END-eval
    } # END-interaction
  } # END-thindraws
  
  # save SSEvar_store SSEsd_store STEvar_store STEsd_store
  if(save_est) save(STEsd_store, SSEsd_store, file=dirName_vardecompgrid)
}else{
  if(file.exists(dirName_vardecompgrid)) load(dirName_vardecompgrid)
}
rm(dirName_vardecompgrid)
