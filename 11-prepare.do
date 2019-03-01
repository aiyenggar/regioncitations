set more off
local destdir /Users/aiyenggar/processed/patents/
cd `destdir'

import delimited `destdir'backward_citations.csv, varnames(1) encoding(UTF-8) clear
sort ua year
label variable bq1 "[ua-year] ua(same) assg(same) backward citations"
label variable bq2 "[ua-year] ua(same) assg(diff) backward citations"
label variable bq3 "[ua-year] ua(diff) assg(diff) backward citations"
label variable bq4 "[ua-year] ua(diff) assg(same) backward citations"
label variable bq5 "[ua-year] other (undeterminable) backward citations"
save `destdir'backward_citations.dta, replace

import delimited `destdir'forward_citations.csv, varnames(1) encoding(UTF-8) clear
sort ua year
label variable fq1 "[ua-year] ua(same) assg(same) forward citations"
label variable fq2 "[ua-year] ua(same) assg(diff) forward citations"
label variable fq3 "[ua-year] ua(diff) assg(diff) forward citations"
label variable fq4 "[ua-year] ua(diff) assg(same) forward citations"
label variable fq5 "[ua-year] other (undeterminable) forward citations"
save `destdir'forward_citations.dta, replace

merge 1:1 ua year using `destdir'backward_citations.dta, nogen
rename ua uaid
merge m:1 uaid using `destdir'uaid.dta, keep(match master) nogen
drop population areakm
sort urban_area year
order year urban_area uaid
save `destdir'ua_year_citations.dta, replace

rename uaid ua
merge 1:1 ua year using `destdir'ua_year_patents.dta, nogen
rename ua uaid
order year urban_area uaid pat_cnt pat_pool inv_cnt avg_ua_share fq* bq*

/* Generating variables that will be used in the estimation */

gen lnpatents = ln(pat_cnt)
label variable lnpatents "Log (Number of Patents)"
gen lnpool = ln(1 + pat_pool)
label variable lnpool "Log (Patent Pool Size)"
gen cit_made_total=fq1+fq2+fq3+fq4+fq5
label variable cit_made_total "Total Citations Made"
gen lncit_made_total=ln(1 + cit_made_total)
label variable lncit_made_total "Log (Total Citations Made)"

/* Dependent Variables */
gen cit_recd_total=bq1+bq2+bq3+bq4+bq5
label variable cit_recd_total "Total Citations Received"
gen cit_recd_nonself = bq3 + bq4 + bq5
label variable cit_recd_nonself "Non-Self Citations Received"
/* End Dependent Variables */

gen rcit_made_localinternal=fq1/cit_made_total
label variable rcit_made_localinternal "Share Citations Made[Same Urban Area, Same Assignee]"
gen rcit_made_localexternal=fq2/cit_made_total
label variable rcit_made_localexternal "Share Citations Made[Same Urban Area, Different Assignee]"
gen rcit_made_nonlocalinternal=fq4/cit_made_total
label variable rcit_made_nonlocalinternal "Share Citations Made[Different Urban Area, Same Assignee]"
gen rcit_made_nonlocalexternal=fq3/cit_made_total
label variable rcit_made_nonlocalexternal "Share Citations Made[Different Urban Area, Different Assignee]"

/* generate year dummies */
levels year, local(levelyear)
foreach ly of local levelyear {
	gen d`ly'=1 if year==`ly'
	replace d`ly'=0 if missing(d`ly')
}
/* done generating year dummies */

foreach var of varlist cat* subcat* {
  gen percent`var' = (100*`var')/pat_cnt
}

order year urban_area uaid *recd* *made* lnpatents lnpool d1* d2* percent*
local now : display %tdCYND daily("$S_DATE", "DMY")
local model "M-01" /* M-01	GEOBOUND-NEAREST	DISTEST-OFF	FLOWCNT-ACCUMULATE	FLOWCAT-ALL */
save `destdir'`now'-`model'-urbanarea-year-estimation.dta
