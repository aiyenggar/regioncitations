set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

/*
 Number of lines in each of the input files (for later comparison with .dta file)
  127783 latlong_urbanareas.tsv
 6647700 application.tsv
  389247 assignee.tsv
  128948 location.tsv
 5105938 nber.tsv
 6647700 patent.tsv
 5902218 patent_assignee.tsv
 15752164 patent_inventor.tsv
 5903412 rawassignee.tsv
 15752111 rawinventor.tsv
 24991550 rawlocation.tsv (24,987,652 not missing latitude or longitude)
 94726691 uspatentcitation.tsv
 22880878 uspc_current.tsv
*/

// Import cleaned/raw files from patentsview
import delimited `datadir'application.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save application.dta, replace

import delimited `datadir'assignee.tsv, varnames(1) encoding(UTF-8) clear
rename id assignee_id
save assignee.dta, replace

import delimited `datadir'location.tsv, varnames(1) encoding(UTF-8) clear
save location.dta, replace

import delimited `datadir'nber.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
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
save rawassignee.dta, replace

import delimited `datadir'rawinventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id sequence
save rawinventor.dta, replace

import delimited `datadir'uspatentcitation.tsv, varnames(1) encoding(UTF-8) clear
save uspatentcitationfull.dta, replace

use uspatentcitationfull.dta
drop uuid name country
save uspatentcitation.dta, replace

use uspatentcitation.dta
egen citation_type=group(category)
/* 
group(categ |
       ory) |      Freq.     Percent        Cum.
------------+-----------------------------------
NULL      1 | 21,863,086       23.08       23.08
applicant 2 | 27,250,149       28.77       51.85
examiner  3 | 20,169,593       21.29       73.14
other     4 | 25,441,800       26.86      100.00
third party5|      2,062        0.00      100.00
------------+-----------------------------------
      Total | 94,726,690      100.00
*/

drop category date
sort patent_id
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen

gen application_date = date(date,"YMD") /* 185 missing */
gen application_year=year(application_date) /* 185 missing */
drop id series_code number country date
order application_year patent_id citation_id citation_type sequence
save citation.dta, replace
/* Very interesting to note that the number of examiner citations has remained
   static over several years while the number of applicant citations has shot up */
   
keep if application_year >= 2001
save citation2001.dta, replace

keep if citation_type == 2
sort application_year patent_id
save applicant_citation2001.dta, replace
export delimited using applicant_citation2001.csv, replace

use uspatentcitation.dta
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

import delimited `datadir'uspc_current.tsv, varnames(1) encoding(UTF-8) clear
drop uuid
save uspc_current.dta, replace
