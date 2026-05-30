#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Figure 3 Fiscal Multipliers                                    #
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
conv_fac     = 0.2     # to transform into multiplier

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

irffmgrid_post = irffmgrid_post / conv_fac

#-------------------------------------------------------------------------------------------------------
# plotting specification
plot_horz    = c(1,5)
x_axis_grid  = seq(1,100,length.out=5)

pdf(file="./figure3_FiscalMultipliers.pdf", height=6, width=10)
par(mfrow=c(n,d+1))
par(fig=c(0,0.07,0.93,1),mar=c(0,0,0,0))
plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
par(fig=c(0,0.07,0.62,0.93), mar=c(0,0,0,0), new=TRUE)
plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
text(0.5,0.5, varNames[2], srt=90, cex=1.8, font=2)
par(fig=c(0,0.07,0.31,0.62), mar=c(0,0,0,0), new=TRUE)
plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
text(0.5,0.5, varNames[3], srt=90, cex=1.8, font=2)
par(fig=c(0,0.07,0.00,0.31), mar=c(0,0,0,0), new=TRUE)
plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
text(0.5,0.5, varNames[4], srt=90, cex=1.8, font=2)
for(dd in 1:d){
  par(fig=c(0.07+0.31*(dd-1),0.07+0.31*dd,0.93,1), mar=c(0,0,0,0), new=TRUE)
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  if(dd == 1) text(0.5, 0.2, expression(paste("UD (",eta,")")),       cex=1.8)
  if(dd == 2) text(0.5, 0.2, expression(paste("BRR (",varphi,")")),   cex=1.8)
  if(dd == 3) text(0.5, 0.2, expression(paste("EPL (",varsigma,")")), cex=1.8)
  
  for(nn in 2:n){
    par(fig=c(0.07+0.31*(dd-1),0.07+0.31*dd,0.93-0.31*(nn-1),0.93-0.31*(nn-2)), mar=c(2.5,2.8,1,1), new=TRUE)
    ylim1 = range(irffmgrid_post[,nn,,plot_horz,], na.rm=TRUE)
    plot.ts(irffmgrid_post[4,nn,dd,plot_horz[1],], ylim=ylim1, xlab="", ylab="", lty=1, lwd=2, axes=FALSE)
    abline(v=seq(1,100,length.out=5), col="grey90", lwd=0.6)
    abline(h=pretty(ylim1), col="grey90", lwd=0.6)
    lines(irffmgrid_post[4,nn,dd,plot_horz[1],], lty=1, lwd=2, col="black")
    polygon(c(1:grid_size,rev(1:grid_size)), c(irffmgrid_post[2,nn,dd,plot_horz[1],],rev(irffmgrid_post[6,nn,dd,plot_horz[1],])), 
            col = adjustcolor("grey20", alpha.f = 0.3), border=NA)
    if(dd == 1 && nn == 2)
      legend("topright", c("P=0","P=4"), lty=c(1,4), col=c("black","darkred"), lwd=2)
    lines(irffmgrid_post[4,nn,dd,plot_horz[2],], lty=4, col="darkred", lwd=2)
    polygon(c(1:grid_size,rev(1:grid_size)), c(irffmgrid_post[3,nn,dd,plot_horz[2],],rev(irffmgrid_post[5,nn,dd,plot_horz[2],])),
            col = adjustcolor( "darkorange3", alpha.f = 0.3), border=NA)
    axis(1, at=seq(1,100,length.out=5), labels=paste0("Q",100*seq(0.1,0.9,length.out=5)), lwd=2, cex.axis=1.4)
    axis(2, at=pretty(ylim1), las=2, lwd=2, cex.axis=1.4)
    box(lwd=2)
  }
}
dev.off()

