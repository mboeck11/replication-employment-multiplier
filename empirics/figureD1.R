#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Plot LMIs                                                      #
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
pdf(file="./figureD1_LMIs_TimeVariation.pdf", height=4, width=12)
par(mfrow=c(1,d), mar=c(4,4,3,2))
for(dd in 1:d){
  data_tmp   = do.call("cbind",lapply(data,function(l)l[,ivars[dd]]))
  data_mean  = ts(apply(data_tmp,1,mean,na.rm=TRUE), start=c(1960,1), frequency=4)
  data_sd    = ts(apply(data_tmp,1,sd,na.rm=TRUE), start=c(1960,1), frequency=4)
  data_range = ts(apply(data_tmp,1,range,na.rm=TRUE), start=c(1960,1), frequency=4)
  data_quant = ts(apply(data_tmp,1,quantile,c(0.10,0.90),na.rm=TRUE), start=c(1960,1), frequency=4)
  if(dd == 1) ylim1=c(0,100)
  if(dd == 2) ylim1=c(0,65)
  if(dd == 3) ylim1=c(-0.5,7)
  plot.ts(data_mean, xlab="", ylab="", ylim=ylim1, axes=FALSE, cex.main=1.8, lty=2, lwd=3)
  if(dd == 1) title(expression(paste("Union density (UD, ",eta,")")), cex.main=2)
  if(dd == 2) title(expression(paste("U. benefit repl. rates (BRR, ",varphi,")")), cex.main=2)
  if(dd == 3) title(expression(paste("Employment protection (EPL, ",varsigma,")")), cex.main=2)
  abline(v=seq(1960,2020,by=20), col="grey80", lwd=0.8)
  if(dd == 1) abline(h=seq(0,100,20), col="grey80", lwd=0.8)
  if(dd == 2) abline(h=seq(0,100,10), col="grey80", lwd=0.8)
  if(dd == 3) abline(h=seq(0,100,1),  col="grey80", lwd=0.8)
  polygon(c(time(data_mean),rev(time(data_mean))), c(data_quant[1,], rev(data_quant[2,])), col=alpha("darkorange", alpha=0.3))
  lines(data_mean, col="darkred", lwd=3, lty=2)
  
  # selected countries: USA
  lines(data_tmp[,"usa"], col="grey20", lwd=2)
  points(x=time(data_tmp)[seq(1,244,by=20)], y=data_tmp[seq(1,244,by=20),"usa"], pch=8, cex=1.5)
  text("USA", x=2010, y=c(7.5,10,-0.4)[dd], cex=1.5) 
  
  # selected countries: NLD
  lines(data_tmp[,"nld"], col="grey20", lwd=2)
  points(x=time(data_tmp)[seq(1,244,by=20)], y=data_tmp[seq(1,244,by=20),"nld"], pch=2, cex=1.5)
  text("NLD", x=1993, y=c(31,58,4)[dd], cex=1.5)
  
  # selected countries: SWE
  lines(data_tmp[,"swe"], col="grey20", lwd=2)
  points(x=time(data_tmp)[seq(1,244,by=20)], y=data_tmp[seq(1,244,by=20),"swe"], pch=4, cex=1.5)
  text("SWE", x=2012, y=c(76,22,2.7)[dd], cex=1.5)
  
  axis(1, at=seq(1960,2020,by=20), lwd=2, cex.axis=1.4)
  if(dd == 1) axis(2, at=seq(0,100,by=20), labels=paste0(seq(0,100,20),"%"), las=2, cex.axis=1.4)
  if(dd == 2) axis(2, at=seq(0,100,by=10), labels=paste0(seq(0,100,10),"%"), las=2, cex.axis=1.4)
  if(dd == 3) axis(2, at=seq(0,100,by=1),  las=2, cex.axis=1.4)
  box(lwd=2)
}
dev.off()
