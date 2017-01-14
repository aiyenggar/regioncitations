use "/Users/aiyenggar/datafiles/patents/patents_by_region.dta", clear
bysort year: egen tcm=sum(cit_made_total)
bysort year: egen tcr=sum(cit_recd_total)
duplicates drop year tcm tcr, force
keep year tcm tcr
save "/Users/aiyenggar/datafiles/patents/stats.dta", replace
import delimited "/Users/aiyenggar/datafiles/patents/uspatentcitation.year.csv", varnames(1) encoding(ISO-8859-1)clear
save "/Users/aiyenggar/datafiles/patents/stats2.dta", replace
merge 1:1 year using stats
keep if _merge==3
drop _merge
sort year
gen factorv=tcm/inventor_citations_granted
