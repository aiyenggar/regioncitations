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
*/
foreach var of varlist cat* subcat* {
  gen percent`var' = (100*`var')/patents
}


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
gen rcit_made_localinternal=cit_made_localinternal/cit_made_total
gen rcit_made_localexternal=cit_made_localexternal/cit_made_total
gen rcit_made_nonlocalinternal=cit_made_nonlocalinternal/cit_made_total
gen rcit_made_nonlocalexternal=cit_made_nonlocalexternal/cit_made_total
gen rcit_made_other=cit_made_other/cit_made_total
gen lncit_made_total=ln(cit_made_total)
gen avg_cit_recd=cit_recd_total/cit_made_total

gen pool2001=pool if year==2001
replace pool2001=0 if missing(pool2001)
bysort region: egen sumpool2001=sum(pool2001)

local cutoff 50	
reg lncit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff')
matrix _s=e(b)	
local icat=1

local cutoff 50	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe from(_s, skip)


reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & sumpool > 300)
matrix _s=e(b)	
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & sumpool > 300), i(regionid) fe from(_s, skip)
