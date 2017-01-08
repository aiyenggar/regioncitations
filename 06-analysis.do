cap log close

set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/knowledge-flows-images/
cd `reportdir'
log using knowledge-flows.log, append

import delimited `destdir'bcit.csv, varnames(1) encoding(UTF-8) clear
save `destdir'bcit.dta, replace

import delimited `destdir'fcit.csv, varnames(1) encoding(UTF-8) clear
save `destdir'fcit.dta, replace

import delimited `destdir'citations.region.year.csv, varnames(1) encoding(UTF-8) clear
save `destdir'citations.region.year.dta, replace


gen lnpatents = ln(patents)
gen lnpool = ln(pool)

sort region
egen regionid = group(region)

sort year
egen yrank = rank(-patents), by(year)
egen poolyrank = rank(-pool), by(year)

sort regionid
egen mean_patent_rate12 = mean(patents) if (year > 2000 & year <= 2012), by(regionid)


sort year
egen patents_year_total = sum(patents), by(year)
sort year yrank
bysort year: gen patents_year_runningsum = sum(patents)
gen patents_year_runningratio = patents_year_runningsum / patents_year_total

sort year yrank

sort region year


save `destdir'patents_by_region.dta, replace
export delimited using `destdir'patents_by_region.csv, replace

log close
