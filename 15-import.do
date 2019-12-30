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

local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

import delimited `datadir'uspatentcitation.tsv, varnames(1) encoding(UTF-8) clear
drop uuid name country
save uspatentcitation.dta, replace

use uspatentcitation.dta, clear
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
drop id series_code number country date date_application
order year_application patent_id citation_id citation_type sequence
rename patent_id p1
rename citation_id patent_id
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
rename patent_id citation_id
rename p1 patent_id
gen date_application = date(date,"YMD") 
gen citation_year_application=year(date_application) 
drop id series_code number country date date_application
order year_application patent_id citation_id citation_type sequence citation_year_application
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

/* year_cpc_subclass.dta will have number of unique patents by application year for each cpc subclass e.g., H01M */
use patent_date_cpc.dta, clear
bysort patent_id subclass_id: keep if _n == 1
keep subclass_id year_application
bysort subclass_id year_application: gen patents_applyear_subclass = _N
bysort subclass_id year_application: keep if _n == 1
bysort subclass_id: egen patents_subclass = sum(patents_applyear_subclass)
merge m:1 subclass_id using cpc_subclass, keep(match master) nogen
gen subclass_desc = proper(substr(title, 1, 108))
drop title
egen rank_subclass_byyear = rank(-patents_applyear_subclass), by(year_application)
gsort -year_application rank_subclass_byyear 
order year_application patents* rank* subclass_id subclass_desc
drop if year_application > 2017
save year_cpcsubclass.dta, replace

/* year_cpc_maingroup.dta will have number of unique patents by application year for each cpc subclass e.g., H01M8/00 */
use patent_date_cpc.dta, clear
bysort patent_id maingroup_id: keep if _n == 1
keep maingroup_id year_application
bysort maingroup_id year_application: gen patents_applyear_maingroup = _N
bysort maingroup_id year_application: keep if _n == 1
bysort maingroup_id: egen patents_maingroup = sum(patents_applyear_maingroup)
gen subgroup_id = maingroup_id
merge m:1 subgroup_id using cpc_subgroup, keep(match master) nogen
gen maingroup_desc = proper(substr(title, 1, 108))
drop title
egen rank_maingroup_byyear = rank(-patents_applyear_maingroup), by(year_application)
gsort -year_application rank_maingroup_byyear
keep year_application patents* rank* maingroup_id maingroup_desc
order year_application patents* rank* maingroup_id maingroup_desc
drop if year_application > 2017
save year_cpcmaingroup.dta, replace

use assignee_id.dta, clear
merge 1:m assignee_numid using patent_assignee_year, keep(match master) nogen
keep patent_id assignee_numid assignee assigneetype assigneeseq assignee_id
order patent_id assignee_numid assignee assigneetype assigneeseq assignee_id
sort patent_id
save patent_assignee.dta, replace

use citation.dta, clear
bysort patent_id citation_id: gen citseq = _n
keep if citseq == 1 /* drop identical citations */
keep application_year patent_id citation_id citation_type

destring citation_id, generate(intcitation_id) force
gen precutoff = intcitation_id < 3930271
egen precutoff_patents_cited = sum(precutoff), by(patent_id)

bysort patent_id citation_id: gen all_patents_cited = _n == 1
by patent_id: replace all_patents_cited = sum(all_patents_cited)
by patent_id: replace all_patents_cited = all_patents_cited[_N]

bysort patent_id citation_type citation_id: gen intype_patents_cited = _n == 1
by patent_id citation_type: replace intype_patents_cited = sum(intype_patents_cited)
by patent_id citation_type: replace intype_patents_cited = intype_patents_cited[_N]

bysort patent_id citation_type: gen tokeep = _n
keep if tokeep == 1
keep application_year patent_id citation_type precutoff_patents_cited all_patents_cited intype_patents_cited
sort patent_id
save count_citations.dta, replace

use rawassignee.dta, clear
keep patent_id assignee_id
bysort patent_id assignee_id: gen cnt_assignee = _n == 1
keep if cnt_assignee == 1 /* drop duplicate entries of same assignee on a patent */
by patent_id: replace cnt_assignee = sum(cnt_assignee)
by patent_id: replace cnt_assignee = cnt_assignee[_N]
drop assignee_id
by patent_id: keep if _n == 1
save count_assignee.dta, replace

use rawinventor.dta, clear
keep patent_id inventor_id
bysort patent_id inventor_id: gen cnt_inventor = _n == 1
keep if cnt_inventor == 1 /* drop duplicate entries of the same inventor on a patent */
by patent_id: replace cnt_inventor = sum(cnt_inventor)
by patent_id: replace cnt_inventor = cnt_inventor[_N]
drop inventor_id
by patent_id: keep if _n == 1
save count_inventor.dta, replace
