# replication-employment-multiplier


Replication files for Boeck, M., Crespo Cuaresma, J., and Glocker, C. (2026)
=======
Replication files for Boeck, M., Crespo Cuaresma, J., and Glocker, C. (2026) *Labor Market Institutions, Fiscal Multipliers, and Macroeconomic Volatility*, Journal of Applied Econometrics, forthcoming.

This replication files reproduce all figures visible in the paper. The figures constructed from the theoretical analysis are reprocued by running */dsge/main.m*. The figures constructed from the empirical analysis are reproduced by running *empirics/main.R*.

Bayesian estimations are based on 25.000 MCMC draws where the first 5.000 are discarded. Hence, the script takes a considerable amount of time to run through. The number of saved draws (*draws*) and discarded draws (*burnins*) can be adapted by the user. The script then reproduces the following

- Figures from /dsge/main.m:
  + Figure 2: Fiscal Spending Multipliers and the LMIs.
  + Figure A1: Fiscal Spending Shocks and the LMIs.
  + Figure B1: Fiscal spending elasticities and the LMIs - no inflation indexation of prices.
  + Figure B2: Fiscal spending elasticities and the LMIs - real wage rigidity.
  + Figure B3: Fiscal spending elasticities and the LMIs - limited asset market participation.
  + Figure B4: Fiscal spending elasticities and the LMIs - firing costs accrue to the government.
  + Figure B5: Fiscal spending elasticities and the LMIs - productivity enhancing government spending.
  + Figure B6: Fiscal spending elasticities and the LMIs - consumption/leisure complementarity.
  
- Figures from /empirics/main.R
  + Figure 1: Labor market institutions in OECD economies: cross-country variation.
  + Figure 3: Fiscal multipliers along LMIs.
  + Figure 4: Forecast error variance decomposition.
  + Figure 5: Macroeconomic volatilities along LMIs.
  + Figure 6: Changes in macroeconomic volatilities along LMIs.
  + Figure D1: Labor market institutions in OECD economies: time variation.
  + Figure E1: Dynamic effects of government spending shocks.
  + Figure E2: Robustness: model specification and sample.
  + Figure E3: Controlling for fiscal foresight.
  + Figure E4: Fiscal multipliers using other labor market indicators.
  + Figure E5: Volatility outcomes using other labor market indicators: unemployment rate.
  + Figure E6: Classification of countries.
  + Figure E7: Cross-country heterogeneity analysis.

**Abstract** How do labor market institutions shape the transmission of government spending shocks and macroeconomic volatility? We develop a theoretical model in which labor market institutions affect fiscal transmission through their effect on wage rigidity, job separation, and matching frictions. We estimate an interacted panel vector autoregressive model for 16 OECD economies and study how macroeconomic responses to government spending shocks vary with institutional labor market characteristics. In line with our theoretical predictions, we show that institutions that stabilize employment and wages tend to dampen output volatility and attenuate the response of output and employment to government spending shocks.

**Links** [(Latest Version May 2026)](https://mboeck11.github.io/papers/BCCG2026JAE.pdf)
