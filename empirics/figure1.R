#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Plot Figure 2: LMIs Cross-Country Variation                    #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
# May 2026                                                                    #
#-----------------------------------------------------------------------------#
rm(list=ls())
library(scales)

# load data
load("./empirics/data_for_estimation.rda")

cN = names(data)
N  = length(cN)

ivars     = c("ud","brr","epl")
ivarNames = c("Union Density", "Benefit Replacement Rate", "Employment Protection Legislation")
d         = length(ivars)

# plotting of LMIs
pdf(file="./figure1_LMIs_CrossCountry.pdf", height=4, width=12)
par(mfrow=c(1,d), mar=c(4,4,3,2))
for(dd in 1:d){
  data_tmp   = do.call("cbind",lapply(data,function(l)l[,ivars[dd]]))
  data_mean  = apply(data_tmp,2,mean,na.rm=TRUE)
  data_quant = apply(data_tmp,2,quantile,c(.10,.90),na.rm=TRUE)
  data_order = order(data_mean)
  data_mean  = data_mean[data_order]
  data_quant = data_quant[,data_order]
  
  if(dd == 1) ylim1=c(0,100)
  if(dd == 2) ylim1=c(0,65)
  if(dd == 3) ylim1=c(0,7)
  plot(1:N, data_mean, axes=FALSE, xlab="", ylab="", ylim=ylim1)
  if(dd == 1) abline(h=seq(0,100,20), col="grey80", lwd=0.8)
  if(dd == 2) abline(h=seq(0,100,10), col="grey80", lwd=0.8)
  if(dd == 3) abline(h=seq(0,100,1),  col="grey80", lwd=0.8)
  abline(v=seq(0,N,4), col="grey80", lwd=0.8)
  if(dd == 1) title(expression(paste("Union density (UD, ",eta,")")), cex.main=2)
  if(dd == 2) title(expression(paste("U. benefit repl. rates (BRR, ",varphi,")")), cex.main=2)
  if(dd == 3) title(expression(paste("Employment protection (EPL, ",varsigma,")")), cex.main=2)
  axis(1, at=1:N, labels=toupper(cN[data_order]), las=2, cex.axis=1.4)
  if(dd == 1) axis(2, at=seq(0,100,by=20), labels=paste0(seq(0,100,20),"%"), las=2, cex.axis=1.4)
  if(dd == 2) axis(2, at=seq(0,100,by=10), labels=paste0(seq(0,100,10),"%"), las=2, cex.axis=1.4)
  if(dd == 3) axis(2, at=seq(0,100,by=1),  las=2, cex.axis=1.4)
  box(lwd=1.5)
  for(cc in 1:N){
    points_y = unique(data_tmp[,data_order[cc]])
    points_x = rep(cc, length(points_y)) + rnorm(length(points_y),0,0.1)
    points(x=points_x, y=points_y, col=adjustcolor( "blue", alpha.f = 0.8), pch=16)
  }
  arrows(1:N, data_quant[1,], 1:N, data_quant[2,], 
         length=0.05, angle=90, code=3, lwd=2, cex=1.5)
  points(1:N, data_mean, pch=19, lwd=2, cex=1.2)
}
dev.off()
