/* This file has the code to generate regression results for papers sent out 2019 and later*/

local samplestartyear = 1990
local sampleendyear = 2013
local citationcategorystartyear = 2001
local allcitationscategory = 100
local applicantcitationscategory = 2
local examinercitationscategory = 3
local quintile_levels 5
local geosample "ua3"
local calcsample "True"
local inputprefix "20190314-`geosample'"
local distest "CalcDist`calcsample'"
local legendsample " (Mapping: `geosample', Distance Calculation: `calcsample')"
local fileprefix = "`inputprefix'-`distest'"
local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/
local sourcefile `destdir'`fileprefix'-urbanarea-year-estimation.dta
local mid=13
local mlist=""
est drop _all

use `sourcefile', clear
keep if citation_type==`allcitationscategory'
xtset uaid year
local yearmin = `samplestartyear'
local dyearstart = `yearmin'+1
local yearmax = `sampleendyear'

/* Generate interaction variables */
gen div=techclass_diversity
gen divsq=div*div
gen intq1=rcit_made_localinternal * div
label variable intq1 "1 x Technology Diversification"
gen sqintq1=rcit_made_localinternal * divsq
label variable sqintq1 "1 x sq(Technology Diversification)"
gen intq2=rcit_made_localexternal * div
label variable intq2 "2 x Technology Diversification"
gen sqintq2=rcit_made_localexternal * divsq
label variable sqintq2 "2 x sq(Technology Diversification)"
gen intq4=rcit_made_nonlocalinternal * div
label variable intq4 "3 x Technology Diversification"
gen sqintq4=rcit_made_nonlocalinternal * divsq
label variable sqintq4 "3 x sq(Technology Diversification)"
gen intq5=rcit_made_other * div
label variable intq5 "4 x Technology Diversification"
gen sqintq5=rcit_made_other * divsq
label variable sqintq5 "4 x sq(Technology Diversification)"
/* Completed generating variables */

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Locations "All"
estadd local PeriodStart `yearmin'
estadd local PeriodEnd `yearmax'
estadd local Citations "All"
local modelname = "Model`mid'"
local mid=`mid'+1
est store `modelname'
local mlist="`mlist' `modelname'"
local myfileprefix = "`fileprefix'-`modelname'"

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other intq1 intq2 intq4 intq5 lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Locations "All"
estadd local PeriodStart `yearmin'
estadd local PeriodEnd `yearmax'
estadd local Citations "All"
local modelname = "Model`mid'"
local mid=`mid'+1
est store `modelname'
local mlist="`mlist' `modelname'"
local myfileprefix = "`fileprefix'-`modelname'"

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other intq1 intq2 intq4 intq5 sqintq1 sqintq2 sqintq4 sqintq5 lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Locations "All"
estadd local PeriodStart `yearmin'
estadd local PeriodEnd `yearmax'
estadd local Citations "All"
local modelname = "Model`mid'"
local mid=`mid'+1
est store `modelname'
local mlist="`mlist' `modelname'"
local myfileprefix = "`fileprefix'-`modelname'"

esttab `mlist' using temp.tex, ///
		title("Negative Binomial Regression Analysis of Invention Quality \label{`fileprefix'-model}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Locations" "Citations" "PeriodStart" "PeriodEnd") addnotes("Reference category is Share Citations Made[Different Urban Area, Different Assignee]" "All models include region fixed effects, year dummies and technology subcategory controls")
filefilter temp.tex `reportdir'`fileprefix'-interactions-model.tex, from("{table}") to("{sidewaystable}") replace
