set more off
local destdir ~/processed/patents/
cd `destdir'

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

use cpc_current.dta, clear
merge m:1 patent_id using patent_date.dta, keep(match master) nogen
save patent_date_cpc.dta, replace

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
merge m:1 patent_id using patent_date.dta, keep(match master) nogen
keep application_year patent_id citation_id citation_type sequence kind
order application_year patent_id citation_id citation_type sequence kind
bysort patent_id citation_id: keep if _n == 1
export delimited `destdir'citation.csv, replace
save citation.dta, replace

/* Very interesting to note that the number of examiner citations has remained
   static over several years while the number of applicant citations has shot up */

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



use `destdir'uspc_current.dta, clear
/* We start with 22,880,877 observations. Tabulated by mainclass count at the end of this file. */
/* By keeping only one entry per patent, we lose many mainclass associations, and many subclass associations for the class retained as well as those dropped */
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
keep rawlocation_id country latlong
sort latlong
/* bring latlongid in */
merge m:1 latlong using `destdir'latlongid.dta, keep(match master) nogen
drop latlong
/* bring ua1, ua2 and ua3 where ua3 is the union */
merge m:1 latlongid using `destdir'latlong_urbanarea.dta, keep(match master) nogen
sort rawlocation_id
/* 25M rawlocation_id are now mapped to ua1-ua3 via latlongid */
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
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanarea.dta
/* 3562 rawlocation_id go unmatched, leaving 15,748,260 matched entries */
replace ua1 = -2 if _merge==1
replace ua2 = -2 if _merge==1
replace ua3 = -2 if _merge==1
replace latlongid = -2 if _merge==1
drop if _merge == 2 /* from using */
/* We retain all 15,751,822 observations but set ua1, ua2, ua3 to -2 for the unmatched */
drop  _merge rawlocation_id
order year patent_id inventor_id ua* 
sort patent_id
save `destdir'patent_inventor_urbanarea.dta, replace
count if ua1 < 0 /* 4,314,067 of 15,751,822 */
count if ua2 < 0 /* 2,035,898 of 15,751,822 */
count if ua3 < 0 /* 1,320,707 of 15,751,822 */
tab year if ua1 <= -1 & ua2 <= -1 & ua3 <= -1

