#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Plot Figure E5a Vola - Unemployment Rate Model                 #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
#-----------------------------------------------------------------------------#
rm(list=ls())

library(scales)

dark   = "grey40"     # dark color
bright = "grey75"     # bright color

# baseline setting
varspec      = "unrate"
intspec      = "multi"
prior        = "ng"
plag         = 1
draws        = 20000
burnin       = 10000
grid_size    = 100
idx_ivars    = 1:3
nhor         = 21

# names
vars         = c("rgovcpc", "rgdppc", "unrate", "rwage")
ivars        = c("ud","brr","epl")
varNames     = c("Government Spending", "Real GDP", "Unemployment Rate", "Real Wage")                    
ivarNames    = c("Union Density", "Unemployment Benefit Replacement Rate", "Employment Protection Legislation")
int_eval     = matrix(c(.1,.5,.9),nrow=3,ncol=length(ivars),dimnames=list(c("low","med","high"),ivars))  

# dimensions
n = length(vars)
d = length(ivars)

# fileNames
dirName        = "./empirics/results/"
setting_unrate = paste0(prior,"-",intspec,"-",varspec)
spec_unrate    = paste0("plag=",plag,"_draws=",draws,"_burnin=",burnin)

# load unrate data
load(paste0(dirName,setting_unrate,"_data.rda"))
Dbig      = do.call("rbind",Draw)
Dbig_vals = sapply(1:d, function(dd)quantile(Dbig[,dd], int_eval[,dd])); dimnames(Dbig_vals)=list(rownames(int_eval), ivars[idx_ivars])

# load irf of unrate
load(paste0(dirName,setting_unrate,"_irfgrid_",spec_unrate,".rda"))

#--------------------------------------------------------------------------------------------------
idx_rgdp   = grep("rgdp",vars)
idx_unrate = grep("unrate",vars)
idx_rwage  = grep("rwage",vars)

# order by variable
sd_rgdppc = sd_unrate = sd_rwage = NULL
for(dd in 1:d){
  sd_rgdppc = cbind(sd_rgdppc,
                    sdgrid_store[,idx_rgdp,   ivars[idx_ivars[dd]], 1], sdgrid_store[,idx_rgdp,  ivars[idx_ivars[dd]], 100], NA_real_)
  sd_unrate = cbind(sd_unrate,
                    sdgrid_store[,idx_unrate, ivars[idx_ivars[dd]], 1], sdgrid_store[,idx_unrate, ivars[idx_ivars[dd]], 100], NA_real_)
  sd_rwage  = cbind(sd_rwage,
                    sdgrid_store[,idx_rwage,  ivars[idx_ivars[dd]], 1], sdgrid_store[,idx_rwage,  ivars[idx_ivars[dd]], 100], NA_real_)
}
sd_rgdppc = sd_rgdppc[, 1:(ncol(sd_rgdppc)-1)]
sd_unrate = sd_unrate[, 1:(ncol(sd_unrate)-1)]
sd_rwage  = sd_rwage[,  1:(ncol(sd_rwage)-1)]

pdf(file="./figureE5a_Volatilities_Unrate.pdf", height=4, width=11)
par(mfrow=c(1,3), mar=c(3,3.5,2.5,1))
boxplot(sd_rgdppc, main=expression("Real GDP"), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(1.8,3.5), range=1)
abline(h=seq(0,5,by=0.3), col="grey80", lwd=0.8)
boxplot(sd_rgdppc, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, lwd=0.7, outline=FALSE, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c(expression(paste("UD (",eta,")")),expression(paste("BRR (",varphi,")")),expression(paste("EPL (",varsigma,")"))),
     cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(0,5,by=0.3), labels=format(seq(0,5,by=.3),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
legend("bottomright", c("Low","High"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)

boxplot(sd_unrate, main=expression("Unemployment Rate"), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(0.5,1.5), range=1)
abline(h=seq(0.6,5,by=.2), col="grey80", lwd=0.8)
boxplot(sd_unrate, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, lwd=0.7, outline=FALSE, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c(expression(paste("UD (",eta,")")),expression(paste("BRR (",varphi,")")),expression(paste("EPL (",varsigma,")"))),
     cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(0.6,5,by=.2), labels=format(seq(0.6,5,by=.2),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
legend("bottomright", c("Low","High"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)

boxplot(sd_rwage, main=expression("Real Wage"), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(1.5,2.7), range=1)
abline(h=seq(0,5,by=0.2), col="grey80", lwd=0.8)
boxplot(sd_rwage, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, lwd=0.7, outline=FALSE, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c(expression(paste("UD (",eta,")")),expression(paste("BRR (",varphi,")")),expression(paste("EPL (",varsigma,")"))),
     cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(0,5,by=.2), labels=format(seq(0,5,by=.2),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
legend("bottomright", c("Low","High"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)
dev.off()
