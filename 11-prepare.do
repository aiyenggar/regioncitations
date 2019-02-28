set more off
local destdir /Users/aiyenggar/processed/patents/
cd `destdir'

import delimited `destdir'backward_citations.csv, varnames(1) encoding(UTF-8) clear
sort ua year
save `destdir'backward_citations.dta, replace

import delimited `destdir'forward_citations.csv, varnames(1) encoding(UTF-8) clear
sort ua year
save `destdir'forward_citations.dta, replace

merge 1:1 ua year using `destdir'backward_citations.dta, nogen
rename ua uaid
merge m:1 uaid using `destdir'uaid.dta, keep(match master) nogen
drop population areakm
sort urban_area year
order year urban_area uaid
save `destdir'ua_year_citations.dta, replace
