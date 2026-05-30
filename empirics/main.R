#-----------------------------------------------------------------------------#
# Labor Market Institutions, Fiscal Multiplier, and Macroeconomic Volatility  #
#                                                                             #
# This Script: Execute this script to replicate all results                   #
#                                                                             #
# Maximilian Boeck, maximilian.boeck@wu.ac.at                                 #
# May 2026                                                                    
#-----------------------------------------------------------------------------#
rm(list=ls())

# set the working directory to ./replication-files
# this directory should contain three folders:
#         i)   data
#         ii)  dsge
#         iii) empirics
# THIS HAS TO BE ADJUSTED ON YOUR LOCAL LAPTOP
# setwd("../replication-files/") 

# generate dataset
source("./empirics/create_dataset.R")

# specify settings:
#               - baseline:                    rgovcpc, rgdppc, emprate, rwage
#               - unrate:                      rgovcpc, rgdppc, unrate,  rwage
#               - vu:                          rgovcpc, rgdppc, vu,      rwage
#               - baselineshort:               rgovcpc, rgdppc, emprate, rwage  (sample defined by availability of govf)
#               - unrateshort:                 rgovcpc, rgdppc, unrate,  rwage  (sample defined by availability of govf)
#               - baselineforesight:           rgovcpc, rgdppc, emprate, rwage  (endo), govf (exo)
#               - baselinefe         rgovc_fe, rgovcpc, rgdppc, emprate, rwage
#               - baselinefcst       govf,     rgovcpc, rgdppc, emprate, rwage # try this one first
# ordering of ivars: ud-brr-epl

# run baseline model
varspec          = "baseline"
intspec          = "multi"
prior            = "ng"
plag             = 1
compute_irf_grid = TRUE
compute_var_grid = TRUE
source("./empirics/estimate_ipvar.R")

# robustness: model specification and sample
compute_var_grid = FALSE
plag             = 2
source("./empirics/estimate_ipvar.R")
plag             = 4
source("./empirics/estimate_ipvar.R")
plag             = 1
varspec          = "baseline-ht"
source("./empirics/estimate_ipvar.R")
varspec          = "baseline-g7"
source("./empirics/estimate_ipvar.R")
varspec          = "baseline-level"
source("./empirics/estimate_ipvar.R")

# robustness: controlling for fiscal foresight
varspec          = "baseline-g7-shortoecd"
source("./empirics/estimate_ipvar.R")
varspec          = "baseline-g7-shortoxf"
source("./empirics/estimate_ipvar.R")
varspec          = "baseline-g7-oecdfcst"
source("./empirics/estimate_ipvar.R")
varspec          = "baseline-g7-oecdfcst2"
source("./empirics/estimate_ipvar.R")
varspec          = "baseline-g7-oxffcst2"
source("./empirics/estimate_ipvar.R")
intspec          = "ud-brr"
varspec          = "baseline-g7-oecdfcst2"
source("./empirics/estimate_ipvar.R")
intspec          = "ud-brr"
varspec          = "baseline-g7-oxffcst2"
source("./empirics/estimate_ipvar.R")

# other labor market indicators: unemployment rate and labor-market-tightness
intspec  = "multi"
varspec  = "unrate"
compute_var_grid = TRUE
source("./empirics/estimate_ipvar.R")
compute_var_grid = FALSE
varspec  = "vu-addemprate"
source("./empirics/estimate_ipvar.R")

# assess group heterogeneity
varspec  = "baseline-conslow"
source("./empirics/estimate_ipvar.R")
varspec  = "baseline-conshigh"
source("./empirics/estimate_ipvar.R")
varspec  = "baseline-lmilow"
source("./empirics/estimate_ipvar.R")
varspec  = "baseline-lmihigh"
source("./empirics/estimate_ipvar.R")

# generate figures
source("./empirics/figure1.R")
source("./empirics/figure3.R")
source("./empirics/figure4.R")
source("./empirics/figure5.R")
source("./empirics/figure6.R")
source("./empirics/figureD1.R")
source("./empirics/figureE1.R")
source("./empirics/figureE2.R")
source("./empirics/figureE3.R")
source("./empirics/figureE4.R")
source("./empirics/figureE5a.R")
source("./empirics/figureE5b.R")
source("./empirics/figureE6.R")
source("./empirics/figureE7.R")
