set more off
local destdir ~/datafiles/patents/
cd `destdir'

use `destdir'rawassignee_urban_areas.dta, clear
keep if country_loc=="IN" | country_rawloc=="IN"
order year assignee
sort appl_date
sort assignee
keep patent_id assignee_id country_loc country_rawloc region appl_date year application_id latitude longitude
keep if country_loc=="IN"

merge m:1 assignee_id using `destdir'assignee.dta,  keep(match master) nogen
gen assignee = organization if !missing(organization)
replace assignee = name_first + " " + name_last if missing(assignee)
drop name_first name_last organization 
bysort assignee: gen assignee_pool=_N
bysort assignee: gen assignee_count=_n

save `destdir'india.dta, replace
gsort -assignee_pool
export excel assignee assignee_pool region country_loc latitude longitude using "india_patents_1980.xlsx" if assignee_count==1,  firstrow(variables) replace

use `destdir'india.dta, clear
drop assignee_pool assignee_count
drop if year < 2000
bysort assignee: gen assignee_pool=_N
bysort assignee: gen assignee_count=_n
gsort -assignee_pool
export excel assignee assignee_pool region country_loc latitude longitude using "india_patents_2000.xlsx" if assignee_count==1,  firstrow(variables) replace

