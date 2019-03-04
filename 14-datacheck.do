use "/Users/aiyenggar/processed/patents/patent_inventor_urbanarea.dta", clear
gen ua = ua1 if ua1 >= 0
replace ua = ua2 if missing(ua) & ua2 >= 0
replace ua = ua3 if missing(ua) & ua3 >= 0
replace ua = -1 if missing(ua)

rename ua uaid
merge m:1 uaid using uaid.dta
keep if _merge == 3
drop _merge
bysort latlongid: gen cnt_pat_inv = _N
gsort - cnt_pat_inv


drop patent_id inventor_id inventorseq
bysort latlongid year: keep if _n==1
gsort - cnt_pat_inv
bysort latlongid: keep if _N==1

drop ua1 ua2 ua3
drop year_pat_inv
save temp.dta, replace
use "/Users/aiyenggar/processed/patents/uaid.dta"
use "/Users/aiyenggar/processed/patents/temp.dta"
rename ua uaid
merge m:1 uaid using uaid.dta
keep if _merge==3
drop _merge
drop population areakm
gsort - cnt_pat_inv
