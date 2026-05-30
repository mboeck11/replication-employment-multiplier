{\rtf1\ansi\ansicpg1252\cocoartf2868
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fswiss\fcharset0 Helvetica-Bold;\f2\fswiss\fcharset0 Helvetica-Oblique;
}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww22420\viewh13220\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 README\
\
Documentation for data for the article \'84Labor Market Institutions, Fiscal Multipliers, and Macroeconomic Volatility\'93 by Maximilian Boeck, Jesus Crespo Cuaresma, and Christian Glocker. In this text document, we describe the data sources involved.\
\

\f1\b Labor market institutions data:
\f0\b0 \

\f2\i data_LMI.xlsx
\f0\i0  organized in three sheets each containing yearly time series for 16 countries (plus one info sheet)\
	- UD: trade union density coming from the OECD and Macrobond\
	- BRR: average gross unemployment benefit replacement rates from the OECD\
	- EPL: employment protection from the OECD and Macrobond\
\
Sample: 61 observations, ranging from 1960 to 2020 (rows)\
Country coverage: 16 countries (cols): Australia (AUS), Austria (AUT), Belgium (BEL), Canada (CAN), Germany (DEU), Denmark (DNK), Spain (ESP), Finland (FIN), France (FRA), Great Britain (GBR), Italy (ITA), Japan (JPN), the Netherlands (NLD), Portugal (PRT), Sweden (SWE), United States (USA)\
\

\f1\b National Accounts data:
\f0\b0 \

\f2\i data_NatAcc.xlsx
\f0\i0  organized in 16 sheets each containing quarterly time series for 16 variables for one country (plus one info sheet); naming of the variables are GEO_VAR where GEO refers to one of the country codes and VAR to a variable name\
	- GEO_rgovc: general government final consumption expenditure, constant prices, seasonally adjusted, national currency (in millions) from OECD (NAQ)\
	- GEO_ue: harmonised unemployment, persons (in thousands), seasonally adjusted from OECD (MEI)\
	- GEO_emp: total employment, employees, persons (in thousands), seasonally adjusted from OECD (NAQ)\
	- GEO_emp_indu: manufacturing employment, employees, persons (in thousands), seasonally adjusted from OECD (NAQ)\
	- GEO_va_indu: gross value added at basic prices, manufacturing, constant prices, seasonally adjusted, national currency (in millions) from OECD (NAQ)\
	- GEO_rgdp: real gross domestic product, constant prices, seasonally adjusted, national currency (in millions) from OECD (NAQ)\
	- GEO_gdpdef: gross domestic product deflator, seasonally adjusted, index from OECD (NAQ)\
	- GEO_wages: wages & salaries, current prices, seasonally adjusted, national currency (in millions) from OECD (NAQ)\
	- GEO_wages_indu: manufacturing wages & salaries, current prices, national currency (in millions) from OECD (NAQ)\
	- GEO_pop: total population, persons (in thousands), seasonally adjusted from OECD (NAQ)\
	- GEO_hours: total hours worked (in millions) from OECD (NAQ)\
	- GEO_vac: vacancies from OECD (MEI)\
	- GEO_int: shot-term interest rate\
	- GEO_tax: tax revenues from OECD\
	- GEO_oxf_govf: government consumption forecast, one quarter ahead from Oxford Economics (only G7 countries: CAN, FRA, DEU, GBR, ITA, JPN, USA and only from 1999 to 2020)\
	- GEO_oecd_govf: government consumption forecast, one quarter ahead from OECD Economic Outlook, interpolated from a semi-annual series (only G7 countries: CAN, FRA, DEU, GBR, ITA, JPN, USA and only from 1985 to 2020)\
\
GEO: Australia (AUS), Austria (AUT), Belgium (BEL), Canada (CAN), Germany (DEU), Denmark (DNK), Spain (ESP), Finland (FIN), France (FRA), Great Britain (GBR), Italy (ITA), Japan (JPN), the Netherlands (NLD), Portugal (PRT), Sweden (SWE), United States (USA)\
Sample: 244 observations, ranging from 1960Q1 to 2020Q4}