cap log close

set more off
local destdir /Users/aiyenggar/datafiles/patents/
cd `destdir'
log using knowledge-flows.log, append


import delimited `destdir'e.backwardmap.csv, varnames(1) encoding(UTF-8) clear
save `destdir'e.backwardmap.dta, replace

import delimited `destdir'e.forwardmap.csv, varnames(1) encoding(UTF-8) clear
save `destdir'e.forwardmap.dta, replace



import delimited `destdir'e.citations.urbanareas.year.csv, varnames(1) encoding(UTF-8) clear
save `destdir'e.citations.urbanareas.year.dta, replace


use `destdir'e.citations.urbanareas.year.dta, clear


gen lnpatents = ln(patents)
gen lnpool = ln(1 + pool)

sort year
egen yrank = rank(-patents), by(year)
egen poolyrank = rank(-pool), by(year)
egen patents_year_total = sum(patents), by(year)

sort year yrank
bysort year: gen patents_year_runningsum = sum(patents)
gen patents_year_runningratio = patents_year_runningsum / patents_year_total

sort region
egen regionid = group(region)
egen mean_patent_rate12 = mean(patents) if (year > 2000 & year <= 2012), by(regionid)

sort year
egen mpr12_rank = rank(-mean_patent_rate12) if !missing(mean_patent_rate12), by(year)

sort year mpr12_rank
bysort year: gen mpr12_runningsum = sum(patents)
gen mpr12_runningratio = mpr12_runningsum / patents_year_total

label variable cit_made_localinternal "Citations Made to [Same Region, Same Assignee]"
label variable cit_made_localexternal "Citations Made to [Same Region, Different Assignee]"
label variable cit_made_nonlocalinternal "Citations Made to [Different Region, Same Assignee]"
label variable cit_made_nonlocalexternal "Citations Made to [Different Region, Different Assignee]"
label variable cit_made_local "Citations Made to [Same Region]"
label variable cit_made_internal "Citations Made to [Same Assignee]"
label variable cit_made_other "Citations Made to [Other]"

label variable cit_recd_total "Total Citations Received"
label variable cit_recd_self "Self Citations Received"
label variable cit_recd_nonself "Non-Self Citations Received"
label variable lnpatents "Log (Num Patents)"
label variable lnpool "Log (Patent Pool Size)"

gen d2002=1 if year==2002
replace d2002=0 if missing(d2002)
gen d2003=1 if year==2003
replace d2003=0 if missing(d2003)
gen d2004=1 if year==2004
replace d2004=0 if missing(d2004)
gen d2005=1 if year==2005
replace d2005=0 if missing(d2005)
gen d2006=1 if year==2006
replace d2006=0 if missing(d2006)
gen d2007=1 if year==2007
replace d2007=0 if missing(d2007)
gen d2008=1 if year==2008
replace d2008=0 if missing(d2008)
gen d2009=1 if year==2009
replace d2009=0 if missing(d2009)
gen d2010=1 if year==2010
replace d2010=0 if missing(d2010)
gen d2011=1 if year==2011
replace d2011=0 if missing(d2011)
gen d2012=1 if year==2012
replace d2012=0 if missing(d2012)

gen lncit_made_localinternal=ln(1 + cit_made_localinternal)
gen lncit_made_localexternal=ln(1 + cit_made_localexternal)
gen lncit_made_nonlocalinternal=ln(1 + cit_made_nonlocalinternal)
gen lncit_made_nonlocalexternal=ln(1 + cit_made_nonlocalexternal)
gen lncit_made_local=ln(1+cit_made_local)
gen lncit_made_internal=ln(1+cit_made_internal)
gen lncit_made_other=ln(1 + cit_made_other)
gen lncit_recd_total=ln(1+cit_recd_total)

//replace cit_made_total = 1 if cit_made_total == 0

gen rcit_made_localinternal=cit_made_localinternal/cit_made_total
gen rcit_made_localexternal=cit_made_localexternal/cit_made_total
gen rcit_made_nonlocalinternal=cit_made_nonlocalinternal/cit_made_total
gen rcit_made_nonlocalexternal=cit_made_nonlocalexternal/cit_made_total
gen rcit_made_other=cit_made_other/cit_made_total
gen rcit_made_local=cit_made_local/cit_made_total
gen rcit_made_internal=cit_made_internal/cit_made_total
gen lncit_made_total=ln(1 + cit_made_total)
gen avg_cit_recd=cit_recd_total/cit_made_total


label variable lncit_made_localinternal "Log (Citations Made[Same Region, Same Assignee])"
label variable lncit_made_localexternal "Log (Citations Made[Same Region, Different Assignee])"
label variable lncit_made_nonlocalinternal "Log (Citations Made[Different Region, Same Assignee])"
label variable lncit_made_nonlocalexternal "Log (Citations Made[Different Region, Different Assignee])"
label variable lncit_made_local "Log (Citations Made[Same Region])"
label variable lncit_made_internal "Log (Citations Made[Same Assignee])"
label variable lncit_made_other "Log (Citations Made[Other])"
label variable lncit_recd_total "Log (Total Citations Received)"

label variable rcit_made_localinternal "Share Citations Made[Same Region, Same Assignee]"
label variable rcit_made_localexternal "Share Citations Made[Same Region, Different Assignee]"
label variable rcit_made_nonlocalinternal "Share Citations Made[Different Region, Same Assignee]"
label variable rcit_made_nonlocalexternal "Share Citations Made[Different Region, Different Assignee]"
label variable rcit_made_other "Share Citations Made[Other]"
label variable rcit_made_local "Share Citations Made[Same Region]"
label variable rcit_made_internal "Share Citations Made[Same Assignee]"

label variable lncit_made_total "Log (Total Citations Made)"
label variable avg_cit_recd "Average Citations Received"

gen pool2001=pool if year==2001
replace pool2001=0 if missing(pool2001)
bysort region: egen sumpool2001=sum(pool2001)

merge m:1 region using `destdir'region.country2.dta, keep(match master) nogen
/*
gen intr_localinternal_ipr_score=rcit_made_localinternal*ipr_score
gen intr_localexternal_ipr_score=rcit_made_localexternal*ipr_score
gen intr_nonlocalinternal_ipr_score=rcit_made_nonlocalinternal*ipr_score
gen intr_nonlocalexternal_ipr_score=rcit_made_nonlocalexternal*ipr_score
label variable intr_localinternal_ipr_score "Share [Same Region, Same Assignee] * IPR"
label variable intr_localexternal_ipr_score "Share [Same Region, Different Assignee] * IPR"
label variable intr_nonlocalinternal_ipr_score "Share [Different Region, Same Assignee] * IPR"
label variable intr_nonlocalexternal_ipr_score "Share [Different Region, Different Assignee] * IPR"
*/
egen countryid = group(country)
tabulate countryid, generate(dcountry)

foreach var of varlist cat* subcat* {
  gen percent`var' = (100*`var')/patents
}

order cat* subcat* d*, last // moving the dummy variables to the end
keep if year >= 2001 & year <= 2012
sort region year
save `destdir'e.patents_by_urbanareas.dta, replace
saveold `destdir'e.patents_by_urbanareas_stata12.dta, replace version(12) 

export delimited using `destdir'e.patents_by_urbanareas.csv, replace

log close
