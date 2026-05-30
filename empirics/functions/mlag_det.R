mlag_det <- function(X,lag,cons=FALSE,trend=FALSE,trendsq=FALSE){
  p <- lag
  X <- as.matrix(X)
  Traw <- nrow(X)
  N <- ncol(X)
  Xlag <- matrix(0,Traw,p*N)
  for (ii in 1:p){
    Xlag[(p+1):Traw,(N*(ii-1)+1):(N*ii)] <- X[(p+1-ii):(Traw-ii),(1:N)]
  }
  colnames(Xlag) <- paste0(colnames(X),".lag",rep(seq(p),each=N))
  if(cons){
    Xlag <- cbind(Xlag,1)
    colnames(Xlag)[ncol(Xlag)] <- "cons"
  }
  if(trend){
    Xlag <- cbind(Xlag,seq(1,Traw))
    colnames(Xlag)[ncol(Xlag)] <- "trend"
  }
  if(trendsq){
    Xlag <- cbind(Xlag,seq(1,Traw)^2)
    colnames(Xlag)[ncol(Xlag)] <- "trendsq"
  }
  
  return(Xlag)
}
