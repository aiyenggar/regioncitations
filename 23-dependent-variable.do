set more off
global destdir ~/processed/patents/
local inputprefix "20191230-ua3"
local distest "dis"
local baseprefix "${destdir}`inputprefix'-"
local prefix "${destdir}`inputprefix'-`distest'-"

import delimited "`prefix'citations-received-by-patent.csv", encoding(ISO-8859-1) clear
sort citation_id patent_id uaid
save "`prefix'citations-received-by-patent.dta", replace

collapse (sum) s_total=total_citations_received s_self=self_citations_received s_nonself=nonself_citations_received , by(uaid year)
rename s_total cit_recd_total
rename s_self cit_recd_self
rename s_nonself cit_recd_nonself
label variable cit_recd_total "Total Citations Received"
label variable cit_recd_self "Self Citations Received"
label variable cit_recd_nonself "Non-Self Citations Received"
save "`prefix'dependent-variables.dta", replace
