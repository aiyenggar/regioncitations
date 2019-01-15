set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

/*
 Number of lines in each of the input files (for later comparison with .dta file)
  128948 locationid_urbanareas.tsv
 6647700 application.tsv
  389247 assignee.tsv
  128948 location.tsv
 5105938 nber.tsv
 6647700 patent.tsv
 5902218 patent_assignee.tsv
 15752164 patent_inventor.tsv
 5903412 rawassignee.tsv
 15752111 rawinventor.tsv
 24991550 rawlocation.tsv
 94726691 uspatentcitation.tsv
 22880878 uspc_current.tsv
*/

// Import the locationid urban_areas mapping generated through the QGIS spatial join
import delimited `destdir'locationid_urbanareas.csv, varnames(1) encoding(UTF-8) clear
rename id location_id
replace city = subinstr(city, `"""',  "", .)
replace city = substr(city, 1, 32)
compress city
drop x y
sort location_id
save locationid_urbanareas.dta, replace

// Import cleaned/raw files from patentsview
import delimited `datadir'application.tsv, varnames(1) encoding(UTF-8) clear
save application.dta, replace

import delimited `datadir'assignee.tsv, varnames(1) encoding(UTF-8) clear
rename id assignee_id
save assignee.dta, replace

import delimited `datadir'location.tsv, varnames(1) encoding(UTF-8) clear
//replace city = subinstr(city, `"""',  "", .)
save location.dta, replace

import delimited `datadir'nber.tsv, varnames(1) encoding(UTF-8) clear
save `destdir'nber.dta, replace

import delimited `datadir'patent_assignee.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save patent_assignee.dta, replace

import delimited `datadir'patent_inventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save patent_inventor.dta, replace

import delimited `datadir'patent.tsv, varnames(1) encoding(UTF-8) clear
rename id patent_id
sort patent_id
save patentwithabstract.dta, replace
drop abstract
save patent.dta, replace

import delimited `datadir'rawassignee.tsv, varnames(1) encoding(UTF-8) clear
drop  if patent_id=="" & assignee_id==""
save rawassignee.dta, replace

import delimited `datadir'rawinventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id sequence
save rawinventor.dta, replace

import delimited `datadir'rawlocation.tsv, varnames(1) encoding(UTF-8) clear
sort id
replace city = subinstr(city, `"""',  "", .)
replace city = substr(city, 1, 32)
compress city
save rawlocation.dta, replace

import delimited `datadir'uspatentcitation.tsv, varnames(1) encoding(UTF-8) clear
save uspatentcitationfull.dta, replace
drop uuid name country
save uspatentcitation.dta, replace

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