use `destdir'rawassignee.dta, clear
/* assignee processing for human readability and reduced space requirement, this value is not used to determine matches, assignee_id is */
gen assignee = organization if !missing(organization)
replace assignee = name_first + " " + name_last if missing(assignee)
replace assignee = substr(assignee, 1, 48)
compress assignee
drop uuid name_first name_last organization
rename sequence assigneeseq
rename type assigneetype 
/* We start with 5,903,411 entries */
keep patent_id assignee_id assignee assigneetype assigneeseq 
sort patent_id
merge m:1 patent_id using patent_date.dta, nogen /* 934138 unmatched from using, total 6837549 */
keep patent_id assignee_id assigneetype assigneeseq assignee year_application year_grant
save rawassignee_year.dta, replace
/*
https://www.uspto.gov/web/offices/ac/ido/oeip/taf/inv_all.htm
 
“An independent inventor (also called an individual inventor), for purposes of this report, is a person whose patent, at the time of grant, has ownership that is unassigned or assigned to an individual (i.e., ownership of the patent is not assigned to an organization).”

2 - US Company or Corporation, 3 - Foreign Company or Corporation, 4 - US Individual, 5 - Foreign Individual, 6 - US Government, 7 - Foreign Government, 8 - Country Government, 9 - State Government (US). Note: A "1" appearing before any of these codes signifies part interest
*/
keep if missing(assignee_id) | assigneetype == 4 | assigneetype == 5 | assigneetype == 14 | assigneetype == 15
/* 999339 observations */
keep patent_id
bysort patent_id: keep if _n == 1 /* 988614 observations */
/* Isolated those patents that are individual patents. These need their assignee set differently */
merge 1:m patent_id using `destdir'rawinventor.dta, keep(match) nogen
/* 1421594 observations */
keep patent_id inventor_id
gen attr_assignee="inventor-"+inventor_id
keep patent_id attr_assignee
sort patent_id
gen joinflag = 1
save `destdir'individual_patents.dta, replace /* 1421594 */

use rawassignee_year.dta, clear
gen joinflag = 1 if missing(assignee_id) | assigneetype == 4 | assigneetype == 5 | assigneetype == 14 | assigneetype == 15
replace joinflag = -1 * (100 + round(1000000 * uniform())) if missing(joinflag)
bysort patent_id joinflag: gen index = _n
drop if joinflag == 1 & index > 1 /* We want only one entry per flagged patent */
drop index /* 10724 dropped, 6826825 remain */
merge 1:m patent_id joinflag using individual_patents, keep(match master) /* 1421594 matched, 7260075 remain */
replace assignee_id = attr_assignee if joinflag==1 & _merge==3
egen assignee_numid = group(assignee_id) if strlen(assignee_id) > 0
replace assignee_numid = -1 * (100 + round(1000000 * uniform())) if missing(assignee_numid)
drop joinflag attr_assignee _merge
save assignee_year.dta, replace

keep patent_id assignee_numid
bysort patent_id assignee_numid: gen cnt_assignee = _n == 1
keep if cnt_assignee == 1 /* drop duplicate entries of same assignee on a patent */
by patent_id: replace cnt_assignee = sum(cnt_assignee)
by patent_id: replace cnt_assignee = cnt_assignee[_N]
drop assignee_numid
by patent_id: keep if _n == 1
label variable cnt_assignee "Count of assignees for patent"
save count_assignee.dta, replace

use citation.dta, clear
bysort patent_id citation_id: gen citseq = _n
keep if citseq == 1 /* drop identical citations */
keep patent_id citation_id citation_type

destring citation_id, generate(intcitation_id) force
gen precutoff = intcitation_id < 3930271
egen precutoff_patents_cited = sum(precutoff), by(patent_id)

bysort patent_id citation_id: gen all_patents_cited = _n == 1
by patent_id: replace all_patents_cited = sum(all_patents_cited)
by patent_id: replace all_patents_cited = all_patents_cited[_N]

bysort patent_id citation_type citation_id: gen cited_type = _n == 1
by patent_id citation_type: replace cited_type = sum(cited_type)
by patent_id citation_type: replace cited_type = cited_type[_N]

bysort patent_id citation_type: gen tokeep = _n
keep if tokeep == 1
keep patent_id citation_type precutoff_patents_cited all_patents_cited cited_type
sort patent_id
reshape wide cited_type, i(patent_id) j(citation_type)
label variable precutoff_patents_cited "Count of Patents Cited with Patent ID less than 3930271"
label variable all_patents_cited "Count of Patents Cited"
label variable cited_type1 "Count of Patents Cited of Undetermined Citation Type (NULL)"
label variable cited_type2 "Count of Patents Cited by Applicant"
label variable cited_type3 "Count of Patents Cited by Examiner"
label variable cited_type4 "Count of Patents Cited by Other"
label variable cited_type5 "Count of Patents Cited by Third Party"
save count_citations.dta, replace

use rawinventor.dta, clear
keep patent_id inventor_id
bysort patent_id inventor_id: gen cnt_inventor = _n == 1
keep if cnt_inventor == 1 /* drop duplicate entries of the same inventor on a patent */
by patent_id: replace cnt_inventor = sum(cnt_inventor)
by patent_id: replace cnt_inventor = cnt_inventor[_N]
drop inventor_id
by patent_id: keep if _n == 1
save count_inventor.dta, replace

use count_citations.dta, clear
merge 1:1 patent_id using count_assignee, nogen
merge 1:1 patent_id using count_inventor, nogen
merge 1:1 patent_id using patent_date, nogen
drop if patent_id == "NULL"
save patent_summary.dta, replace
replace cited_type1 = 0 if missing(cited_type1)
replace cited_type2 = 0 if missing(cited_type2)
replace cited_type3 = 0 if missing(cited_type3)
replace cited_type4 = 0 if missing(cited_type4)
replace cited_type5 = 0 if missing(cited_type5)
replace precutoff_patents_cited = -1 if missing(precutoff_patents_cited)
replace all_patents_cited = -1 if missing(all_patents_cited)
replace cnt_assignee = -1 if missing(cnt_assignee)
replace cnt_inventor = -1 if missing(cnt_inventor)
export delimited `destdir'patent_summary.csv, replace
