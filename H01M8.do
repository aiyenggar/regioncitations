use patent_date_cpc.dta, clear

bysort patent_id subclass_id: keep if _n == 1
keep patent_id subclass_id year_grant
destring patent_id, replace
bysort year_grant subclass_id: gen grp_gyear = _N
bysort subclass_id year_grant: keep if _n == 1
drop patent_id
bysort subclass_id: egen gtot = sum(grp_gyear)
merge m:1 subclass_id using cpc_group, keep(match master) nogen
rename title group_desc

egen grp_rank = rank(-grp_gyear), by(year_grant)
gsort -year_grant -grp_gyear
save group.dta, replace

use assignee_id.dta, clear
merge 1:m assignee_numid using patent_assignee_year, keep(match master) nogen
keep patent_id assignee_numid assignee assigneetype assigneeseq assignee_id
order patent_id assignee_numid assignee assigneetype assigneeseq assignee_id
sort patent_id
save patent_assignee.dta, replace

use patent_date_cpc.dta, clear
keep if (subclass_id == "H01M" /*| subclass_id == "H02J"*/)
keep patent_id year_application year_grant
bysort patent_id: keep if _n == 1
merge 1:m patent_id using patent_assignee, keep(match master) nogen
bysort year_application: gen patents_appyear = _N
save h01m.dta, replace

bysort assignee_numid: gen patents_assignee = _N
bysort assignee_numid year_application: gen patents_assigneeyear = _N
keep year_application year_grant assignee_numid assignee patents_assignee patents_assigneeyear patents_appyear
bysort assignee_numid year_application: keep if _n == 1
bysort year_application: gen assignees_year = _N
gsort -year_application -patents_assignee
save h01myearassignee.dta, replace

keep assignee_numid assignee patents_assignee
bysort assignee_numid: keep if _n == 1
gsort -patents_assignee
save h01massignee.dta, replace
