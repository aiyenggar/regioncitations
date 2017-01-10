cap log close

set more off
local destdir /Users/aiyenggar/datafiles/patents/
cd `destdir'
log using knowledge-flows.log, append

/*
import delimited `destdir'bcit.csv, varnames(1) encoding(UTF-8) clear
save `destdir'bcit.dta, replace

import delimited `destdir'fcit.csv, varnames(1) encoding(UTF-8) clear
save `destdir'fcit.dta, replace

import delimited `destdir'citations.region.year.csv, varnames(1) encoding(UTF-8) clear
save `destdir'citations.region.year.dta, replace
*/

use `destdir'citations.region.year.dta, clear

gen lnpatents = ln(patents)
gen lnpool = ln(pool)

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

label variable cit_recd_total "Citations Received"
label variable cit_recd_local "Citations Received Within Region"
label variable cit_recd_nonlocal "Citations Received Outside Region"

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

label variable lncit_made_localinternal "Log(Cit[Same Region, Same Assignee])"
label variable lncit_made_localexternal "Log(Cit[Same Region, Different Assignee])"
label variable lncit_made_nonlocalinternal "Log(Cit[Different Region, Same Assignee])"
label variable lncit_made_nonlocalexternal "Log(Cit[Different Region, Different Assignee])"
label variable lncit_made_local "Log(Cit[Same Region])"
label variable lncit_made_internal "Log(Cit[Same Assignee])"
label variable lncit_made_other "Log(Cit[Other])"

save `destdir'patents_by_region.dta, replace
export delimited using `destdir'patents_by_region.csv, replace

log close
