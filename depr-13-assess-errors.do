set more off
local destdir /Users/aiyenggar/processed/patents/
cd `destdir'

import delimited `destdir'assignee_error_patents.csv, encoding(ISO-8859-1)clear
rename num_lines assignee_error_lines
sort patent_id
save `destdir'assignee_error_patents.dta, replace

import delimited `destdir'inventor_error_patents.csv, encoding(ISO-8859-1)clear
rename num_lines inventor_error_lines
sort patent_id
save `destdir'inventor_error_patents.dta, replace
/*         
			inventor error: 2,570,913  
			assignee error: 902,421 
*/
merge 1:1 patent_id using `destdir'assignee_error_patents.dta, nogen
merge 1:1 patent_id using `destdir'20190228-patent_missing.dta, nogen
gen missing_ua = 1 if missing(ualist)
replace missing_ua = 0 if missing(missing_ua)
gen missing_assignee = 1 if missing(assigneelist)
replace missing_assignee = 0 if missing(missing_assignee)
drop _merge ualist assigneelist
merge 1:1 patent_id using `destdir'application.dta
drop if _merge == 2 /* We are not interested in those not in the master */
gen year = year(date(date,"YMD"))
drop _merge id series_code number country date
/* 2,570,333 patent_id cannot match either the inventor or the assignee data.
  These are probably malformed patent_ids. However 942034 patent_ids can be 
  traced to the application.dta  */
save `destdir'errors.dta, replace

/*
. tab missing_ua missing_assignee if !missing(year)

           |   missing_assignee
missing_ua |         0          1 |     Total
-----------+----------------------+----------
         0 |         0    941,170 |   941,170 
         1 |       594        270 |       864 
-----------+----------------------+----------
     Total |       594    941,440 |   942,034 
*/

