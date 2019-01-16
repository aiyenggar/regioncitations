set more off
local destdir ~/processed/patents/
cd `destdir'

use `destdir'rawlocation.dta, clear
rename id rawlocation_id
rename city city_rawloc
rename state state_rawloc
rename country country_rawloc
rename latlong latlong_rawloc
sort location_id
merge m:1 location_id using `destdir'locationid_urbanareas.dta

order rawlocation_id location_id urban_area city_rawloc state_rawloc country_rawloc latitude longitude
drop _merge
sort rawlocation_id
save `destdir'rawlocation_urbanareas.dta, replace
export delimited using `destdir'rawlocation_urbanareas.csv, replace

/* 
The following is not the best way to capture the country since this data 
comes from rawlocation and there are observed instances of it being incorrect.
This would be better done by bringing the country information 
from the urban areas data
*/

use `destdir'rawlocation_urbanareas.dta, clear
drop if missing(urban_area)
keep urban_area country_rawloc
replace country_loc=country_rawloc if missing(country_loc) & !missing(country_rawloc) & strlen(country_rawloc)==2
bysort urban_area: keep if _n == 1
keep urban_area country_rawloc 
rename country_rawloc country2
save urban_area.country2.dta, replace

use `destdir'rawinventor.dta, clear
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanareas.dta, keep(match master) nogen
rename sequence inventorseq
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
drop id series_code country uuid
order year patent_id inventor_id region country_loc 
sort patent_id
keep patent_id inventor_id region country_loc year date latitude longitude city_rawloc location_id 
order patent_id inventor_id region country_loc year date latitude longitude city_rawloc location_id
export delimited using `destdir'rawinventor_urbanareas.csv, replace

use `destdir'rawassignee.dta, clear
gen assignee = organization if !missing(organization)
replace assignee = name_first + " " + name_last if missing(assignee)
drop name_first name_last organization
rename sequence assigneeseq
rename type assigneetype

merge 1:1 rawlocation_id using `destdir'rawlocation_urbanareas.dta, keep(match master) nogen
drop uuid
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
drop id series_code country date 
order year patent_id assignee_id region assignee
sort patent_id
keep patent_id assignee_id region country_loc
order patent_id assignee_id region country_loc
export delimited using `destdir'rawassignee_urbanareas.csv, replace





/* 
tab assigneetype if year > 2000
assigneetyp |
          e |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |  1,360,657       47.39       47.39
          3 |  1,471,529       51.25       98.65
          4 |     13,651        0.48       99.12
          5 |     10,920        0.38       99.50
          6 |     11,203        0.39       99.89
          7 |      2,644        0.09       99.99
          8 |          2        0.00       99.99
          9 |        105        0.00       99.99
         12 |         83        0.00       99.99
         13 |        110        0.00      100.00
         14 |         61        0.00      100.00
         15 |         43        0.00      100.00
         16 |          2        0.00      100.00
------------+-----------------------------------
      Total |  2,871,010      100.00
*/

