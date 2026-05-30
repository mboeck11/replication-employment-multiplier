#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Plot Figure E7 Cross-Country Effects Comparison                #
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
setting_conshigh = paste0(prior,"-",intspec,"-",varspec,"-conshigh")
setting_conslow  = paste0(prior,"-",intspec,"-",varspec,"-conslow")
setting_lmihigh  = paste0(prior,"-",intspec,"-",varspec,"-lmihigh")
setting_lmilow   = paste0(prior,"-",intspec,"-",varspec,"-lmilow")
spec_baseline    = paste0("plag=",plag,"_draws=",draws,"_burnin=",burnin)

# load baseline data
load(paste0(dirName,setting_baseline,"_data.rda"))
Dbig      = do.call("rbind",Draw)
Dbig_vals = sapply(1:d, function(dd)quantile(Dbig[,dd], int_eval[,dd])); dimnames(Dbig_vals)=list(rownames(int_eval), ivars[idx_ivars])

# load irf of baseline
load(paste0(dirName,setting_baseline,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_baseline = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: cons high
load(paste0(dirName,setting_conshigh,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_conshigh = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustnes: cons low
load(paste0(dirName,setting_conslow,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_conslow  = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: lmi high
load(paste0(dirName,setting_lmihigh,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_lmihigh  = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: lmi low
load(paste0(dirName,setting_lmilow,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_lmilow   = irffmgrid_post / conv_fac
rm(irffmgrid_post)

#-------------------------------------------------------------------------------------------------------
# plotting specification
plot_horz    = 1
x_axis_grid  = seq(1,100,length.out=5)

for(plot_horz in c(1,5)){
  pdf(paste0("./figureE7",ifelse(plot_horz==1,"a","b"),"_CrossCountry_hor=",plot_horz,".pdf"), height=6.5, width=11)
  layout(matrix(c(1,2,3,4,5,6,7,8,9,18,10,11,12,13,18,14,15,16,17,18),5,4))
  par(mfrow=c(n,d+1))
  par(fig=c(0,0.07,0.93,1),mar=c(0,0,0,0))
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  par(fig=c(0,0.07,0.65,0.93), mar=c(0,0,0,0), new=TRUE)
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  text(0.5,0.5, varNames[2], srt=90, cex=1.4, font=2)
  par(fig=c(0,0.07,0.37,0.65), mar=c(0,0,0,0), new=TRUE)
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  text(0.5,0.5, varNames[3], srt=90, cex=1.4, font=2)
  par(fig=c(0,0.07,0.09,0.37), mar=c(0,0,0,0), new=TRUE)
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  text(0.5,0.5, varNames[4], srt=90, cex=1.4, font=2)
  par(fig=c(0,0.07,0,0.09), mar=c(0,0,0,0), new=TRUE)
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  for(dd in 1:d){
    par(fig=c(0.07+0.31*(dd-1),0.07+0.31*dd,0.93,1), mar=c(0,0,0,0), new=TRUE)
    plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
    if(dd == 1) text(0.5, 0.2, expression(paste("UD (",eta,")")),       cex=1.8)
    if(dd == 2) text(0.5, 0.2, expression(paste("BRR (",varphi,")")),   cex=1.8)
    if(dd == 3) text(0.5, 0.2, expression(paste("EPL (",varsigma,")")), cex=1.8)
    
    for(nn in 2:n){
      par(fig=c(0.07+0.31*(dd-1),0.07+0.31*dd,0.93-0.28*(nn-1),0.93-0.28*(nn-2)), mar=c(2.5,3.2,1,1), new=TRUE)
      ylim1 = range(irffmgrid_post_baseline[c(2,4,6),nn,,plot_horz,], 
                    irffmgrid_post_conslow[4,nn,,plot_horz,],
                    irffmgrid_post_conshigh[4,nn,,plot_horz,],
                    irffmgrid_post_lmilow[4,nn,,plot_horz,],
                    irffmgrid_post_lmihigh[4,nn,,plot_horz,], na.rm=TRUE)
      plot.ts(irffmgrid_post_baseline[4,nn,dd,plot_horz,], ylim=ylim1, xlab="", ylab="", lty=1, lwd=2, axes=FALSE)
      abline(v=x_axis_grid, col="grey80", lwd=0.8)
      abline(h=pretty(ylim1), col="grey80", lwd=0.8)
      polygon(c(1:grid_size,rev(1:grid_size)), c(irffmgrid_post_baseline[2,nn,dd,plot_horz,],rev(irffmgrid_post_baseline[6,nn,dd,plot_horz,])),
              col = adjustcolor("grey20", alpha.f = 0.3), border=NA)
      lines(irffmgrid_post_baseline[4,nn,dd,plot_horz,], lty=1, lwd=2, col="black")
      lines(irffmgrid_post_conslow[4,nn,dd,plot_horz,], col="darkred",        lwd=2)
      points(x_axis_grid, irffmgrid_post_conslow[4,nn,dd,plot_horz,x_axis_grid], col=alpha("darkred",0.8),        pch=16, cex=2)
      lines(irffmgrid_post_conshigh[4,nn,dd,plot_horz,], col="aquamarine4",    lwd=2)
      points(x_axis_grid, irffmgrid_post_conshigh[4,nn,dd,plot_horz,x_axis_grid], col=alpha("aquamarine4",0.8),    pch=10, cex=2)
      lines(irffmgrid_post_lmilow[4,nn,dd,plot_horz,],    col="darkorange",     lwd=2)
      points(x_axis_grid, irffmgrid_post_lmilow[4,nn,dd,plot_horz,x_axis_grid],    col=alpha("darkorange",0.8),     pch=12, cex=2)
      lines(irffmgrid_post_lmihigh[4,nn,dd,plot_horz,],    col="cornflowerblue", lwd=2)
      points(x_axis_grid, irffmgrid_post_lmihigh[4,nn,dd,plot_horz,x_axis_grid],    col=alpha("cornflowerblue",0.8), pch=2,  cex=2)
      axis(1, at=x_axis_grid, labels=paste0("Q",100*seq(0.1,0.9,length.out=5)), lwd=2, cex.axis=1.4)
      axis(2, at=pretty(ylim1), las=2, lwd=2, cex.axis=1.4)
      box(lwd=2)
    }
  }
  par(fig=c(0.07,1,0,0.09), mar=c(0,0,0,0), new=TRUE)
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  legend("center", c("Baseline","Cons Lower","Cons Upper","LMI Lower","LMI Upper"), 
         lty=c(1,1,1,1,1), pch=c(NA,16,10,12,2), pt.cex=c(1,2,2,2,2),
         col=c("black","darkred","aquamarine4","darkorange","cornflowerblue"), 
         lwd=2, bty="o", horiz=TRUE, cex=1.5, text.width=NULL)
  dev.off()
}

