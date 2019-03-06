/* This file has the code to generate regression results for papers sent out 2019 and later*/

/*
One table with:
Model 1: DV - All Citations Received. All Locations. All Time (1976 onward). All Citations.
Model 2: DV - All Citations Received. U.S. Locations. All Time (1976 onward). All Citations.
Model 3: DV - All Citations Received. Non-U.S. Locations. All Time (1976 onward). All Citations.
Model 4: DV - Nonself Citations Received. All Locations. All Time (1976 onward). All Citations.
Model 5: DV - All Citations Received. All Locations. 2001-2013. Applicant Citations.
Model 6: DV - All Citations Received. All Locations. 2001-2013. Examiner Citations.
*/

local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/
eststo clear
cd `reportdir'
local modelprefix "M-03-Consolidated"

use `destdir'20190305-M-03-urbanarea-year-estimation.dta, clear
keep if citation_type==100
xtset uaid year
local yearmin = 1976
local dyearstart = `yearmin'+1
local yearmax = 2013

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local SampleLocation "All Locations"
estadd local SamplePeriod "`yearmin'-`yearmax'"
estadd local SampleCitations "All Citations"
est store model1

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

use `destdir'20190305-M-03-urbanarea-year-estimation.dta, clear
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

use `destdir'20190305-M-03-urbanarea-year-estimation.dta, clear
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

esttab model1 model2 model3 model4 model5 model6  using `reportdir'`modelprefix'-model.tex, ///
		title("Negative Binomial Regresssion Analysis of Invention Quality \label{`modelprefix'-model}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "SampleLocation" "SamplePeriod" "SampleCitations") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
