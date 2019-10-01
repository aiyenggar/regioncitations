local mg H01M8/00
local fn fuelcells

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

use `fn'yearassignee.dta, clear
bysort year_application: gen i_yearapplication = _n
label var patents_appyear "Patents granted (till March 2018, CPC:`mg')"
label var year_application "Application year"
twoway connected patents_appyear year_application if i_yearapplication == 1 & year_application >= 1980 & year_application <= 2014, xlabel(1980(5)2015) ylabel(50(200)1300)

use `fn'yearassignee.dta, clear
drop year_grant patents_appyear assignees_year
rename patents_assignee_appyear y
reshape wide y, i(assignee_numid) j(year_application)
foreach var of varlist y1971-y2017 {
	replace `var' = 0 if missing(`var')
}
drop y1971-y1995
drop y2016-y2017
gen p19962015 = y1996 + y1997 + y1998 + y1999 + y2000 + y2001+ y2002 + y2003 + y2004 + y2005 + y2006 + y2007 + y2008 + y2009 + y2010 + y2011 + y2012 + y2013 + y2014 + y2015
order assignee p19962015 y*
gsort -p19962015
save `fn'yearwise.dta, replace

keep if p19962015 >= 30
keep assignee p19962015 y*
export excel using "`fn'min30patents.xlsx", firstrow(variables) replace
