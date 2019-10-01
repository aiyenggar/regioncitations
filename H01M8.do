local mg H01M8/00
local fn h01m8

use patent_date_cpc.dta, clear
keep if (maingroup_id == "`mg'") /* another "H02J" */
keep patent_id year_application year_grant maingroup_id /* at some stage look at category and sequence */
bysort patent_id: keep if _n == 1
merge 1:m patent_id using patent_assignee, keep(match master) nogen
drop assignee_id
bysort year_application: gen patents_appyear = _N
order year_application patents_appyear patent_id assignee assigneetype year_grant
gsort -year_application patent_id
save `fn'.dta, replace

bysort assignee_numid: gen patents_assignee = _N
bysort assignee_numid year_application: gen patents_assignee_appyear = _N
keep year_application year_grant assignee patents_assignee patents_assignee_appyear patents_appyear  assigneetype maingroup_id assignee_numid
order year_application year_grant assignee patents_assignee patents_assignee_appyear patents_appyear  assigneetype maingroup_id assignee_numid
bysort assignee_numid year_application: keep if _n == 1
bysort year_application: gen assignees_year = _N
gsort -year_application -patents_assignee
save `fn'yearassignee.dta, replace

keep assignee_numid assignee patents_assignee assigneetype maingroup_id
bysort assignee_numid: keep if _n == 1
gsort -patents_assignee
save `fn'assignee.dta, replace

/* 3194 assignees, 26 with 100 or more patents, 63 with 50 or more patents, 298 with 10 or more patents, 548 with 5 or more patents */
local mg H01M8/00
local fn h01m8
use `fn'yearassignee.dta, clear
bysort year_application: gen i_yearapplication = _n
label var patents_appyear "Patents granted (till March 2018, CPC:`mg')"
label var year_application "Application year"
twoway connected patents_appyear year_application if i_yearapplication == 1 & year_application >= 1980 & year_application <= 2014, xlabel(1980(5)2015) ylabel(50(200)1300)
