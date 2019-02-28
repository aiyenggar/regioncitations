local year_start 1976
local year_end 2018
local destdir ~/processed/patents/
local now : display %tdCYND daily("$S_DATE", "DMY")

use `destdir'citation.dta, clear
keep if application_year >= `year_start' & application_year <= `year_end'
sort application_year patent_id
local filename `now'-citation-`year_start'-`year_end'
export delimited using `filename'.csv, replace

use `destdir'patent_inventor_urbanarea.dta, clear
gen ua = ua1 if ua1 >= 0
replace ua = ua2 if missing(ua) & ua2 >= 0
replace ua = ua3 if missing(ua) & ua3 >= 0
replace ua = -1 if missing(ua)
keep patent_id inventor_id ua
tostring ua, generate(ualist)

bysort patent_id: replace ualist = ualist[_n-1] + "," + ualist if _n > 1
bysort patent_id: keep if _n == _N
drop inventor_id ua
save `now'-inventor.dta, replace

use `destdir'patent_assignee_urbanarea.dta, clear
keep patent_id assignee_numid assignee
tostring assignee_numid, generate(assigneelist)
bysort patent_id: replace assigneelist = assigneelist[_n-1] + "," + assigneelist if _n > 1
bysort patent_id: keep if _n == _N
drop assignee_numid assignee
save `now'-assignee.dta, replace

merge 1:1 patent_id using `now'-inventor.dta
save `now'-patent_consolidated-all.dta, replace
drop _merge
export delimited `now'-patent_list_location_assignee.csv, replace

use `now'-patent_consolidated-all.dta, clear
drop if _merge==3
save `now'-patent_missing.dta, replace
export delimited `now'-patent_missing.csv, replace

/* We are missing assignee information for 941,175 patents (_merge==2) */
/* We are missing inventor information for 594 patents (_merge==1) */
