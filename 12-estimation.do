/* This file has the code to generate regression results as was used in papers sent out till 2018 */

local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/
local yearmin = 2001
local dyearstart = `yearmin'+1
local yearmax = 2013

use `destdir'20190305-M-03-urbanarea-year-estimation.dta, clear

local modelprefix "M-03-All-Citations-`yearmin'-`yearmax'"
keep if citation_type==100
local citation_type_desc "All Citations (Applicant, Examiner and Other Citations)"

/*
local modelprefix "M-03-All-Citations-`yearmin'-`yearmax'"
keep if citation_type==100
local citation_type_desc "All Citations (Applicant, Examiner and Other Citations)"

local modelprefix "M-03-Applicant-Citations-`yearmin'-`yearmax'"
keep if citation_type==2
local citation_type_desc "Applicant Citations"

local modelprefix "M-03-Examiner-Citations-`yearmin'-`yearmax'"
keep if citation_type==3
local citation_type_desc "Examiner Citations"
*/

eststo clear
xtset uaid year
cd `reportdir'

// DV is Total Citations Received
local submodelprefix "Total"
xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-correlation.tex) digits(2) no key(`modelprefix'-`submodelprefix'-correlation) title("Correlations and Summary Statistics for the Sample of `citation_type_desc'") replace  
sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-summary.tex) labels key(`modelprefix'-`submodelprefix'-summary) title("Summary Statistics for the Sample of `citation_type_desc'") replace 

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country=="US"), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country!="US"), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3

// DV is Non-Self Citations Received
local submodelprefix "NonSelf"
xtnbreg cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other  lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model4

corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-correlation.tex) digits(2) no key(`modelprefix'-`submodelprefix'-correlation) title("Correlations and Summary Statistics for the Sample of `citation_type_desc'") replace  
sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-summary.tex) labels key(`modelprefix'-`submodelprefix'-summary) title("Summary Statistics for the Sample of `citation_type_desc'") replace 

xtnbreg cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other  lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country=="US"), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model5

xtnbreg cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other  lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country!="US"), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model6

esttab model1 model2 model3 model4 model5 model6  using `reportdir'`modelprefix'-model.tex, ///
		title("Negative Binomial Regresssion Analysis of Invention Quality for Sample of `citation_type_desc'\label{`modelprefix'-model}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
