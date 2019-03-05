local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/

use `destdir'20190305-M-03-urbanarea-year-estimation.dta, clear
keep if citation_type==100 & country=="US"
eststo clear
xtset uaid year
cd `reportdir'

local modelprefix "M-03"
local yearmin = 2001
local dyearstart = `yearmin'+1
local yearmax = 2013

// DV is Total Citations Received
local submodelprefix "Total"
xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-correlation.tex) digits(2) no key(`modelprefix'-`submodelprefix'-correlation) title("`modelprefix' Correlations and Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace  
sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal    lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-summary.tex) labels key(`modelprefix'-`submodelprefix'-summary) title("`modelprefix' Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace 

// DV is Non-Self Citations Received
local submodelprefix "NonSelf"
xtnbreg cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-correlation.tex) digits(2) no key(`modelprefix'-`submodelprefix'-correlation) title("`modelprefix' Correlations and Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace
sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(`modelprefix'-`submodelprefix'-summary.tex) labels key(`modelprefix'-`submodelprefix'-summary) title("`modelprefix' Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace 

esttab model1 model19  using `reportdir'`modelprefix'-model-1-19.tex, ///
		title("`modelprefix' Negative binomial regresssion analysis of invention quality for all citations \label{`modelprefix'-model-1-19}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
