cap log close
set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/flows-2017-01-10/
cd `destdir'
log using `reportdir'flows-2017-01-10.log, append

use `destdir'patents_by_region.dta, clear

eststo clear
set more off
xtset regionid year

/* Trial 1: Failed to converge */
xtnbreg cit_recd_total cit_made_localinternal cit_made_localexternal ///
		cit_made_nonlocalinternal cit_made_nonlocalexternal  cit_made_other ///
		lnpatents lnpool d2002-d2012 ///
		if (!missing(mean_patent_rate12) & mean_patent_rate12 > 200)
eststo
esttab using `reportdir'eflowsregt01.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{eflowsreg}") ///
		indicate("Year Dummy = d20*")  ///
		label longtable replace
// This regressions runs into > 500 iterations. While it does finally converge, I chose to kill it without completing

xtnbreg cit_recd_total cit_made_localinternal cit_made_localexternal /// 
		cit_made_nonlocalinternal cit_made_nonlocalexternal cit_made_other ///
		lnpatents lnpool  d2002-d2012  ///
		if (!missing(mean_patent_rate12) & mean_patent_rate12 > 200), i(regionid) fe

eststo
esttab using `reportdir'eflowsregt01.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{eflowsreg}") ///
		indicate("Year Dummy = d20*" "Region Fixed Effects = *region*")  ///
		label longtable replace
// The above regression ran several hours and did not converge. The most recent time I killed it after 19 iterations
log close
/* -----------------------------------------------------------------------*/


/* Trial 2 (patents instead of lnpatents): The model with fixed effects failed to converge */
cap log close
eststo clear
set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/flows-2017-01-10/
cd `destdir'
log using `reportdir'flows-2017-01-10.log, append

xtnbreg cit_recd_total cit_made_localinternal cit_made_localexternal ///
		cit_made_nonlocalinternal cit_made_nonlocalexternal  cit_made_other ///
		patents lnpool d2002-d2012 ///
		if (!missing(mean_patent_rate12) & mean_patent_rate12 > 200)
eststo
esttab using `reportdir'eflowsregt02.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{eflowsreg}") ///
		indicate("Year Dummy = d20*")  ///
		label longtable replace
		
xtnbreg cit_recd_total cit_made_localinternal cit_made_localexternal /// 
		cit_made_nonlocalinternal cit_made_nonlocalexternal cit_made_other ///
		lnpatents lnpool  d2002-d2012  ///
		if (!missing(mean_patent_rate12) & mean_patent_rate12 > 200), i(regionid) fe
// The above regression did not converge after 79 iterations, and was killed	
eststo
esttab using `reportdir'eflowsregt02.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{eflowsreg}") ///
		indicate("Year Dummy = d20*" "Region Fixed Effects = *region*")  ///
		label longtable replace
// The above regression did not converge even after 43 iterations. Killed it
log close
/* -----------------------------------------------------------------------*/

/* Trial 3 (log of all independent and control variables): We have some results */
cap log close
set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/flows-2017-01-10/
cd `destdir'
log using `reportdir'flows-2017-01-10.log, append

use `destdir'patents_by_region.dta, clear
eststo clear
xtset regionid year

xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal ///
		lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other ///
		lnpatents lnpool d2002-d2012 ///
		if (!missing(mean_patent_rate12) & mean_patent_rate12 > 200)
eststo
local reportdir /Users/aiyenggar/OneDrive/code/articles/flows-2017-01-10/
estadd local fixed "No" , replace
esttab using `reportdir'eflowsregt03.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{eflowsreg}") ///
		indicate("Year Dummy = d20*") s(fixed N, label("Region Fixed effects")) ///
		label longtable replace
		
xtnbreg cit_recd_total lncit_made_localinternal lncit_made_localexternal ///
		lncit_made_nonlocalinternal lncit_made_nonlocalexternal  lncit_made_other ///
		lnpatents lnpool d2002-d2012 ///
		if (!missing(mean_patent_rate12) & mean_patent_rate12 > 200), i(regionid) fe 
eststo
estadd local fixed "Yes" , replace
esttab using `reportdir'eflowsregt03.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{eflowsreg}") ///
		indicate("Year Dummy = d20*")  s(fixed N, label("Region Fixed effects")) ///
		label longtable replace		
log close
/* -----------------------------------------------------------------------*/







/* Template for Trial */
/* Start Below */
/* Trial ? (?): ? */
cap log close
eststo clear
set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/flows-2017-01-10/
cd `destdir'
log using `reportdir'flows-2017-01-10.log, append


log close
/* -----------------------------------------------------------------------*/
/* End Above */
