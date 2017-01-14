/* OLS and xtnbreg on all data */
cap log close
set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/flows-2017-01-10/

cd `destdir'
log using `reportdir'flows-2017-01-10.log, append
use `destdir'patents_by_region.dta, clear

eststo clear
xtset regionid year
reg lncit_recd_total lncit_made_localinternal lncit_made_localexternal ///
		lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other ///
		lnpatents lnpool d2002-d2012 ///
		if (year>=2001 & year<=2012)
outreg2 using  `reportdir'reg01.tex, title("Linear Regression\label{reg01}") ctitle("Log(Total Citations Received)") tex(pretty frag) label dec(4) replace

local cutoff 50	
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other lnpatents lnpool d2002-d2012 if (year>=2001 & year<=2012 & mean_patent_rate12 > `cutoff'), i(regionid) fe
eststo
estadd local fixed "Yes" , replace
esttab using `reportdir'xtnbreg01.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{xtnbreg01}") ///
		s(fixed N, label("Region Fixed Effects")) ///
		label longtable replace	
		//indicate("Year Dummy = d20*") 
log close
/* -----------------------------------------------------------------------*/
