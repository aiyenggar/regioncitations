/* OLS and xtnbreg on all data */
cap log close
set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/citations-20170114/

cd `destdir'
log using `reportdir'flows-2017-01-10.log, append
use `destdir'patents_by_region.dta, clear

eststo clear
xtset regionid year
reg lncit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 if (year>=2001 & year<=2012)
matrix _s=e(b)
eststo
estadd local fixed "OLS" , replace
outreg2 using  `reportdir'reg01.tex, title("Linear Regression\label{reg01}") ctitle("Log(Total Citations Received)") tex(pretty frag) label dec(4) replace
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 if (year>=2001 & year<=2012), i(regionid) fe from(_s, skip)
eststo
estadd local fixed "xtnbreg" , replace

local cutoff 50	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe
eststo
estadd local fixed "xtnbreg 50" , replace

local cutoff 100	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe
eststo
estadd local fixed "xtnbreg 100" , replace

		
local cutoff 200	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe
eststo
estadd local fixed "xtnbreg 200" , replace

esttab using `reportdir'xtnbreg01.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{xtnbreg01}") ///
		s(fixed N, label("Model")) ///
		label longtable replace
		//indicate("Year Dummy = d20*") 
		
log close
/* -----------------------------------------------------------------------*/


/* 17-Jan-2017 */
set more off
local destdir /Users/aiyenggar/datafiles/patents/
use `destdir'patents_by_region.dta, clear
/*
local icat=1
while `icat' <= 6 {
	gen percentcat`icat' = (100*cat`icat')/patents
	local icat= `icat' + 1
}
foreach var of varlist cat* subcat* {
  gen percent`var' = (100*`var')/patents
}

*/


eststo clear
xtset regionid year

local cutoff 50	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe
eststo
estadd local fixed "xtnbreg 50" , replace

/* With category dummies */
local cutoff 50	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 dcat1-dcat6 if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe
eststo
estadd local fixed "xtnbreg 50" , replace


local cutoff 50	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 percentcat1-percentcat6 if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe
eststo
estadd local fixed "xtnbreg 50" , replace

esttab using `reportdir'xtnbreg20170117.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{xtnbreg20170117}") ///
		s(fixed N, label("Model")) ///
		label longtable replace
		
/* non log */


local cutoff 50	
reg lncit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff')
matrix _s=e(b)	
local icat=1

local cutoff 50	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe from(_s, skip)


reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & sumpool > 300)
matrix _s=e(b)	
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & sumpool > 300), i(regionid) fe from(_s, skip)

/* 18-Jan-2017. We now have country dummies and region source */

local destdir /Users/aiyenggar/datafiles/patents/
use `destdir'patents_by_region.dta, clear
local reportdir /Users/aiyenggar/OneDrive/code/articles/citations-20170114/
eststo clear
xtset regionid year

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers"), i(regionid) fe
eststo model1
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid != 188), i(regionid) fe
eststo model2


gen intr_localinternal_ipr_score=rcit_made_localinternal*ipr_score
gen intr_localexternal_ipr_score=rcit_made_localexternal*ipr_score
gen intr_nonlocalinternal_ipr_score=rcit_made_nonlocalinternal*ipr_score
gen intr_nonlocalexternal_ipr_score=rcit_made_nonlocalexternal*ipr_score
label variable intr_localinternal_ipr_score "Share [Same Region, Same Assignee] * IPR"
label variable intr_localexternal_ipr_score "Share [Same Region, Different Assignee] * IPR"
label variable intr_nonlocalinternal_ipr_score "Share [Different Region, Same Assignee] * IPR"
label variable intr_nonlocalexternal_ipr_score "Share [Different Region, Different Assignee] * IPR"

//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_lnpatents intr_localexternal_lnpatents intr_nonlocalinternal_lnpatents intr_nonlocalexternal_lnpatents lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & !missing(rcit_made_localinternal) & !missing(rcit_made_localexternal) & !missing(rcit_made_nonlocalinternal) & !missing(rcit_made_nonlocalexternal))
//matrix _s=e(b)	
// from(_s, skip)
// & !missing(rcit_made_localinternal) & !missing(rcit_made_localexternal) & !missing(rcit_made_nonlocalinternal) & !missing(rcit_made_nonlocalexternal)
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers"), i(regionid) fe 
eststo model3

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid != 188), i(regionid) fe 
eststo model4
//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers")
//xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers"), i(regionid) fe from(_s, skip)
/* End Experiments */

esttab using `reportdir'xtnbreg20170118.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{xtnbreg20170118}") ///
		order(cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool ) ///
		label longtable replace wide p(3) se(3) not nostar
