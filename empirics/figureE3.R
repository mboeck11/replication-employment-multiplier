#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Plot Figure E3 Fiscal Foresight Robustness                     #
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
dirName             = "./empirics/results/"
setting_g7          = paste0(prior,"-",intspec,"-",varspec,"-g7")
setting_g7oecdshort = paste0(prior,"-",intspec,"-",varspec,"-g7-shortoecd")
setting_g7oxfshort  = paste0(prior,"-",intspec,"-",varspec,"-g7-shortoxf")
setting_oecdfcst    = paste0(prior,"-",intspec,"-",varspec,"-g7-oecdfcst")
setting_oecdfcst2   = paste0(prior,"-",intspec,"-",varspec,"-g7-oecdfcst2")
setting_oxffcst2    = paste0(prior,"-",intspec,"-",varspec,"-g7-oxffcst2")
setting_udbrr_oecd2 = paste0(prior,"-ud-brr-",varspec,"-g7-oecdfcst2")
setting_udbrr_oxf2  = paste0(prior,"-ud-brr-",varspec,"-g7-oxffcst2")
spec_baseline       = paste0("plag=",plag,"_draws=",draws,"_burnin=",burnin)

# load baseline data
load(paste0(dirName,setting_g7,"_data.rda"))
Dbig      = do.call("rbind",Draw)
Dbig_vals = sapply(1:d, function(dd)quantile(Dbig[,dd], int_eval[,dd])); dimnames(Dbig_vals)=list(rownames(int_eval), ivars[idx_ivars])

# load baseline: g7
load(paste0(dirName,setting_g7,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_g7        = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: g7 short oecd
load(paste0(dirName,setting_g7oecdshort,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_g7oecdshort = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: g7 short oxf
load(paste0(dirName,setting_g7oxfshort,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_g7oxfshort  = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: g7 oecdfcst2
load(paste0(dirName,setting_oecdfcst2,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_oecdfcst2   = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: g7 oxffcst2
load(paste0(dirName,setting_oxffcst2,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_oxffcst2    = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: ud-brr g7 oecdfcst2
load(paste0(dirName,setting_udbrr_oecd2,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_udbrr_oecd2 = irffmgrid_post / conv_fac
rm(irffmgrid_post)

# load robustness: ud-brr g7 oxffcst2
load(paste0(dirName,setting_udbrr_oxf2,"_irfgrid_",spec_baseline,".rda"))
irffmgrid_post_udbrr_oxf2  = irffmgrid_post / conv_fac
rm(irffmgrid_post)

#-------------------------------------------------------------------------------------------------------
# plotting specification
plot_horz    = 1
x_axis_grid  = seq(1,100,length.out=5)

for(plot_horz in c(1,5)){
  pdf(paste0("./figureE3",ifelse(plot_horz==1,"a","b"),"_FiscalForesight_hor=",plot_horz,".pdf"), height=6.5, width=11)
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
      par(fig=c(0.07+0.31*(dd-1),0.07+0.31*dd,0.93-0.28*(nn-1),0.93-0.28*(nn-2)), mar=c(2.5,2.8,1,1), new=TRUE)
      ylim1 = range(irffmgrid_post_g7[c(2,4,6),nn,,plot_horz,], 
                    irffmgrid_post_g7oecdshort[4,nn,,plot_horz,],
                    irffmgrid_post_g7oxfshort[4,nn,,plot_horz,],
                    irffmgrid_post_oecdfcst2[4,nn+1,,plot_horz,],
                    irffmgrid_post_oxffcst2[4,nn+1,,plot_horz,], na.rm=TRUE)
      plot.ts(irffmgrid_post_g7[4,nn,dd,plot_horz,], ylim=ylim1, xlab="", ylab="", lty=1, lwd=2, axes=FALSE)
      abline(v=x_axis_grid, col="grey80", lwd=0.8)
      abline(h=pretty(ylim1), col="grey80", lwd=0.8)
      lines(irffmgrid_post_g7[4,nn,dd,plot_horz,], lty=1, lwd=2, col="black")
      polygon(c(1:grid_size,rev(1:grid_size)), c(irffmgrid_post_g7[2,nn,dd,plot_horz,],rev(irffmgrid_post_g7[6,nn,dd,plot_horz,])), 
              col = adjustcolor("grey20", alpha.f = 0.3), border=NA)
      lines(irffmgrid_post_g7oecdshort[4,nn,dd,plot_horz,], col="darkred",        lwd=2)
      points(x_axis_grid, irffmgrid_post_g7oecdshort[4,nn,dd,plot_horz,x_axis_grid], col=alpha("darkred",0.8), pch=16, cex=2)
      lines(irffmgrid_post_g7oxfshort[4,nn,dd,plot_horz,],  col="aquamarine4",    lwd=2)
      points(x_axis_grid, irffmgrid_post_g7oxfshort[4,nn,dd,plot_horz,x_axis_grid],    col=alpha("aquamarine4",0.8), pch=10, cex=2)
      lines(irffmgrid_post_oecdfcst2[4,nn+1,dd,plot_horz,], col="darkorange",     lwd=2)
      points(x_axis_grid, irffmgrid_post_oecdfcst2[4,nn+1,dd,plot_horz,x_axis_grid], col=alpha("darkorange",0.8), pch=12, cex=2)
      lines(irffmgrid_post_oxffcst2[4,nn+1,dd,plot_horz,],  col="cornflowerblue", lwd=2)
      points(x_axis_grid, irffmgrid_post_oxffcst2[4,nn+1,dd,plot_horz,x_axis_grid],  col=alpha("cornflowerblue",0.8), pch=2, cex=2)
      if(ivars[dd] %in% c("ud","brr")){
        lines(irffmgrid_post_udbrr_oecd2[4,nn+1,dd,plot_horz,], col="darkorchid3", lwd=2)
        points(x_axis_grid, irffmgrid_post_udbrr_oecd2[4,nn+1,dd,plot_horz,x_axis_grid], col=alpha("darkorchid3",0.8), pch=4, cex=2)
        lines(irffmgrid_post_udbrr_oxf2[4,nn+1,dd,plot_horz,], col="chartreuse3", lwd=2)
        points(x_axis_grid, irffmgrid_post_udbrr_oxf2[4,nn+1,dd,plot_horz,x_axis_grid], col=alpha("chartreuse3",0.8), pch=6, cex=2)
      }
      axis(1, at=x_axis_grid, labels=paste0("Q",100*seq(0.1,0.9,length.out=5)), lwd=2, cex.axis=1.4)
      axis(2, at=pretty(ylim1), las=2, lwd=2, cex.axis=1.4)
      box(lwd=2)
    }
  }
  par(fig=c(0.07,1,0,0.09), mar=c(0,0,0,0), new=TRUE)
  plot(-10,-10,axes=FALSE,ylim=c(0,1),xlim=c(0,1))
  legend("center", c("G7","G7 (OECD EO)","G7 (Oxf Econ)","OECD EO","Oxf Econ","OECD EO (UD-BRR)","Oxf Econ (UD-BRR)"), 
         lty=c(1,1,1,1,1,1,1), pch=c(NA,16,10,12,2,4,6), pt.cex=c(1,2,2,2,2,2,2), 
         col=c("black","darkred","aquamarine4","darkorange","cornflowerblue","darkorchid3","chartreuse3"), 
         lwd=2, bty="o", horiz=TRUE, cex=1.06, text.width=NULL)
  dev.off()
}
