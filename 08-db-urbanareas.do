set more off
local destdir ~/processed/patents/
cd `destdir'

use `destdir'rawlocation.dta, clear
sort latlong1
merge m:1 latlong1 using `destdir'latlong_urbanareas.dta, keep(match master) nogen
order rawlocation_id urban_area latitude longitude
sort rawlocation_id
save `destdir'rawlocation_urbanareas.dta, replace
export delimited using `destdir'rawlocation_urbanareas.csv, replace


/*
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
replace country_rawloc="JP" if country_rawloc=="JA"
sort rawlocation_id
save `destdir'rawlocation_urbanareas.dta, replace
export delimited using `destdir'rawlocation_urbanareas.csv, replace
*/

/* 
The following is not the best way to capture the country since this data 
comes from rawlocation and there are observed instances of it being incorrect.
This would be better done by bringing the country information 
from the urban areas data


use `destdir'rawlocation_urbanareas.dta, clear
drop if missing(urban_area)
keep urban_area country_rawloc
bysort urban_area: keep if _n == 1
keep urban_area country_rawloc 
rename country_rawloc country2
save urban_area.country2.dta, replace
*/

use `destdir'rawinventor.dta, clear
sort rawlocation_id
drop if missing(rawlocation_id) | rawlocation_id=="NULL" 
/* 287 rows have an empty rawlocation_id and 1 row has rawlocation_id as NULL */
/* 15,751,822 of the initial 15,752,110 remain */
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanareas.dta, keep(match master) nogen
/* All entries are matched, leaving 15,751,822 matched entries */
rename sequence inventorseq
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
/* All entries are matched, leaving 15,751,822 matched entries */
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
drop id series_code country uuid
order year patent_id inventor_id urban_area 
sort patent_id
keep patent_id inventor_id urban_area year date latitude* longitude* latlong* 

gen latitude01=round(latitude,.01)
gen longitude01=round(longitude,.01)
gen latlong01=string(latitude01)+","+string(longitude01)
bysort latlong01: gen index01 = _n
bysort latlong01: gen count01 = _N
bysort latlong01 (urban_area) : gen urban_area2 = urban_area[_N]

drop latlong
rename latlong1 latlong
gen latitude1=round(latitude,.1)
gen longitude1=round(longitude,.1)
gen latlong1=string(latitude1)+","+string(longitude1)
bysort latlong1: gen index1 = _n
bysort latlong1: gen count1 = _N
bysort latlong1 (urban_area2) : gen urban_area3 = urban_area2[_N]

save `destdir'rawinventor_urbanareas.dta, replace
export delimited using `destdir'rawinventor_urbanareas.csv, replace

use `destdir'rawassignee.dta, clear
gen assignee = organization if !missing(organization)
replace assignee = name_first + " " + name_last if missing(assignee)
drop name_first name_last organization
rename sequence assigneeseq
rename type assigneetype
/* We start with 5,903,411 entries */
sort rawlocation_id
drop if missing(rawlocation_id) | rawlocation_id=="NULL"
/* 7,707 rows have an empty rawlocation_id or rawlocation_id as NULL*/
/* 5,895,704 of the initial 5,903,411 remain */
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanareas.dta, keep(match master) nogen
/* All entries are matched, leaving 5,895,704 matched entries */
drop uuid
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
/* All entries are matched, leaving 5,895,704 matched entries */
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
drop id series_code country date 
order year patent_id assignee_id urban_area assignee
sort patent_id
replace assignee = substr(assignee, 1, 48)
compress assignee
keep patent_id assignee_id urban_area country_rawloc year assigneetype assignee assigneeseq
order patent_id assignee_id urban_area country_rawloc
save `destdir'rawassignee_urbanareas.dta, replace
export delimited using `destdir'rawassignee_urbanareas.csv, replace

/* 
 tab assigneetype if year > 2000
assigneetyp |
          e |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        222        0.01        0.01
          2 |  1,678,904       47.22       47.23
          3 |  1,828,166       51.42       98.65
          4 |     16,467        0.46       99.12
          5 |     13,801        0.39       99.51
          6 |     13,244        0.37       99.88
          7 |      3,888        0.11       99.99
          8 |          2        0.00       99.99
          9 |        109        0.00       99.99
         12 |         89        0.00       99.99
         13 |        134        0.00      100.00
         14 |         65        0.00      100.00
         15 |         52        0.00      100.00
         16 |          2        0.00      100.00
         17 |          2        0.00      100.00
------------+-----------------------------------
      Total |  3,555,147      100.00

tab assigneetype

assigneetyp |
          e |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        734        0.01        0.01
          1 |          9        0.00        0.01
          2 |  2,954,197       50.11       50.12
          3 |  2,817,041       47.78       97.90
          4 |     36,218        0.61       98.52
          5 |     25,515        0.43       98.95
          6 |     43,726        0.74       99.69
          7 |     12,950        0.22       99.91
          8 |         22        0.00       99.91
          9 |        249        0.00       99.91
         12 |      1,262        0.02       99.94
         13 |        587        0.01       99.95
         14 |      2,688        0.05       99.99
         15 |        485        0.01      100.00
         16 |          7        0.00      100.00
         17 |         12        0.00      100.00
         18 |          1        0.00      100.00
         19 |          1        0.00      100.00
------------+-----------------------------------
      Total |  5,895,704      100.00
	  
*/


// drop if missing(longitude) | missing(latitude)
/*
gen latitude001=round(latitude,.001)
gen longitude001=round(longitude,.001)
gen latitude01=round(latitude,.01)
gen longitude01=round(longitude,.01)
gen latitude1=round(latitude,.1)
gen longitude1=round(longitude,.1)

gen latlong001=string(latitude001)+","+string(longitude001)
gen latlong01=string(latitude01)+","+string(longitude01)
gen latlong1=string(latitude1)+","+string(longitude1)

bysort latlong001: gen index001 = _n
bysort latlong01: gen index01 = _n
bysort latlong1: gen index1 = _n

count if index1==1 /* 53325 */
count if index01==1 /* 111106 */
count if index001==1 /* 117367 */
*/
