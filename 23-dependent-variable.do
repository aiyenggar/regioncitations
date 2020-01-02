set more off
global destdir ~/processed/patents/
local inputprefix "20191230-ua3"
local distest "dis"
local baseprefix "${destdir}`inputprefix'-"
local prefix "${destdir}`inputprefix'-`distest'-"

import delimited "`prefix'citations-received-by-patent.csv", encoding(ISO-8859-1) clear
sort citation_id patent_id uaid
save "`prefix'citations-received-by-patent.dta", replace

collapse (sum) s_total=total_citations_received s_self=self_citations_received s_nonself=nonself_citations_received , by(citation_id uaid)
rename citation_id patent_id
sort patent_id
merge m:1 patent_id using patent_summary, keep(match master) nogen
keep patent_id application_year uaid cit_recd_*
rename application_year year
drop if uaid < 0
sort uaid year
collapse (sum) cit_recd_total=s_total cit_recd_self=s_self cit_recd_nonself=s_nonself, by (uaid, year)
label variable cit_recd_total "Total Citations Received"
label variable cit_recd_self "Self Citations Received"
label variable cit_recd_nonself "Non-Self Citations Received"
save "`prefix'dependent-variables.dta", replace
