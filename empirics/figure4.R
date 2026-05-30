#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Figure 4 Forecast Error Variance Decomposition                 #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
# May 2026                                                                    #
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
load(paste0(dirName,setting_baseline,"_irfgrid_",spec_baseline,".rda"))

pdf(file="./figure4_fevd.pdf", height=6, width=10)
par(mfrow=c(n-1,d),mar=c(2,5.5,2,1))
for(nn in 2:n){
  ylim1 <- range(fevdgrid_post[c(2,4,6),nn,,,c(1,100)], na.rm=TRUE)
  for(dd in 1:d){
    plot.ts(fevdgrid_post[4,nn,dd,,1], ylim=ylim1, xlab="", ylab="", xaxt="n", lty=1, lwd=2, yaxt="n")
    abline(h=pretty(ylim1), col="grey80", lwd=0.8)
    abline(v=seq(1,nhor,by=4), col="grey80", lwd=0.8)
    polygon(c(1:nhor,rev(1:nhor)), c(fevdgrid_post[2,nn,dd,,1],   rev(fevdgrid_post[6,nn,dd,,1])),   
            col = adjustcolor("grey20", alpha.f = 0.5), border=NA)
    polygon(c(1:nhor,rev(1:nhor)), c(fevdgrid_post[2,nn,dd,,100], rev(fevdgrid_post[6,nn,dd,,100])), 
            col = adjustcolor("darkorange3", alpha.f = 0.5), border=NA)
    lines(fevdgrid_post[4,nn,dd,,1], lty=1, lwd=2, col="black")
    lines(fevdgrid_post[4,nn,dd,,100], lty=2, lwd=2, col="darkred")
    if(nn == 2 && dd == 1)
      title(expression(paste("UD (",eta,")")), cex.main=1.8)
    if(nn == 2 && dd == 2)
      title(expression(paste("BRR (",varphi,")")), cex.main=1.8)
    if(nn == 2 && dd == 3)
      title(expression(paste("EPL (",varsigma,")")), cex.main=1.8)
    if(dd == 1)
      mtext(varNames[nn], side=2, line=4, font=2)
    if(nn == 2 && dd == 3)
      legend("topright", c("Low","High"), lty=c(1,2), lwd=3, col=c("black","darkred"), bty="n", cex=1.5)
    axis(1, at=seq(1,nhor,by=4), labels=seq(0,nhor-1,by=4), cex.axis=1.4)
    axis(2, at=pretty(ylim1), las=2, cex.axis=1.4)
  }
}
dev.off()