#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Plot Figure E5b Change in Vola - Unemployment Rate Model       #
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
load(paste0(dirName,setting_unrate,"_vardecompgrid_",spec_unrate,".rda"))

#--------------------------------------------------------------------------------------------------
idx_rgdp   = grep("rgdp",vars)
idx_unrate = grep("unrate",vars)
idx_rwage  = grep("rwage",vars)

# basis small
basis <- 1
# union density
sd_ud  = cbind(STEsd_store[idx_rgdp,    "ud", 100, basis,] - STEsd_store[idx_rgdp,     "ud", 1, basis,],
               SSEsd_store[idx_rgdp,    "ud", 100, basis,] - SSEsd_store[idx_rgdp,     "ud", 1, basis,],
               NA_real_,
               STEsd_store[idx_unrate, "ud", 100, basis,] - STEsd_store[idx_unrate,  "ud", 1, basis,],
               SSEsd_store[idx_unrate, "ud", 100, basis,] - SSEsd_store[idx_unrate,  "ud", 1, basis,],
               NA_real_,
               STEsd_store[idx_rwage,   "ud", 100, basis,] - STEsd_store[idx_rwage,    "ud", 1, basis,],
               SSEsd_store[idx_rwage,   "ud", 100, basis,] - SSEsd_store[idx_rwage,    "ud", 1, basis,])
# unemployment benefit replacement rates
sd_brr = cbind(STEsd_store[idx_rgdp,    "brr", 100, basis,] - STEsd_store[idx_rgdp,    "brr", 1, basis,],
               SSEsd_store[idx_rgdp,    "brr", 100, basis,] - SSEsd_store[idx_rgdp,    "brr", 1, basis,],
               NA_real_,
               STEsd_store[idx_unrate, "brr", 100, basis,] - STEsd_store[idx_unrate, "brr", 1, basis,],
               SSEsd_store[idx_unrate, "brr", 100, basis,] - SSEsd_store[idx_unrate, "brr", 1, basis,],
               NA_real_,
               STEsd_store[idx_rwage,   "brr", 100, basis,] - STEsd_store[idx_rwage,   "brr", 1, basis,],
               SSEsd_store[idx_rwage,   "brr", 100, basis,] - SSEsd_store[idx_rwage,   "brr", 1, basis,])
# employment protection legislation
sd_epl = cbind(STEsd_store[idx_rgdp,    "epl", 100, basis,] - STEsd_store[idx_rgdp,    "epl", 1, basis,],
               SSEsd_store[idx_rgdp,    "epl", 100, basis,] - SSEsd_store[idx_rgdp,    "epl", 1, basis,],
               NA_real_,
               STEsd_store[idx_unrate, "epl", 100, basis,] - STEsd_store[idx_unrate, "epl", 1, basis,],
               SSEsd_store[idx_unrate, "epl", 100, basis,] - SSEsd_store[idx_unrate, "epl", 1, basis,],
               NA_real_,
               STEsd_store[idx_rwage,   "epl", 100, basis,] - STEsd_store[idx_rwage,   "epl", 1, basis,],
               SSEsd_store[idx_rwage,   "epl", 100, basis,] - SSEsd_store[idx_rwage,   "epl", 1, basis,])

pdf(file="./figureE5b_DeltaVolatilities_Unrate.pdf", height=4, width=11)
par(mfrow=c(1,3), mar=c(3,5,2.5,1))
boxplot(sd_ud, main=expression(paste(Delta,"UD(",eta,") > 0")), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(-0.6,0.7), range=1)
abline(h=seq(-2,2,by=0.2), col="grey80", lwd=0.8)
boxplot(sd_ud, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, outline=FALSE, lwd=0.7, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c("Real GDP","Unemp. Rate","Real Wage"), cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(-2,2,by=0.2), labels=format(seq(-2,2,by=0.2),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
mtext("Change in Volatility", side=2.5, line=3.5)
legend("bottomright", c("STE","SSE"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)

boxplot(sd_brr, main=expression(paste(Delta,"BRR(",varphi,") > 0")), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(-0.6,1), range=1)
abline(h=seq(-2,2,by=0.2), col="grey80", lwd=0.8)
boxplot(sd_brr, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, outline=FALSE, lwd=0.7, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c("Real GDP","Unemp. Rate","Real Wage"), cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(-2,2,by=0.2), labels=format(seq(-2,2,by=0.2),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
mtext("Change in Volatility", side=2.5, line=3.5)
legend("bottomright", c("STE","SSE"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)

boxplot(sd_epl, main=expression(paste(Delta,"EPL(",varsigma,") > 0")), axes=FALSE, cex.main=1.8, outline=FALSE, ylim=c(-1.5,0.7), range=1)
abline(h=seq(-2,2,by=0.4), col="grey80", lwd=0.8)
boxplot(sd_epl, col=c(dark,bright,"black",dark,bright,"black",dark,bright), axes=FALSE, outline=FALSE, lwd=0.7, range=1, add=TRUE)
axis(1, at=c(1.5,4.5,7.5), labels=c("Real GDP","Unemp Rate","Real Wage"), cex.axis=1.4, line=0.5, tick=FALSE)
axis(2, at=seq(-2,2,by=0.4), labels=format(seq(-2,2,by=0.4),nsmall=1), las=2, cex.axis=1.4); box(lwd=2)
mtext("Change in Volatility", side=2.5, line=3.5)
legend("bottomright", c("STE","SSE"), col=c(dark,bright), lwd=4, bty="n", cex=1.5)
dev.off()

