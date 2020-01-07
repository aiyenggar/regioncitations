set more off
global destdir ~/processed/regioncitations/
local inputprefix "20200107"
local baseprefix "${destdir}`inputprefix'-"

import delimited "`baseprefix'flows.csv", encoding(ISO-8859-1) clear
gen flow = q1 + q2 + q3 + q4 + q5 + q6
bysort patent_id: gen total_flow = sum(flow)
by patent_id: replace total_flow = round(total_flow[_N],0.00000001)
bysort patent_id uaid: egen uaid_flow = sum(flow)
merge m:1 patent_id uaid using count-uaid-inventor.dta, keep(match master) nogen
gen uaid_share = cnt_uaid_inventor/cnt_inventor if cnt_inventor != 0
label variable uaid_share "[patent_id] Share of inventors belonging to uaid"
save "`baseprefix'patent-flows.dta", replace

drop if uaid < 0
collapse (sum) sq1=q1 sq2=q2 sq3=q3 sq4=q4 sq5=q5 sq6=q6 suaid_share=uaid_share, by(uaid year)
label variable suaid_share "[uaid, year] Sum of uaid_share per [patent_id, uaid]"
save "`baseprefix'explanatory-variables.dta", replace
