#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Plot Figure E1 Dynamic Effects                                 #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
#-----------------------------------------------------------------------------#
rm(list=ls())

library(scales)

# baseline setting
varspec      = "baseline"
intspec      = "multi"
prior        = "ng"
plag         = 1
draws        = 20000
burnin       = 10000
grid_size    = 100
idx_ivars    = 1:3
nhor         = 21

# names
vars         = c("rgovcpc", "rgdppc", "emprate", "rwage")
ivars        = c("ud","brr","epl")
varNames     = c("Government Spending", "Real GDP", "Employment Rate", "Real Wage")                    
ivarNames    = c("Union Density", "Unemployment Benefit Replacement Rate", "Employment Protection Legislation")
int_eval     = matrix(c(.1,.5,.9),nrow=3,ncol=length(ivars),dimnames=list(c("low","med","high"),ivars))
plot_knames  = c("Q10","Q90","Q90-Q10")

# dimensions
n = length(vars)
d = length(ivars)

# fileNames
dirName          = "./empirics/results/"
setting_baseline = paste0(prior,"-",intspec,"-",varspec)
spec_baseline    = paste0("plag=",plag,"_draws=",draws,"_burnin=",burnin)

# load baseline data
load(paste0(dirName,setting_baseline,"_data.rda"))
Dbig      = do.call("rbind",Draw)
Dbig_vals = sapply(1:d, function(dd)quantile(Dbig[,dd], int_eval[,dd])); dimnames(Dbig_vals)=list(rownames(int_eval), ivars[idx_ivars])

# load irf of baseline
load(paste0(dirName,setting_baseline,"_irf_",spec_baseline,".rda"))

#-------------------------------------------------------------------------------------------------------
for(dd in 1:d){
  pdf(file=paste0("./figureE1",ifelse(ivars[dd]=="ud","a",ifelse(ivars[dd]=="brr","b","c")),"_DynamicEffects_",toupper(ivars[dd]),".pdf"), height=5, width=13)
  par(mfrow=c(3,n), mar=c(2,3,2,1))
  for(kk in 1:3){
    for(nn in 1:n){
      ylim1 = range(irf_post[,nn,dd,,])
      main1 = paste0(varNames[nn]," (",toupper(ivars[dd]),": ",plot_knames[kk],")")
      plot.ts(irf_post[4,nn,dd,,kk], main=main1, ylim=ylim1, axes=FALSE, xlab="", ylab="", cex.main=1.4)
      abline(v=seq(1,nhor,by=6), col="grey80", lwd=0.8)
      abline(h=pretty(ylim1), col="grey80", lwd=0.8)
      polygon(c(1:nhor,rev(1:nhor)), c(irf_post[1,nn,dd,,kk],rev(irf_post[7,nn,dd,,kk])), col = "grey80", border=NA)
      polygon(c(1:nhor,rev(1:nhor)), c(irf_post[2,nn,dd,,kk],rev(irf_post[6,nn,dd,,kk])), col = "grey60", border=NA)
      polygon(c(1:nhor,rev(1:nhor)), c(irf_post[3,nn,dd,,kk],rev(irf_post[5,nn,dd,,kk])), col = "grey40", border=NA)
      lines(irf_post[4,nn,dd,,kk], col="black", lwd=2, lty=1)
      abline(h=0, col="grey20", lwd=2)
      axis(1, at=seq(1,nhor,by=6), labels=seq(0,nhor,by=6), lwd=2, cex.axis=1.3)
      axis(2, at=pretty(ylim1), lwd=2, las=2, cex.axis=1.3)
      box(lwd=2)
    }
  }
  dev.off()
}
