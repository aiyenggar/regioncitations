set more off
local datadir ~/data/patentsview/
local destdir ~/datafiles/patents/
cd `destdir'

import delimited `datadir'application.tsv, varnames(1) encoding(UTF-8) clear
save application.dta, replace

import delimited `datadir'uspatentcitation.tsv, varnames(1) encoding(UTF-8) clear
save uspatentcitation.dta, replace

import delimited `datadir'rawassignee.tsv, varnames(1) encoding(UTF-8) clear
drop  if patent_id=="" & assignee_id==""
//replace assignee_id=organization if assignee=="" & (type==2 | type==3)
save rawassignee.dta, replace

local datadir ~/data/patentsview/
import delimited `datadir'rawinventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id sequence
save rawinventor.dta, replace

import delimited `datadir'location.tsv, varnames(1) encoding(UTF-8) clear
replace city = subinstr(city, `"""',  "", .)
save location.dta, replace

import delimited `datadir'rawlocation.tsv, varnames(1) encoding(UTF-8) clear
sort id
replace city = subinstr(city, `"""',  "", .)
replace city = substr(city, 1, 32)
compress city
save rawlocation.dta, replace

import delimited `datadir'patent_inventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save patent_inventor.dta, replace


local datadir ~/data/patentsview/
import delimited `datadir'locationid_urban_areas.csv, varnames(1) encoding(UTF-8) clear
rename id location_id
replace city = subinstr(city, `"""',  "", .)
replace city = substr(city, 1, 32)
compress city
drop x y
sort location_id
save `destdir'locationid_urban_areas.dta, replace

import delimited `datadir'nber.tsv, varnames(1) encoding(UTF-8) clear
save `destdir'nber.dta, replace

use `destdir'uspatentcitation.dta
export delimited using uspatentcitation.csv, replace

preserve
keep if category == "cited by applicant"
save a.uspatentcitation.dta, replace
export delimited using a.uspatentcitation.csv, replace

restore
preserve
keep if category == "cited by examiner"
save e.uspatentcitation.dta, replace
export delimited using e.uspatentcitation.csv, replace

restore
preserve
keep if category == "cited by other"
save o.uspatentcitation.dta, replace
export delimited using o.uspatentcitation.csv, replace

restore
preserve
keep if category == "cited by third party"
save t.uspatentcitation.dta, replace
export delimited using t.uspatentcitation.csv, replace

restore
keep if category == "NULL"
save n.uspatentcitation.dta, replace
export delimited using n.uspatentcitation.csv, replace
