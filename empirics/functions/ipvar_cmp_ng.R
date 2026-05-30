ipvar_cmp_ng <- function(Yraw, Draw, plag = 1, args = NULL){
  #----------------------------------------INPUTS----------------------------------------------------#
  # prepare arguments
  draws = burnin = 5000; SV = FALSE; cons=TRUE; trend=FALSE; qtrend=FALSE; thin=1; Ex=NULL; prmean=NULL; save.prior=FALSE
  if(!is.null(args)){
    for(aa in c("draws","burnin","SV","cons","trend","qtrend","thin","Ex","prmean","save.prior")){
      if(aa%in%names(args)) assign(aa, args[[aa]])
    }
  }
  arglist=list(Yraw=Yraw, plag=plag, draws=draws, burnin=burnin, SV=SV, cons=cons, trend=trend, qtrend=qtrend,
               thin=thin, Ex=Ex, prmean=prmean, save.prior=save.prior)
  
  #----------------------------------------PACKAGES--------------------------------------------------#
  require(stochvol,quietly=TRUE)
  require(GIGrvg, quietly=TRUE)
  require(Rcpp, quietly=TRUE)
  require(MASS, quietly=TRUE)
  require(mvtnorm, quietly=TRUE)
  require(stringr, quietly=TRUE)
  sourceCpp("./empirics/functions/aux.cpp")
  
  if(!is.null(prmean)){
    if(length(prmean)==1){
      prmean=rep(prmean,n)
    }
    if(length(prmean)!=n){
      stop("Please provide argument 'prmean' with correct length (either 1 or number of endog. variables)!")
    }
  }
  
  #-------------------------------------------START--------------------------------------------------#
  # get names
  varNames = colnames(Yraw[[1]])
  if(is.null(varNames)) varNames = paste0("var.",seq(1,ncol(Yraw[[1]])))
  cN   = names(Yraw)
  if(is.null(cN)) cN = paste0("cN.",seq(1,length(Yraw)))
  dNames   = colnames(Draw[[1]])
  if(is.null(dNames)) dNames = paste0("D.",seq(1,ncol(Draw[[1]])))
  
  # parameters
  N    = length(cN)
  n    = length(varNames)
  Traw = unlist(lapply(Yraw,nrow))
  Ki   = ncol(Draw[[1]])
  K    = n*plag
  det  = ifelse(cons,1,0) + ifelse(trend,1,0) + ifelse(qtrend,1,0)
  Ki1  = Ki+1
  
  # check whether data has same colnames
  if(!all(unlist(lapply(Yraw,function(y)all(colnames(y)%in%varNames))))){
    stop("Not same variables in all countries, check!")
  }
  
  # varNameslags
  varNameslags = NULL
  for(pp in 1:plag) varNameslags = c(varNameslags,paste0(varNames,".lag",pp))
  varNameslags = paste0(rep(paste0("D",seq(0,Ki),"."),each=K),rep(varNameslags,Ki1))
  
  # exogenous variables
  texo <- FALSE; Mex <- 0; Exraw <- lapply(cN, function(cc) NULL); names(Exraw) = cN
  if(!is.null(Ex)){
    Exraw <- Ex
    texo <- TRUE
    if(is.matrix(Exraw)){
      if(!all(dim(Exraw)==dim(Yraw)))
        stop("Please provide Ex with same dimensions as Yraw!")
      
      Exraw = lapply(cN, function(cc){
        tmp = Exraw[,grepl(cc, colnames(Exraw))]
        colnames(tmp) = str_remove(colnames(tmp), paste0(cc,"\\."))
        return(tmp)
      })
      names(Exraw) = cN
      
      exNames = paste0("Ex.",colnames(Exraw[[1]]))
    }else if(is.list(Exraw)){
      if(!all(names(Exraw)%in%cN))
        stop("Please provide Ex as list with same names as Yraw!")
      if(!all(unlist(lapply(Exraw,nrow))%in%unlist(lapply(Yraw,nrow))))
        stop("Please provide Ex as list with same sample length as Yraw!")
      
      exNames = paste0("Ex.",colnames(Exraw[[1]]))
    }
    if(is.null(exNames)) exNames <- paste0("Ex.",seq(1,ncol(Exraw[[1]])))
    Mex = length(exNames)
    varNameslags <- c(varNameslags, exNames)
  }
  
  # create data lists
  Ylag = lapply(Yraw, function(y) mlag(y, plag))
  Xraw = lapply(1:N, function(cc){
    Drawbig  = matrix(NA_real_, Traw[cc], K*Ki)
    Xtempbig = matrix(NA_real_, Traw[cc], K*Ki)
    for(kk in 1:Ki){
      Drawbig[,((kk-1)*K+1):(kk*K)]  = Draw[[cc]][,kk]
      Xtempbig[,((kk-1)*K+1):(kk*K)] = Ylag[[cc]]
    }
    DYlag = matrixcalc::hadamard.prod(Xtempbig,Drawbig)
    tmp   = cbind(Ylag[[cc]],DYlag)
    if(texo) tmp <- cbind(tmp, Ex[[cc]])
    colnames(tmp) <- varNameslags
    return(tmp)
  })
  names(Xraw) <- cN
  
  DYraw = lapply(1:N, function(cc){
    temp = matrix(NA,Traw[cc],Ki1*n)
    for(nn in 1:n){
      idx = seq((nn-1)*Ki1+1,nn*Ki1)
      temp[,idx] = cbind(Yraw[[cc]][,nn],
                         matrixcalc::hadamard.prod(matrix(Yraw[[cc]][,nn],Traw[cc],Ki),Draw[[cc]]))
    }
    colnames(temp) = paste0(rep(c("",paste0("D",seq(Ki),".")),n),rep(varNames,each=Ki1))
    return(temp)
  })
  DYmat = matrix(seq(1,n*Ki1),Ki1,n)
  
  X    = lapply(Xraw,function(x)x[(plag+1):nrow(x),,drop=FALSE])
  Y    = lapply(Yraw,function(y)y[(plag+1):nrow(y),,drop=FALSE])
  D    = lapply(Draw,function(d)d[(plag+1):nrow(d),,drop=FALSE])
  DY   = lapply(DYraw,function(dy)dy[(plag+1):nrow(dy),,drop=FALSE])
  bigT = unlist(lapply(Y,nrow))
  
  # add deterministics per country
  if(cons){
    varNameslags = c(varNameslags, "cons")
    for(cc in 1:N){
      X[[cc]] = cbind(X[[cc]], 1)
      colnames(X[[cc]]) = varNameslags
    }
  }
  if(trend){
    varNameslags = c(varNameslags, "trend")
    for(cc in 1:N){
      X[[cc]] = cbind(X[[cc]], seq(1,bigT[cc]))
      colnames(X[[cc]]) = varNameslags
    }
  }
  if(qtrend){
    varNameslags = c(varNameslags, "qtrend")
    for(cc in 1:N){
      X[[cc]] = cbind(X[[cc]], seq(1,bigT[cc])^2)
      colnames(X[[cc]]) = varNameslags
    }
  }
  
  # dimensions
  k    = length(varNameslags)
  nN   = n*N
  v    = (n*(n-1))/2
  #---------------------------------------------------------------------------------------------------------
  # OLS Quantitites
  #---------------------------------------------------------------------------------------------------------
  XtXinv <- lapply(1:N, function(cc){
    temp <- try(solve(crossprod(X[[cc]])),silent=TRUE)
    if(is(temp,"try-error")) temp <- MASS::ginv(crossprod(X[[cc]]))
    return(temp)
  })
  A_OLS = array(NA_real_,  c(k, n, N),      dimnames=list(varNameslags, varNames, cN))
  J_OLS = array(0,         c(n, n, Ki1, N), dimnames=list(varNames, varNames, c("NoI",dNames), cN))
  V_OLS = array(NA_real_,  c(k, n, N),      dimnames=list(varNameslags, varNames, cN))
  Z_OLS = array(0,         c(n, n, Ki1, N), dimnames=list(varNames, varNames, c("NoI",dNames), cN))
  S_OLS = matrix(NA_real_, n, N,            dimnames=list(varNames, cN))
  for(cc in 1:N) for(kk in 1:Ki1) J_OLS[,,kk,cc] <- diag(n)
  for(cc in 1:N) for(Kk in 1:Ki1) Z_OLS[,,kk,cc] <- diag(n)
  E_OLS = vector(mode = "list", length=N)
  for(cc in 1:N){
    Y.c  = as.matrix(Y[[cc]])
    X.c  = as.matrix(X[[cc]])
    DY.c = as.matrix(DY[[cc]])
    X1 = X.c
    E.c = matrix(NA_real_, bigT[cc], n)
    S.c = rep(NA_real_, n)
    for(nn in 1:n){
      if(nn>1) X1 = cbind(DY.c[,c(DYmat[,1:(nn-1)])],X.c)
      XtX     = crossprod(X1)
      XtXinv1 = try(chol2inv(chol(XtX)), silent=TRUE)
      if(is(XtXinv1,"try-error")) XtXinv1 = try(solve(XtX), silent=TRUE)
      if(is(XtXinv1,"try-error")) XtXinv1 = MASS::ginv(XtX)
      temp = XtXinv1%*%t(X1)%*%Y.c[,nn]
      A_OLS[,nn,cc] = temp[((nn-1)*Ki1+1):nrow(temp),]
      if(nn>1) for(kk in 1:Ki1) J_OLS[nn,1:(nn-1),kk,cc] = -temp[DYmat[kk,1:(nn-1)],] # alternativ: seq(kk,(mm-1)*Ki1,by=Ki1)
      E.c[,nn] = Y.c[,nn] - X1%*%temp
      S.c[nn] = crossprod(E.c[,nn])/(bigT[cc]-ncol(X1))
      temp = diag(XtXinv1*S.c[nn])
      V_OLS[,nn,cc] = temp[((nn-1)*Ki1+1):length(temp)]
      if(nn>1) for(kk in 1:Ki1) Z_OLS[nn,1:(nn-1),kk,cc] = temp[DYmat[kk,1:(nn-1)]]
    }
    E_OLS[[cc]] = E.c
    S_OLS[,cc] = S.c
  }
  #---------------------------------------------------------------------------------------------------------
  # Initial Values
  #---------------------------------------------------------------------------------------------------------
  A_draw    = A_OLS
  J_draw    = J_OLS
  sig2_draw = S_OLS
  Em_str    = E_OLS
  
  #---------------------------------------------------------------------------------------------------------
  # PRIORS
  #---------------------------------------------------------------------------------------------------------
  # 1st stage prior
  alpha_draw = array(0, c(k, n),         dimnames=list(varNameslags, varNames))
  ALPHA_draw = array(100^2, c(k, n, N),  dimnames=list(varNameslags, varNames, cN))
  gamma_draw = array(0, c(n, n, Ki1),    dimnames=list(varNames, varNames, c("NoI", dNames)))
  GAMMA_draw = array(0, c(n, n, Ki1, N), dimnames=list(varNames, varNames, c("NoI",dNames), cN))
  for(kk in 1:Ki1){
    gamma_draw[,,kk] <- diag(n)
    GAMMA_tmp = matrix(100^2,n,n); diag(GAMMA_tmp) = 0; GAMMA_tmp[upper.tri(GAMMA_tmp)] = 0
    for(cc in 1:N) GAMMA_draw[,,kk,cc] = GAMMA_tmp
  }
  
  # NG
  d_lambda   = 0.01                                       # hyperparameter global
  e_lambda   = 0.01                                       # hyperparamater global
  b_tau      = 1                                          # hyperparameter MH step tau ~ G(b_tau,b_tau*nu_tau) => corresponds to Exp(1/nu_tau) iff b_tau=1
  nu_tau     = 1                                          # hyperparameter MH step
  tau_start  = 1
  phi_start  = 1
  sample_tau = TRUE
  sample_phi = TRUE
  
  # 1st stage A_draw / J_draw
  lambda2_draw = array(0.01,      c(plag+1,Ki1,N), dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames), cN))
  tau_draw     = array(tau_start, c(plag+1,Ki1,N), dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames), cN))
  tau_tuning   = array(.43,       c(plag+1,Ki1,N), dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames), cN))
  tau_accept   = array(0,         c(plag+1,Ki1,N), dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames), cN))
  
  # 2nd stage alpha_draw / gamma_draw
  if(is.null(prmean)) prmean = 1  # prior mean
  a_prior       = matrix(0,k,n)
  diag(a_prior) = prmean
  A_prior       = matrix(100^2,k,n) # prior variances
  
  g_prior = array(0, c(n,n,Ki1))
  G_prior = array(0, c(n,n,Ki1)) # prior variances
  G_tmp  = matrix(100,n,n); diag(G_tmp) = 0; G_tmp[upper.tri(G_tmp)] = 0
  for(kk in 1:Ki1) G_prior[,,kk] = G_tmp
  
  # NG
  delta2_draw = matrix(0.01,      plag+1, Ki1, dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames)))
  phi_draw    = matrix(phi_start, plag+1, Ki1, dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames)))
  phi_tuning  = matrix(.43,       plag+1, Ki1, dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames)))
  phi_accept  = matrix(0,         plag+1, Ki1, dimnames=list(c(paste0("lag.",seq(1,plag)),"cov"), c("NoI",dNames)))
  
  # variance-covariance matrix
  c0 = 0.01
  d0 = 0.01
  #--------------------------Sampler Stuff---------------------------------------------#
  ntot  = burnin+draws
  
  # thinning
  count      = 0
  thindraws  = draws/thin
  thin.draws = seq(burnin+1,ntot,by=thin)
  arglist    = c(arglist, thindraws=thindraws)
  #--------------------------Storages--------------------------------------------------#
  A_store       = array(NA_real_, c(thindraws,k,n,N),     dimnames=list(NULL,varNameslags,varNames,cN))
  J_store       = array(NA_real_, c(thindraws,n,n,Ki1,N), dimnames=list(NULL,varNames,varNames,NULL,cN))
  alpha_store   = array(NA_real_, c(thindraws,k,n),       dimnames=list(NULL,varNameslags,varNames))
  gamma_store   = array(NA_real_, c(thindraws,n,n,Ki1),   dimnames=list(NULL,varNames,varNames,NULL))
  sig2_store    = array(NA_real_, c(thindraws,n,N),       dimnames=list(NULL,varNames,cN))
  if(save.prior){
    # NG 1st stage
    ALPHA_store   = array(NA_real_, c(thindraws,k,n,N),        dimnames=list(NULL,varNameslags,varNames,cN))
    GAMMA_store   = array(NA_real_, c(thindraws,n,n,Ki1,N),    dimnames=list(NULL,varNames,varNames,c("NoI",dNames),cN))
    lambda2_store = array(NA_real_, c(thindraws,plag+1,Ki1,N), dimnames=list(NULL,c(paste0("lag.",seq(1,plag)),"cov"),c("NoI",dNames),cN))
    tau_store     = array(NA_real_, c(thindraws,plag+1,Ki1,N), dimnames=list(NULL,c(paste0("lag.",seq(1,plag)),"cov"),c("NoI",dNames),cN))
    # NG 2nd stage
    Aprior_store  = array(NA_real_, c(thindraws,k,n),        dimnames=list(NULL,varNameslags,varNames))
    Gprior_store  = array(NA_real_, c(thindraws,n,n,Ki1),    dimnames=list(NULL,varNames,varNames,c("NoI",dNames)))
    delta2_store  = array(NA_real_, c(thindraws,plag+1,Ki1), dimnames=list(NULL,c(paste0("lag.",seq(1,plag)),"cov"),c("NoI",dNames)))
    phi_store     = array(NA_real_, c(thindraws,plag+1,Ki1), dimnames=list(NULL,c(paste0("lag.",seq(1,plag)),"cov"),c("NoI",dNames)))
  }else{
    ALPHA_store <- Aprior_store <- lambda2_store <- tau_store <- GAMMA_store <- Gprior_store <- delta2_store <- phi_store <- NULL
  }
  
  #--------------------------MCMC Loop--------------------------------------------------#
  for(irep in 1:ntot){
    #----------------------------------------------------------------------------
    # Step 1: Sample coefficients
    for(cc in 1:N){
      Y.c  = Y[[cc]]
      X.c  = X[[cc]]
      DY.c = DY[[cc]]
      S.c  = sig2_draw[,cc]
      E.c  = Em_str[[cc]]
      
      for(nn in 1:n){
        Y.i = Y.c[,nn] / sqrt(S.c[nn])
        if(nn>1) X1 = cbind(DY.c[,c(DYmat[,1:(nn-1)])],X.c) else X1 = X.c
        X.i = X1 / sqrt(S.c[nn])
        
        aprior = alpha_draw[,nn,drop=FALSE]
        Vprior = as.matrix(ALPHA_draw[,nn,cc])
        if(nn>1){
          for(ll in (nn-1):1){
            aprior = rbind(matrix(gamma_draw[nn,ll,],Ki1,1),aprior)
            Vprior = rbind(matrix(GAMMA_draw[nn,ll,,cc],Ki1,1),Vprior)
          }
        }
        Vpriorinv = diag(1/c(Vprior))
        
        V_post = try(chol2inv(chol(crossprod(X.i)+Vpriorinv)),silent=TRUE)
        if(is(V_post,"try-error")) V_post = try(solve(crossprod(X.i)+Vpriorinv),silent=TRUE)
        if(is(V_post,"try-error")) V_post = MASS::ginv(crossprod(X.i)+Vpriorinv)
        a_post = V_post%*%(crossprod(X.i,Y.i) + Vpriorinv %*% aprior)
        
        A_draw.i = try(a_post+t(chol(V_post))%*%rnorm(ncol(X.i)),silent=TRUE)
        if(is(A_draw.i,"try-error")) A_draw.i = matrix(MASS::mvrnorm(1,a_post,V_post),ncol(X.i),1)
        A_draw[,nn,cc] = A_draw.i[((nn-1)*Ki1+1):nrow(A_draw.i),]
        if(nn>1) for(kk in 1:Ki1) J_draw[nn,1:(nn-1),kk,cc] = -A_draw.i[DYmat[kk,1:(nn-1)],]
        E.c[,nn] = Y.c[,nn]-X1%*%A_draw.i
      }
      Em_str[[cc]] = E.c
    }
    #----------------------------------------------------------------------------
    # Step 2: Sample shrinkage prior - 1st stage
    for(cc in 1:N){
      for(kk in 1:Ki1){
        # covariances
        V.cov = GAMMA_draw[,,kk,cc]
        V.cov = V.cov[lower.tri(V.cov)]
        # Global shrinkage parameter
        lambda2_draw["cov",kk,cc] = rgamma(n     = 1,
                                           shape = d_lambda + tau_draw["cov",kk,cc]*v,
                                           rate  = e_lambda + 0.5*tau_draw["cov",kk,cc]*sum(V.cov))
        # Local shrinkage parameter
        for(nn in 2:n){
          for(ii in 1:(nn-1)){
            temp = do_rgig1(lambda = tau_draw["cov",kk,cc]-0.5, 
                            chi    = (J_draw[nn,ii,kk,cc] - gamma_draw[nn,ii,kk])^2,
                            psi    = tau_draw["cov",kk,cc]*lambda2_draw["cov",kk,cc])
            # offsetting
            GAMMA_draw[nn,ii,kk,cc] = ifelse(temp<1e-8,1e-8,ifelse(temp>1e+8,1e+8,temp))
          }
        }
        # Hierarchical Prior
        if(sample_tau){
          before <- tau_draw["cov",kk,cc]
          tau_draw["cov",kk,cc] = MH_step(tau_draw["cov",kk,cc], tau_tuning["cov",kk,cc], v, lambda2_draw["cov",kk,cc], 
                                          as.vector(V.cov), b_tau, nu_tau, d_lambda, e_lambda)
          if(before!=tau_draw["cov",kk,cc]){
            tau_accept["cov",kk,cc] <- tau_accept["cov",kk,cc] + 1
          }
          # scale MH proposal during the first 50% of the burn-in stage
          if(irep<(0.5*burnin)){
            if ((tau_accept["cov",kk,cc]/irep)>0.3){tau_tuning["cov",kk,cc] <- 1.01*tau_tuning["cov",kk,cc]}
            if ((tau_accept["cov",kk,cc]/irep)<0.15){tau_tuning["cov",kk,cc] <- 0.99*tau_tuning["cov",kk,cc]}
          }
        }
        
        # autoregressive coefficients
        for(pp in 1:plag){
          slct.i = grep(paste0("(?=^D",kk-1,")(?=.*lag",pp,")"), rownames(A_draw), perl=TRUE)
          if(pp == 1 & kk == 1){
            if(texo){
              slct.i = c(slct.i, grep("Ex",varNameslags))
            }
          }
          
          # multiplicative gamma prior
          if(pp==1){
            lambda2_draw[pp,kk,cc] <- rgamma(n     = 1,
                                             shape = d_lambda + tau_draw[pp,kk,cc]*n*length(slct.i),
                                             rate  = e_lambda + 0.5*tau_draw[pp,kk,cc]*sum(ALPHA_draw[slct.i,,cc]))
          }else{
            lambda2_draw[pp,kk,cc] <- rgamma(n     = 1,
                                             shape = d_lambda + tau_draw[pp,kk,cc]*n*length(slct.i),
                                             rate  = e_lambda + 0.5*tau_draw[pp,kk,cc]*prod(lambda2_draw[1:(pp-1),kk,cc])*sum(ALPHA_draw[slct.i,,cc]))
          }
          for(ss in slct.i){
            for(nn in 1:n){
              temp = do_rgig1(lambda = tau_draw[pp,kk,cc]-0.5,
                              chi    = (A_draw[ss,nn,cc] - alpha_draw[ss,nn])^2,
                              psi    = tau_draw[pp,kk,cc]*prod(lambda2_draw[1:pp,kk,cc]))
              # offsetting
              ALPHA_draw[ss,nn,cc] = ifelse(temp<1e-8,1e-8,ifelse(temp>1e+8,1e+8,temp))
            }
          }
          # Hierarchical prior
          if(sample_tau){
            before <- tau_draw[pp,kk,cc]
            tau_draw[pp,kk,cc] = MH_step(tau_draw[pp,kk,cc], tau_tuning[pp,kk,cc], n*length(slct.i), lambda2_draw[pp,kk,cc], 
                                         as.vector(A_draw[slct.i,,cc]), b_tau, nu_tau, d_lambda, e_lambda)
            if(before!=tau_draw[pp,kk,cc]){
              tau_accept[pp,kk,cc] <- tau_accept[pp,kk,cc] + 1
            }
            # scale MH proposal during the first 50% of the burn-in stage
            if(irep<(0.5*burnin)){
              if((tau_accept[pp,kk,cc]/irep)>0.30){tau_tuning[pp,kk,cc] = 1.01*tau_tuning[pp,kk,cc]}
              if((tau_accept[pp,kk,cc]/irep)<0.15){tau_tuning[pp,kk,cc] = 0.99*tau_tuning[pp,kk,cc]}
            }
          }
        } # END of for-loop 1:plag
      }
      # END OF NG SAMPLING
    }
    #----------------------------------------------------------------------------
    # Step 3: Sample common means
    for(nn in 1:n){
      A.i = A_draw[,nn,]
      V.i = ALPHA_draw[,nn,]
      
      aprior = a_prior[,nn,drop=FALSE]
      Vprior = A_prior[,nn,drop=FALSE]
      if(nn>1){
        for(ll in (nn-1):1){
          A.i = rbind(matrix(J_draw[nn,ll,,],Ki1,N), A.i)
          V.i = rbind(matrix(GAMMA_draw[nn,ll,,],Ki1,N), V.i)
          
          aprior = rbind(matrix(g_prior[nn,ll,],Ki1,1), aprior)
          Vprior = rbind(matrix(G_prior[nn,ll,],Ki1,1), Vprior)
        }
      }
      Vpriorinv = diag(1/c(Vprior))
      
      V_post = try(chol2inv(chol(diag(apply(1/V.i,1,sum)) + Vpriorinv)),silent=TRUE)
      if(is(V_post,"try-error")) V_post = try(solve(diag(apply(V.i,1,sum)) + Vpriorinv),silent=TRUE)
      if(is(V_post,"try-error")) V_post = MASS::ginv(diag(apply(V.i,1,sum)) + Vpriorinv)
      a_post = V_post %*% (apply(matrixcalc::hadamard.prod(1/V.i,A.i),1,sum) + Vpriorinv%*%aprior)
      
      alpha_draw.i = try(a_post + t(chol(V_post))%*%rnorm(nrow(A.i)),silent=TRUE)
      if(is(alpha_draw.i,"try-error")) alpha_draw.i = matrix(MASS::mvrnorm(1,a_post,V_post),nrow(A.i),1)
      alpha_draw[,nn] = alpha_draw.i[((nn-1)*Ki1+1):nrow(alpha_draw.i),]
      if(nn>1) for(kk in 1:Ki1) gamma_draw[nn,1:(nn-1),kk] = alpha_draw.i[DYmat[kk,1:(nn-1)],]
    }
    #----------------------------------------------------------------------------
    # # Step 4: Sample shrinkage prior - 2nd stage
    for(kk in 1:Ki1){
      # covariances
      v.cov = G_prior[,,kk]
      v.cov = v.cov[lower.tri(v.cov)]
      # Global Shrinkage Parameter
      delta2_draw["cov",kk] = rgamma(n = 1,
                                     shape = d_lambda + phi_draw["cov",kk]*v,
                                     rate  = e_lambda + 0.5*phi_draw["cov",kk]*sum(v.cov))
      # Local Shrinkage Parameter
      for(nn in 2:n){
        for(ii in 1:(nn-1)){
          temp = do_rgig1(lambda = phi_draw["cov",kk] - 0.5,
                          chi    = (gamma_draw[nn,ii,kk] - g_prior[nn,ii,kk])^2,
                          psi    = phi_draw["cov",kk]*delta2_draw["cov",kk])
          # offsetting
          G_prior[nn,ii,kk] = ifelse(temp<1e-8,1e-8,ifelse(temp>1e+8,1e+8,temp))
        }
      }
      # Hierarchical Prior
      if(sample_phi){
        before <- phi_draw["cov",kk]
        phi_draw["cov",kk] = MH_step(phi_draw["cov",kk], phi_tuning["cov",kk], v, delta2_draw["cov",kk], 
                                     as.vector(v.cov), b_tau, nu_tau, d_lambda, e_lambda)
        if(before!=phi_draw["cov",kk]){
          phi_accept["cov",kk] <- phi_accept["cov",kk] + 1
        }
        # scale MH proposal during the first 50% of the burn-in stage
        if(irep<(0.5*burnin)){
          if((phi_accept["cov",kk]/irep)>0.30){phi_tuning["cov",kk] = 1.01*phi_tuning["cov",kk]}
          if((phi_accept["cov",kk]/irep)<0.15){phi_tuning["cov",kk] = 0.99*phi_tuning["cov",kk]}
        }
      }
      # autoregressive coefficients
      for(pp in 1:plag){
        slct.i = grep(paste0("(?=^D",kk-1,")(?=.*lag",pp,")"), rownames(alpha_draw), perl=TRUE)
        if(pp == 1 & kk == 1){
          if(texo){
            slct.i = c(slct.i, grep("Ex",varNameslags))
          }
        }
        # multiplicative gamma prior
        if(pp==1){
          delta2_draw[pp,kk] <- rgamma(n     = 1,
                                       shape = d_lambda + phi_draw[pp,kk]*n*length(slct.i),
                                       rate  = e_lambda + 0.5*phi_draw[pp,kk]*sum(A_prior[slct.i,]))
        }else{
          delta2_draw[pp,kk] <- rgamma(n     = 1,
                                       shape = d_lambda + phi_draw[pp,kk]*n*length(slct.i),
                                       rate  = e_lambda + 0.5*phi_draw[pp,kk]*prod(delta2_draw[1:(pp-1),kk])*sum(A_prior[slct.i,]))
        }
        for(ss in slct.i){
          for(nn in 1:n){
            temp = do_rgig1(lambda = phi_draw[pp,kk] - 0.5,
                            chi    = (alpha_draw[ss,nn] - a_prior[ss,nn])^2,
                            psi    = phi_draw[pp,kk]*prod(delta2_draw[1:pp,kk]))
            # offsetting
            A_prior[ss,nn] = ifelse(temp<1e-8,1e-8,ifelse(temp>1e+8,1e+8,temp))
          }
        }
        # Hierarchical prior
        if(sample_phi){
          before <- phi_draw[pp,kk]
          phi_draw[pp,kk] = MH_step(phi_draw[pp,kk], phi_tuning[pp,kk], n*length(slct.i), delta2_draw[pp,kk], 
                                    as.vector(alpha_draw[slct.i,]), b_tau, nu_tau, d_lambda, e_lambda)
          if(before!=phi_draw[pp,kk]){
            phi_accept[pp,kk] <- phi_accept[pp,kk] + 1
          }
          # scale MH proposal during the first 50% of the burn-in stage
          if(irep<(0.5*burnin)){
            if((phi_accept[pp,kk]/irep)>0.30){phi_tuning[pp,kk] = 1.01*phi_tuning[pp,kk]}
            if((phi_accept[pp,kk]/irep)<0.15){phi_tuning[pp,kk] = 0.99*phi_tuning[pp,kk]}
          }
        }
      }
    } # END NG 2nd layer
    #----------------------------------------------------------------------------
    # Step 5: Sample variances
    for (cc in 1:N){
      for(nn in 1:n){
        S_1 <- c0 + 0.5 * bigT[cc]
        S_2 <- d0 + 0.5 * crossprod(Em_str[[cc]][,nn])
        
        sig2_draw[nn,cc] <- 1/rgamma(1,S_1,S_2)
      }
    } # end for-loop countrywise
    #----------------------------------------------------------------------------
    # Step 6: Store stuff
    if(irep %in% thin.draws){
      count = count+1
      
      A_store[count,,,]     = A_draw
      J_store[count,,,,]    = J_draw
      alpha_store[count,,]  = alpha_draw
      gamma_store[count,,,] = gamma_draw
      sig2_store[count,,]   = sig2_draw
      if(save.prior){
        ALPHA_store[count,,,]   = ALPHA_draw
        GAMMA_store[count,,,,]  = GAMMA_draw
        lambda2_store[count,,,] = lambda2_draw
        tau_store[count,,,]     = tau_draw
        Aprior_store[count,,]   = A_prior
        Gprior_store[count,,,]  = G_prior
        delta2_store[count,,]   = delta2_draw
        phi_store[count,,]      = phi_draw
      }
    }
    if(irep%%50==0) 
      cat(paste0("Current draw: ",irep,"/",ntot,".\n"))
  }
  #---------------------------------------------------------------------------------------------------------
  # END ESTIMATION
  #---------------------------------------------------------------------------------------------------------
  dimnames(A_store)=list(NULL,varNameslags,varNames)
  ret <- list(Y=Y, X=X, 
              A=A_store, alpha=alpha_store, J=J_store, gamma=gamma_store, sig2=sig2_store,
              ALPHA=ALPHA_store, GAMMA=GAMMA_store, lambda2=lambda2_store, tau=tau_store,
              Aprior=Aprior_store, Gprior=Gprior_store, delta2=delta2_store, phi=phi_store,
              args=arglist)
  return(ret)
}
