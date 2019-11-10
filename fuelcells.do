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

local mg H01M8/00
local fn fuelcells

use "patent_date_cpc.dta", clear
gen sampleg=1 if (maingroup_id == "`mg'")
replace sampleg=0 if missing(sampleg)
bysort patent_id: egen scnt=sum(sampleg)
/* Every entry for a given patent_id should carry the same sampleg value */
replace sampleg=1 if scnt > 0
replace sampleg=0 if scnt == 0
keep patent_id subgroup_id category date_application year_application year_grant sampleg
drop if missing(year_application) | year_application < 1960 | year_application > 2020
gsort date_application patent_id
keep if category=="inventional"
drop category
egen nid_subgroup = group(subgroup_id)
save patent_cpc_nid_subgroup.dta, replace

keep subgroup_id nid_subgroup
bysort nid_subgroup: keep if _n == 1
save nid_subgroup_map.dta, replace

use patent_cpc_nid_subgroup.dta, clear
keep patent_id nid_subgroup sampleg
order patent_id nid_subgroup sampleg
bysort patent_id: drop if _N==1 /* patents that do not combine anything */
export delimited using "patent_cpc_nid_subgroup.csv", replace

/* Process in python to generate novel-cpc.csv */
local mg H01M8/00
local fn fuelcells
import delimited "novel-cpc-sample.csv", varnames(1) stringcols(3) encoding(UTF-8) clear
save novel-cpc-sample.dta, replace
bysort initial_patent: gen count_novel = _N
bysort initial_patent: keep if _n == 1
keep initial_patent count_novel
rename initial_patent patent_id
save novel-cpc-patents-sample.dta, replace

import delimited "novel-cpc-global.csv", varnames(1) stringcols(3) encoding(UTF-8) clear
save novel-cpc-global.dta, replace
bysort initial_patent: gen count_novel = _N
bysort initial_patent: keep if _n == 1
keep initial_patent count_novel
rename initial_patent patent_id
save novel-cpc-patents-global.dta, replace

use "`fn'.dta", clear
bysort patent_id: keep if _n == 1
order patent_id year_application
keep patent_id year_application
sort year_application patent_id
export delimited using "`fn'patents.csv", replace
save "`fn'patents.dta", replace

use "`fn'patents.dta", clear
merge 1:1 patent_id using novel-cpc-patents-sample.dta, keep(match master)
replace count_novel = 0 if _merge == 1
drop _merge
gen ln_count_novel = ln(1 + count_novel)
rename count_novel samp_novel_comb
rename ln_count_novel samp_ln_novel_comb
merge 1:1 patent_id using novel-cpc-patents-global.dta, keep(match master)
replace count_novel = 0 if _merge == 1
drop _merge
gen ln_count_novel = ln(1 + count_novel)
rename count_novel glob_novel_comb
rename ln_count_novel glob_ln_novel_comb
save "`fn'-novel-patents.dta", replace

use "`fn'-novel-patents.dta", clear
merge  1:m patent_id using patent_assignee, keep(match master) nogen
drop assignee_id

bysort year_application assignee_numid: egen yr_assg_num_pat=sum(1)
bysort year_application assignee_numid: egen yr_assg_snov_pat=count(patent_id) if samp_novel_comb > 0
replace yr_assg_snov_pat=0 if missing(yr_assg_snov_pat)
bysort year_application assignee_numid: egen snov=max(yr_assg_snov_pat)
drop yr_assg_snov_pat
rename snov yr_assg_snov_pat

bysort year_application assignee_numid: egen yr_assg_gnov_pat=count(patent_id) if glob_novel_comb > 0
replace yr_assg_gnov_pat=0 if missing(yr_assg_gnov_pat)
bysort year_application assignee_numid: egen gnov=max(yr_assg_gnov_pat)
drop yr_assg_gnov_pat
rename gnov yr_assg_gnov_pat

order patent_id year_application yr* assignee_numid assignee
save "`fn'-novel-patents-assignee-year.dta", replace

bysort year_application assignee_numid: keep if _n == 1
drop patent_id
/* fill in years where no patents were filed */
keep if year >= 1995 & year <= 2014
bysort assignee_numid: egen assg_pat=sum(yr_assg_num_pat)
keep if assg_pat >= 30
gsort -assg_pat  assignee_numid year_application
gen share_snovel_year = round(yr_assg_snov_pat*100/yr_assg_num_pat, 2)
gen share_gnovel_year = round(yr_assg_gnov_pat*100/yr_assg_num_pat, 2)
order year_application share* assignee_numid assignee yr*
save "`fn'-novel-assignee-year.dta", replace

