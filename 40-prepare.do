set more off
local destdir /Users/aiyenggar/processed/patents/
cd `destdir'

//local inputprefix "20190314-ua1"
//local inputprefix "20190314-ua2"
local inputprefix "20190314-ua3"
local distest "dis"
//local distest "nod"

import delimited `destdir'`inputprefix'-`distest'-dependent-variable.csv, varnames(1) encoding(UTF-8) clear
label variable cit_recd_total "[ua-year] total citations received"
label variable cit_recd_self "[ua-year] self citations received"
label variable cit_recd_nonself "[ua-year] nonself citations received"
save `destdir'`inputprefix'-`distest'-pure_citations_received.dta, replace

import delimited `destdir'`inputprefix'-`distest'-forward_citations.csv, varnames(1) encoding(UTF-8) clear
label variable citation_type "1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party, 100 All"
sort uaid year
label variable fq1 "[ua-year-citationtype] ua(same) assg(same) forward citations"
label variable fq2 "[ua-year-citationtype] ua(same) assg(diff) forward citations"
label variable fq3 "[ua-year-citationtype] ua(diff) assg(diff) forward citations"
label variable fq4 "[ua-year-citationtype] ua(diff) assg(same) forward citations"
label variable fq5 "[ua-year-citationtype] other (undeterminable) forward citations"
save `destdir'`inputprefix'-`distest'-forward_citations.dta, replace

collapse (sum) sfq1=fq1 sfq2=fq2 sfq3=fq3 sfq4=fq4 sfq5=fq5, by(uaid year)
gen citation_type = 100
save `destdir'temp_collapsed_forward.dta, replace

use `destdir'`inputprefix'-`distest'-forward_citations.dta, clear
merge 1:1 uaid year citation_type using `destdir'temp_collapsed_forward.dta
replace fq1 = sfq1 if _merge == 2
replace fq2 = sfq2 if _merge == 2
replace fq3 = sfq3 if _merge == 2
replace fq4 = sfq4 if _merge == 2
replace fq5 = sfq5 if _merge == 2
sort uaid year citation_type
drop sf* _merge
merge m:1 uaid year using `destdir'`inputprefix'-`distest'-pure_citations_received.dta, keep(match master) nogen
merge m:1 uaid using `destdir'uaid.dta, keep(match master) nogen
drop population areakm
sort urban_area year
order year urban_area uaid *recd*
save `destdir'`inputprefix'-`distest'-ua_year_citations.dta, replace

merge m:1 uaid year using `destdir'`inputprefix'-ua_year_patents.dta, keep(match master) nogen
order year urban_area uaid techclass* pat_cnt pat_pool inv_cnt avg_ua_share fq*

label variable cit_recd_total "Total Citations Received"
label variable cit_recd_self "Self Citations Received"
label variable cit_recd_nonself "Non-Self Citations Received"

/* Generating variables that will be used in the estimation */

gen lnpatents = ln(pat_cnt)
label variable lnpatents "Log (Number of Patents)"
gen lnpool = ln(1 + pat_pool)
label variable lnpool "Log (Patent Pool Size)"
gen cit_made_total=fq1+fq2+fq3+fq4+fq5
label variable cit_made_total "Total Citation Flows"
gen lncit_made_total=ln(1 + cit_made_total)
label variable lncit_made_total "Log (Total Citation Flows)"


gen rcit_made_localinternal=fq1/cit_made_total
label variable rcit_made_localinternal "Share Citations Made[Same Urban Area, Same Assignee]"
gen rcit_made_localexternal=fq2/cit_made_total
label variable rcit_made_localexternal "Share Citations Made[Same Urban Area, Different Assignee]"
gen rcit_made_nonlocalinternal=fq4/cit_made_total
label variable rcit_made_nonlocalinternal "Share Citations Made[Different Urban Area, Same Assignee]"
gen rcit_made_nonlocalexternal=fq3/cit_made_total
label variable rcit_made_nonlocalexternal "Share Citations Made[Different Urban Area, Different Assignee]"
gen rcit_made_other=fq5/cit_made_total
label variable rcit_made_other "Share Citations Made[Other]"

/* generate year dummies */
levels year, local(levelyear)
foreach ly of local levelyear {
	gen d`ly'=1 if year==`ly'
	replace d`ly'=0 if missing(d`ly')
}
/* done generating year dummies */

order year urban_area uaid country techclass* citation_type *recd* *made* lnpatents lnpool d* percent*
save `destdir'`inputprefix'-`distest'-urbanarea-year-estimation.dta, replace