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

import delimited `datadir'nber.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save `destdir'nber.dta, replace

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
gen date_application = date(date,"YMD") /* 185 missing */
gen year_application=year(date_application) /* 185 missing */
drop id series_code number country date
order year_application patent_id citation_id citation_type sequence
save citation.dta, replace
/* Very interesting to note that the number of examiner citations has remained
   static over several years while the number of applicant citations has shot up */

/* Create a dta file with patent_id, date_application, date_grant, year_application, year_grant */
use patent.dta, clear
keep patent_id date
rename date date_grant
sort patent_id
merge 1:1 patent_id using `destdir'application.dta, keep(match master) nogen
rename date date_application
keep patent_id date_grant date_application
gen year_application=year(date(date_application,"YMD"))
gen year_grant=year(date(date_grant,"YMD"))
save patent_date.dta, replace

import delimited `datadir'uspc_current.tsv, varnames(1) encoding(UTF-8) clear
drop uuid
save uspc_current.dta, replace

local datadir ~/data/20180528-patentsview/
import delimited `datadir'cpc_current.tsv, varnames(1) encoding(UTF-8) clear
drop uuid
rename subsection_id class_id
rename group_id subclass_id
split subgroup_id, g(group_id) parse(/)
gen maingroup_id = group_id1 + "/00"
gen twodigsubgroup_id = group_id1 + "/" + substr(group_id2,1,2)
rename group_id1 slashprior_id
rename group_id2 slashpost_id
tostring patent_id, replace
sort patent_id
order patent_id section_id class_id subclass_id maingroup_id subgroup_id twodigsubgroup_id
save cpc_current.dta, replace

merge m:1 patent_id using patent_date.dta, keep(match master) nogen
save patent_date_cpc.dta, replace

import delimited `datadir'cpc_group.tsv,  varnames(1) encoding(UTF-8) clear
sort id
rename id subclass_id
save cpc_subclass.dta, replace

local datadir ~/data/20180528-patentsview/
import delimited `datadir'cpc_subgroup.tsv,  varnames(1) encoding(UTF-8) clear
sort id
rename id subgroup_id
split subgroup_id, g(group_id) parse(/)
gen maingroup_id = group_id1 + "/00"
rename group_id1 slashprior_id
rename group_id2 slashpost_id
order subgroup_id maingroup_id title
save cpc_subgroup.dta, replace

keep if maingroup_id == "H01M8/00" & strlen(slashpost_id) == 2
export delimited using "/Users/aiyenggar/processed/patents/H01M8-subgroup-2digitcategories.csv", quote replace
