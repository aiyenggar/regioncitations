local year_start 2001
local year_end 2018
local destdir ~/processed/patents/
local now : display %tdCYND daily("$S_DATE", "DMY")

use `destdir'citation.dta, clear
keep if application_year >= `year_start' & application_year <= `year_end'
sort application_year patent_id
local filename `now'-citation-`year_start'-`year_end'
export delimited using `filename'.csv, replace

use `destdir'patent_inventor_urbanarea.dta, clear
keep if year >= `year_start' & year <= `year_end'
tab year
sort year patent_id
local filename `now'-inventor-`year_start'-`year_end'
export delimited `filename'.csv, replace

use `destdir'patent_assignee_urbanarea.dta, clear
keep if year >= `year_start' & year <= `year_end'
tab year
sort year patent_id
local filename `now'-assignee-`year_start'-`year_end'
export delimited `filename'.csv, replace

