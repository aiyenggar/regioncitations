/* This file has the code to generate regression results for trials and experiments */

local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/
eststo clear
cd `reportdir'
local geosample "ua2"
local calcsample "False"

local inputprefix "20190306-`geosample'"
local distest "CalcDist`calcsample'"
local legendsample " (Mapping: `geosample', Distance Calculation: `calcsample')"
local sourcefile `destdir'`inputprefix'-`distest'-urbanarea-year-estimation.dta

use `sourcefile', clear
keep if citation_type==100
xtset uaid year
local yearmin = 1976
local dyearstart = `yearmin'+1
local yearmax = 2013


gen fq4and5 = fq4 + fq5
gen rcit_made_fq4and5=fq4and5/cit_made_total
label variable rcit_made_fq4and5 "Share Citations Made[Different Urban Area, Different Assignee and Other]"

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local SampleLocation "All Locations"
estadd local SamplePeriod "`yearmin'-`yearmax'"
estadd local SampleCitations "All Citations"
est store model1

corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_fq4and5 lncit_made_total lnpatents lnpool if e(sample) == 1, file(`reportdir'`inputprefix'-`distest'-correlation.tex) digits(2) no key(`inputprefix'-`distest'-correlation) title("Correlations and Summary Statistics (Sample:`inputprefix'-`distest')") replace  
sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  rcit_made_fq4and5 lncit_made_total lnpatents lnpool if e(sample) == 1, file(`reportdir'`inputprefix'-`distest'-summary.tex) labels key(`inputprefix'-`distest'-summary) title("Summary Statistics (Sample:`inputprefix'-`distest')") replace 

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country=="US"), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local SampleLocation "U.S. Locations"
estadd local SamplePeriod "`yearmin'-`yearmax'"
estadd local SampleCitations "All Citations"
est store model2

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country!="US"), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local SampleLocation "Non-U.S. Locations"
estadd local SamplePeriod "`yearmin'-`yearmax'"
estadd local SampleCitations "All Citations"
est store model3

xtnbreg cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local SampleLocation "All Locations"
estadd local SamplePeriod "`yearmin'-`yearmax'"
estadd local SampleCitations "All Citations"
est store model4

use `sourcefile', clear
keep if citation_type==2
xtset uaid year
local yearmin = 2001
local dyearstart = `yearmin'+1
local yearmax = 2013

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local SampleLocation "All Locations"
estadd local SamplePeriod "`yearmin'-`yearmax'"
estadd local SampleCitations "Applicant Citations"
est store model5

use `sourcefile', clear
keep if citation_type==3
xtset uaid year
local yearmin = 2001
local dyearstart = `yearmin'+1
local yearmax = 2013

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local SampleLocation "All Locations"
estadd local SamplePeriod "`yearmin'-`yearmax'"
estadd local SampleCitations "Examiner Citations"
est store model6

esttab model1 model2 model3 model4 model5 model6  using `reportdir'`inputprefix'-`distest'-model.tex, ///
		title("Negative Binomial Regression Analysis of Invention Quality \label{`inputprefix'-`distest'-model}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "SampleLocation" "SamplePeriod" "SampleCitations") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
