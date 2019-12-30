set more off
global destdir ~/processed/patents/
local inputprefix "20191230-ua3"
local distest "dis"
local baseprefix "${destdir}`inputprefix'-"
local prefix "${destdir}`inputprefix'-`distest'-"

import delimited "`prefix'patent-citation-received-by-year.csv", encoding(ISO-8859-1) clear
sort patent_id year
save "`prefix'patent-citation-received-by-year.dta", replace

bysort patent_id: egen cit_recd_total = sum(total_citations_received)
bysort patent_id: egen cit_recd_self = sum(self_citations_received)
bysort patent_id: egen cit_recd_nonself = sum(nonself_citations_received)
drop year total_citations_received self_citations_received nonself_citations_received
bysort patent_id: keep if _n == 1
save "`prefix'patent-citation-received.dta", replace

use  "`baseprefix'patent.dta", clear
keep year uaid patent_id
bysort patent_id uaid: keep if _n == 1
merge m:1 patent_id using "`prefix'patent-citation-received.dta", keep(match master) nogen
drop if uaid < 0
save "`prefix'uaid-patent-citation-received.dta", replace

bysort uaid year: egen tr = sum(cit_recd_total)
bysort uaid year: egen sr = sum(cit_recd_self)
bysort uaid year: egen nr = sum(cit_recd_nonself)
drop patent_id
bysort uaid year: keep if _n == 1
drop cit_recd_total cit_recd_self cit_recd_nonself
rename tr cit_recd_total
rename sr cit_recd_self
rename nr cit_recd_nonself
label variable cit_recd_total "Total Citations Received"
label variable cit_recd_self "Self Citations Received"
label variable cit_recd_nonself "Non-Self Citations Received"
save "`prefix'dependent-variables.dta", replace
