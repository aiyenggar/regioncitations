set more off
global destdir ~/processed/regioncitations/
cd ${destdir}
local inputprefix "20200107"
local baseprefix "${destdir}`inputprefix'-"

use `baseprefix'explanatory-variables.dta, clear
// label variable citation_type "1 Null, 2 Applicant, 3 Examiner, 4 Other, 5 Third Party, 100 All"
// label variable countstyle "ALL - all flows UNIQ - flows between urban areas and assignees counted only once per citation"
rename sq1 q1
rename sq2 q2
rename sq3 q3
rename sq4 q4
rename sq5 q5
rename sq6 q6
rename suaid_share uaid_flow_share

gen cit_made_total = q1 + q2 + q3 + q4 + q5 + q6
label variable cit_made_total "Total Citation Flows"
gen lncit_made_total=ln(1 + cit_made_total)
label variable lncit_made_total "Log (Total Citation Flows)"

label variable q1 "[ua-year] ua(same) assg(same) citations made"
label variable q2 "[ua-year] ua(same) assg(diff) citations made"
label variable q3 "[ua-year] ua(diff) assg(same) citations made"
label variable q4 "[ua-year] ua(diff) assg(diff) citations made"
label variable q5 "[ua-year] other (undeterminable) citations made"
label variable q6 "[ua-year] count of patents that made no citations"

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

merge m:1 uaid year using ${destdir}ua-year-patents.dta, keep(match master) nogen
merge m:1 uaid year using `baseprefix'dependent-variables.dta, keep(match master)
replace cit_recd_total = 0 if _merge == 1
replace cit_recd_self = 0 if _merge == 1
replace cit_recd_nonself = 0 if _merge == 1
drop _merge
merge m:1 uaid using uaid.dta, keep(match master) nogen
drop population areakm
sort urban_area year
order year urban_area uaid *recd*

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

order year urban_area uaid country *diversification *recd* *made* lnpatents lnpool
save `baseprefix'urbanarea-year-estimation.dta, replace
