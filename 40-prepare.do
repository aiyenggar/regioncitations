set more off
global destdir ~/processed/patents/
local inputprefix "20190314-ua3"
local distest "dis"
local baseprefix "${destdir}`inputprefix'-"
local prefix "${destdir}`inputprefix'-`distest'-"

import delimited `prefix'predictor-variables.csv, varnames(1) encoding(UTF-8) clear
label variable citation_type "1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party, 100 All"
label variable countstyle "ALL - all flows UNIQ - flows between urban areas and assignees counted only once per citation"
label variable cit_made_total "Total Citation Flows"
gen lncit_made_total=ln(1 + cit_made_total)
label variable lncit_made_total "Log (Total Citation Flows)"

label variable q1 "[ua-year-citationtype-countstyle] ua(same) assg(same) citations made"
label variable q2 "[ua-year-citationtype-countstyle] ua(same) assg(diff) citations made"
rename q3 q4o
rename q4 q3
rename q4o q4
label variable q3 "[ua-year-citationtype-countstyle] ua(diff) assg(same) citations made"
label variable q4 "[ua-year-citationtype-countstyle] ua(diff) assg(diff) citations made"
label variable q5 "[ua-year-citationtype-countstyle] other (undeterminable) citations made"

gen rcit_made_localinternal=q1/cit_made_total
label variable rcit_made_localinternal "Share Citations Made[Same Urban Area, Same Assignee]"
gen rcit_made_localexternal=q2/cit_made_total
label variable rcit_made_localexternal "Share Citations Made[Same Urban Area, Different Assignee]"
gen rcit_made_nonlocalinternal=q3/cit_made_total
label variable rcit_made_nonlocalinternal "Share Citations Made[Different Urban Area, Same Assignee]"
gen rcit_made_nonlocalexternal=q4/cit_made_total
label variable rcit_made_nonlocalexternal "Share Citations Made[Different Urban Area, Different Assignee]"
gen rcit_made_other=q5/cit_made_total
label variable rcit_made_other "Share Citations Made[Other]"
sort uaid year
save `prefix'predictor-variables.dta, replace

merge m:1 uaid year using `prefix'dependent-variables.dta, keep(match master) nogen
merge m:1 uaid using `destdir'uaid.dta, keep(match master) nogen
drop population areakm
sort urban_area year
order year urban_area uaid *recd*
save `prefix'ua-year-citations.dta, replace

merge m:1 uaid year using `baseprefix'ua-year-patents.dta, keep(match master) nogen
order year urban_area uaid pat_cnt pat_pool inv_cnt avg_ua_share q*

/* Generating variables that will be used in the estimation */

gen lnpatents = ln(pat_cnt)
label variable lnpatents "Log (Number of Patents)"
gen lnpool = ln(1 + pat_pool)
label variable lnpool "Log (Patent Pool Size)"

/* generate year dummies */
levels year, local(levelyear)
foreach ly of local levelyear {
	gen d`ly'=1 if year==`ly'
	replace d`ly'=0 if missing(d`ly')
}
/* done generating year dummies */

order year urban_area uaid country *focus *diversification citation_type countstyle *recd* *made* lnpatents lnpool d* 
save `prefix'urbanarea-year-estimation.dta, replace
