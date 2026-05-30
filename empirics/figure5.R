#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Figure 5 Volatilities                                          #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
# May 2026                                                                    #
#-----------------------------------------------------------------------------#
rm(list=ls())

library(scales)

dark   = "grey40"     # dark color
bright = "grey75"     # bright color

# baseline setting
varspec      = "baseline"
intspec      = "multi"
prior        = "ng"
plag         = 1
draws        = 40000
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

#--------------------------------------------------------------------------------------------------
idx_rgdp       = grep("rgdp",vars)
idx_emprate    = grep("emprate",vars)
idx_rwage      = grep("rwage",vars)

# order by variable
sd_rgdppc = sd_emprate = sd_rwage = NULL
for(dd in 1:d){
  sd_rgdppc = cbind(sd_rgdppc,
                    sdgrid_store[,idx_rgdp,     ivars[idx_ivars[dd]], 1], sdgrid_store[,idx_rgdp,    ivars[idx_ivars[dd]], 100], NA_real_)
  sd_emprate = cbind(sd_emprate,
                     sdgrid_store[,idx_emprate, ivars[idx_ivars[dd]], 1], sdgrid_store[,idx_emprate, ivars[idx_ivars[dd]], 100], NA_real_)
  sd_rwage   = cbind(sd_rwage,
                     sdgrid_store[,idx_rwage,   ivars[idx_ivars[dd]], 1], sdgrid_store[,idx_rwage,   ivars[idx_ivars[dd]], 100], NA_real_)
}
sd_rgdppc  = sd_rgdppc[, 1:(ncol(sd_rgdppc)-1)]
sd_emprate = sd_emprate[,1:(ncol(sd_emprate)-1)]
sd_rwage   = sd_rwage[,  1:(ncol(sd_rwage)-1)]

pdf(file="./figure5_Volatilities.pdf", height=4, width=11)
par(mfrow=c(1,3), mar=c(3,3.5,2.5,1))
boxplot(sd_rgdppc, main=expression("Real GDP"), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(1.8,3.6), range=1)
abline(h=seq(0,5,by=0.3), col="grey80", lwd=0.8)
boxplot(sd_rgdppc, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, lwd=0.7, outline=FALSE, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c(expression(paste("UD (",eta,")")),expression(paste("BRR (",varphi,")")),expression(paste("EPL (",varsigma,")"))),
     cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(0,5,by=0.3), labels=format(seq(0,5,by=.3),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
legend("bottomright", c("Low","High"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)

boxplot(sd_emprate, main=expression("Employment Rate"), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(0.5,1.5), range=1)
abline(h=seq(0.6,5,by=.2), col="grey80", lwd=0.8)
boxplot(sd_emprate, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, lwd=0.7, outline=FALSE, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c(expression(paste("UD (",eta,")")),expression(paste("BRR (",varphi,")")),expression(paste("EPL (",varsigma,")"))),
     cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(0.6,5,by=.2), labels=format(seq(0.6,5,by=.2),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
legend("bottomright", c("Low","High"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)

boxplot(sd_rwage, main=expression("Real Wage"), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(1.5,3.1), range=1)
abline(h=seq(0,5,by=0.2), col="grey80", lwd=0.8)
boxplot(sd_rwage, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, lwd=0.7, outline=FALSE, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c(expression(paste("UD (",eta,")")),expression(paste("BRR (",varphi,")")),expression(paste("EPL (",varsigma,")"))),
     cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(0,5,by=.2), labels=format(seq(0,5,by=.2),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
legend("bottomright", c("Low","High"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)
dev.off()
