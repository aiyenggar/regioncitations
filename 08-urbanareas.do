set more off
local destdir ~/processed/patents/
cd `destdir'

use `destdir'uspc_current.dta, clear
/* We start with 22,880,877 observations, primarily because most 
   patents have multiple class assignments. */
keep if sequence == 0
drop sequence
/* 6,610,258 patents remain */
sort mainclass_id
rename mainclass_id class
rename subclass_id subclass
merge m:1 class using `destdir'nber_class_match.dta
/* 5,108,545 of the 6,610,258 entries are matched */
/* class 287 723 903 930 935 968 976 977 984 987 are found in no patents */
/* Provide a new catergory (8) and subcategory (81) for all design patents */
replace cat=8 if (strpos(class,"D")==1 & strpos(subclass,"D")==1 & missing(cat))
replace subcat=81 if (strpos(class,"D")==1 & strpos(subclass,"D")==1 & missing(subcat))
keep if _merge == 1 | _merge == 3
drop _merge
sort patent_id
save `destdir'patent_technology_classification.dta, replace

use `destdir'rawlocation.dta, clear
sort latlong
merge m:1 latlong using `destdir'latlong_urbanarea.dta, keep(match master) nogen
order rawlocation_id urban_area* latitude longitude
sort rawlocation_id
save `destdir'rawlocation_urbanarea.dta, replace

use `destdir'rawinventor.dta, clear
/* We start with 15,752,110 observations */
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
/* 1 observation has patent_id as NULL leaving 15,752,109 matched entries */
drop if patent_id=="NULL"
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
keep patent_id inventor_id rawlocation_id year sequence
rename sequence inventorseq
sort rawlocation_id
drop if missing(rawlocation_id)
/* 287 observations have an empty rawlocation_id  */
/* 15,751,822 of the initial 15,752,109 remain */
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanarea.dta, keep(match master) nogen
/* 3562 rawlocation_id go unmatched, leaving 15,748,260 matched entries */
/* We retain all 15,751,822 observations including the unmatched */
drop location_id latlong rawlocation_id
/*
gen latlong01=string(round(latitude,.01))+","+string(round(longitude,.01)) 
bysort latlong01 (urban_area) : gen urban_area2 = urban_area[_N]
gen latlong1=string(round(latitude,.1))+","+string(round(longitude,.1))
bysort latlong1 (urban_area2) : gen urban_area3 = urban_area2[_N]
*/
order year patent_id inventor_id urban_area* 
sort patent_id
save `destdir'patent_inventor_urbanarea.dta, replace
export delimited using `destdir'patent_inventor_urbanarea.csv, replace


use `destdir'rawassignee.dta, clear
gen assignee = organization if !missing(organization)
replace assignee = name_first + " " + name_last if missing(assignee)
replace assignee = substr(assignee, 1, 48)
compress assignee
drop name_first name_last organization
rename sequence assigneeseq
rename type assigneetype
drop uuid
/* We start with 5,903,411 entries */
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
/* All entries are matched, leaving 5,903,411 matched entries */
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
keep year patent_id assignee_id assignee assigneetype assigneeseq rawlocation_id
sort rawlocation_id
drop if missing(rawlocation_id) | rawlocation_id=="NULL"
/* 7,707 rows have an empty rawlocation_id or rawlocation_id as NULL*/
/* 5,895,704 of the initial 5,903,411 remain */
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanarea.dta, keep(match master) nogen
/* 335 entries are not matched, but all 5,895,704 entries are retained */
drop rawlocation_id location_id latlong
/*
gen latlong01=string(round(latitude,.01))+","+string(round(longitude,.01)) 
bysort latlong01 (urban_area) : gen urban_area2 = urban_area[_N]
gen latlong1=string(round(latitude,.1))+","+string(round(longitude,.1))
bysort latlong1 (urban_area2) : gen urban_area3 = urban_area2[_N]
*/
order year patent_id assignee_id urban_area*
sort patent_id
save `destdir'patent_assignee_urbanarea.dta, replace
export delimited using `destdir'patent_assignee_urbanarea.csv, replace

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

