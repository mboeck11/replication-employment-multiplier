#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Prepare Dataset                                                #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
# 22/05/2026                                                                  #
#-----------------------------------------------------------------------------#
rm(list=ls())

library(readxl)
library(stringr)
library(seasonal)
library(deseats)

# countries
cN = excel_sheets("./data/data_NatAcc.xlsx")
cN = cN[-1]
N  = length(cN)

# load labor market institutions data
ud  = read_xlsx("./data/data_LMI.xlsx", sheet="UD")
brr = read_xlsx("./data/data_LMI.xlsx", sheet="BRR")
epl = read_xlsx("./data/data_LMI.xlsx", sheet="EPL")

# loop
data = list()
for(cc in 1:length(cN)){
  # select country name
  cntry <- cN[cc]
  
  # load data
  data_cc = read_xlsx("./data/data_NatAcc.xlsx", sheet=cntry)
  colnames(data_cc)[2:ncol(data_cc)] = str_extract(colnames(data_cc[,2:ncol(data_cc)]), "(?<=_).*")
  colnames(data_cc)[1]="time"
  
  # kill unnecessary rows
  data_cc = data_cc[which(!is.na(data_cc$time)),]
  
  # do seasonal adjustment for some countries and series
  if(cntry %in% c("aus","can")){
    idx_emp = which(!is.na(data_cc$emp))
    data_cc$emp[idx_emp] = final(seas(ts(data_cc$emp, start=c(1960,1), frequency=4))) # seasonal package clears NAs
  }
  if(cntry %in% c("aus","can","jpn","kor")){
    idx_emp_indu = which(!is.na(data_cc$emp_indu))
    data_cc$emp_indu[idx_emp_indu] = final(seas(ts(data_cc$emp_indu, start=c(1960,1), frequency=4))) # seasonal package clears NAs
  }
  if(cntry %in% c("jpn")){
    idx_pop = which(!is.na(data_cc$pop))
    data_cc$pop[idx_pop] = final(seas(ts(data_cc$pop, start=c(1960,1), frequency=4))) # seasonal package clears NAs
  }
  if(cntry %in% c("can")){
    idx_hours = which(!is.na(data_cc$hours))
    data_cc$hours[idx_hours] = final(seas(ts(data_cc$hours, start=c(1960,1), frequency=4))) # seasonal package clears NAs
  }
  
  # construct some additional variables
  data_cc$rgovcgrowth  = NA_real_
  data_cc$rgovcgrowth[2:nrow(data_cc)] = diff(log(data_cc$rgovc),lag=1)*400
  data_cc$rgovc_oxf_fe  = data_cc$rgovcgrowth - data_cc$oxf_govf
  data_cc$rgovc_oecd_fe = data_cc$rgovcgrowth - data_cc$oecd_govf
  data_cc$rgovcpc       = data_cc$rgovc      / data_cc$pop
  data_cc$rgdppc        = data_cc$rgdp       / data_cc$pop
  data_cc$emppc         = data_cc$emp        / data_cc$pop
  data_cc$emppc_indu    = data_cc$emp_indu   / data_cc$pop
  data_cc$uepc          = data_cc$ue         / data_cc$pop
  data_cc$emprate       = data_cc$emp        / (data_cc$emp + data_cc$ue) * 100
  data_cc$emprate_indu  = data_cc$emp_indu   / (data_cc$emp + data_cc$ue) * 100
  data_cc$unrate        = data_cc$ue         / (data_cc$emp + data_cc$ue) * 100
  data_cc$vacrate       = data_cc$vac        / (data_cc$emp + data_cc$ue) * 100
  data_cc$rwage         = data_cc$wages      / data_cc$gdpdef
  data_cc$rwagepc       = data_cc$wages      / (data_cc$gdpdef * data_cc$pop)
  data_cc$rwage_indu    = data_cc$wages_indu / data_cc$gdpdef
  data_cc$rwagepc_indu  = data_cc$wages_indu / (data_cc$gdpdef * data_cc$pop)
  data_cc$vu            = data_cc$vac        / (data_cc$ue*1000)
  data_cc$rgovcpc_old   = data_cc$rgovc      / (data_cc$pop * data_cc$gdpdef)
  data_cc$rgdppc_old    = data_cc$rgdp       / (data_cc$pop * data_cc$gdpdef)
  data_cc$rtax          = data_cc$tax        / data_cc$gdpdef
  data_cc$rtaxpc        = data_cc$tax        / (data_cc$gdpdef * data_cc$pop)
  
  # add LMIs
  data_cc$ud         = rep(unlist(ud[,toupper(cntry)]),     each=4)
  data_cc$brr        = rep(unlist(brr[,toupper(cntry)]),    each=4)
  data_cc$epl        = rep(unlist(epl[,toupper(cntry)]),    each=4)
  
  # transform to time series object
  data_cc = ts(data_cc[,2:ncol(data_cc)], start=c(1960,1), frequency=4)
  
  # apply hamilton filter for Gordon-Krenn transformation
  for(var in c("rgovc","rgovcpc","rgdp","rgdppc","emprate","rwage")){
    tmp_ts = data_cc[,var]
    idx_na = which(!is.na(tmp_ts))
    tmp_ts = ts(log(tmp_ts[idx_na]), start=time(tmp_ts)[idx_na[1]], frequency=4)
    tmp_ts = hamilton_filter(tmp_ts)@decomp[,"Rest"] * 100
    data_cc = ts.union(data_cc,tmp_ts)
    colnames(data_cc)[ncol(data_cc)] = paste0(var,"_ht")
    colnames(data_cc) = str_remove(colnames(data_cc),"data_cc\\.")
  }
  
  # safe in list
  data[[cntry]] <- data_cc
}
rm(data_cc, cN, N, brr, epl, ud, cc, cntry, idx_emp, idx_emp_indu, idx_hours, idx_na, idx_pop, tmp_ts, var)

save(data, file="./empirics/data_for_estimation.rda")