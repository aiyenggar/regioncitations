set more off
local destdir ~/processed/patents/
cd `destdir'

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

/*
https://www.uspto.gov/web/offices/ac/ido/oeip/taf/inv_all.htm
 
“An independent inventor (also called an individual inventor), for purposes of this report, is a person whose patent, at the time of grant, has ownership that is unassigned or assigned to an individual (i.e., ownership of the patent is not assigned to an organization).”

2 - US Company or Corporation, 3 - Foreign Company or Corporation, 4 - US Individual, 5 - Foreign Individual, 6 - US Government, 7 - Foreign Government, 8 - Country Government, 9 - State Government (US). Note: A "1" appearing before any of these codes signifies part interest
*/

gen update_assignee=1 if missing(assignee_id) | assigneetype == 4 | assigneetype == 5 | assigneetype == 14 | assigneetype == 15
replace update_assignee=0 if missing(update_assignee) /* 0 for 5,838,211 and 1 for  999,338 */
bysort patent_id update_assignee: gen patcnt = _N /* A patent can have multiple assignees, we count how many 'assignees' are missing and how many are present */
bysort patent_id update_assignee: gen patind = _n
/* shouldn't the below be patind > 1? With patcnt > 1 we lose those patents forever do we not? */
drop if update_assignee==1 & patcnt>1 /* 18,717 observations deleted. For those patents that we want to set the assignee for, we want one entry per patent_id. Multiple assignees will be taken care of with multiple inventors on the patent */
save `destdir'temp_patent_assignee_year1.dta, replace /* 6,818,832 observations saved */

/* Isolated those patents that are individual patents. These need their assignee set differently */
keep if update_assignee==1 /* 980,621 observations */
keep patent_id
merge 1:m patent_id using `destdir'rawinventor.dta, keep(match) nogen /* drop 270 of not matched from master */
/* 1,404,965 observations */
keep patent_id inventor_id
gen attr_assignee="inventor-"+inventor_id
keep patent_id attr_assignee
sort patent_id
gen update_assignee=1
gen patind=1
save `destdir'temp_assignee_reassignment.dta, replace /* 1,404,965 */

use `destdir'temp_patent_assignee_year1.dta, clear /* 6,818,832 */
merge 1:m patent_id update_assignee patind using `destdir'temp_assignee_reassignment.dta, keep(match master)
/* 5,838,480 not matched from master, 1,404,965 matched, leaving us with 7,243,445 observations */
replace assignee_id = attr_assignee if update_assignee==1 & _merge==3 /* 1,404,965  changes made */
egen assignee_numid = group(assignee_id) if strlen(assignee_id) > 0
replace assignee_numid = -1 if missing(assignee_numid)
save `destdir'temp_patent_assignee_year2.dta, replace

bysort assignee_numid: gen patent_count=_N if !missing(assignee_numid)
bysort assignee_numid: keep if _n == 1 | missing(assignee_numid)
gsort - patent_count
keep assignee_numid assignee_id assignee patent_count assigneetype assigneeseq
order assignee_numid assignee_id assignee
save `destdir'assignee_id.dta, replace

use `destdir'temp_patent_assignee_year2.dta, clear
keep patent_id assignee_numid year /* assignee_numid will do the job for the comparisons */
order year patent_id assignee_numid
sort patent_id
save `destdir'patent_assignee_year.dta, replace /* 7,243,445 observations for 6,640,891 unique patents with 264 unassigned patents */

merge m:1 patent_id using `destdir'application.dta, nogen
/* 5,903,411 entries are matched,  934,138 are not. We keep all since the unmatched need to be interpreted as individual patents */
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
