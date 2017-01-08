cap log close

set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/knowledge-flows-images/
cd `reportdir'
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

label variable cit_made_localinternal "Local-Internal"
label variable cit_made_localexternal "Local-External"
label variable cit_made_nonlocalinternal "Non-Local-Internal"
label variable cit_made_localexternal "Non-Local-External"
label variable cit_made_local "Local"
label variable cit_made_internal "Internal"
label variable cit_made_ther "Other"

label variable cit_recd_local "Local Citations Received"
label variable cit_recd_nonlocal "Non-Local Citations Received"

label variable lnpatents "Log Patents"
label variable lnpool "Log Patent Pool"

set more off
xtset regionid year
xtnbreg cit_recd_local cit_made_localinternal cit_made_localexternal cit_made_nonlocalinternal cit_made_nonlocalexternal  cit_made_other lnpatents lnpool if mean_patent_rate12 > 500
outreg2 using  `reportdir'flowsreg.tex, drop (_*) tex(pretty frag) label dec(2) replace
xi: xtnbreg cit_recd_local cit_made_localinternal cit_made_localexternal cit_made_nonlocalinternal cit_made_nonlocalexternal cit_made_other lnpatents lnpool i.year i.regionid if mean_patent_rate12 > 500
outreg2 using  `reportdir'flowsreg.tex, title(Effect of location of citations made on location of citations received  \label{flowsreg}) drop (_*) tex(pretty frag) label dec(2) append

save `destdir'patents_by_region.dta, replace
export delimited using `destdir'patents_by_region.csv, replace

log close
