cap log close
log using knowledge-flows.log, append
set more off
local destdir /Users/aiyenggar/datafiles/patents/

use `destdir'primary.uspc.dta, clear
merge m:1 mainclass_id using `destdir'uspc-hjt-mapping.dta
drop if _merge==2
drop _merge uuid
save `destdir'category.primary.uspc.dta, replace

use `destdir'rawinventor_region.dta, clear

/* Keep only entry per patent region (this may not be so because of multiple inventors from the same location on the same patent) */

sort region
egen iregion = group(region)

sort iregion year
bysort iregion year: gen dup_patent_count=_N
// 13,734,673 observations

sort patent_id iregion
bysort patent_id iregion: gen patent_region_index=_n
keep if patent_region_index == 1
drop inventor_id patent_region_index
// We have 8,456,978 observations now

// Add any patent level information here
merge m:1 patent_id using `destdir'category.primary.uspc.dta
drop if _merge==2
drop _merge

sort iregion year

local icat=1
while `icat' <= 6 {
	bysort iregion year: gen runsumcat`icat'=sum(1)  if cat==`icat'
	replace runsumcat`icat'=0 if missing(runsumcat`icat')
	bysort iregion year: egen cat`icat'=max(runsumcat`icat')
	drop runsumcat`icat'
	local icat= `icat' + 1
}

set more off
levels subcat, local(subcatid)
foreach l of local subcatid {
	bysort iregion year: gen runsumsubcat`l'=sum(1)  if subcat==`l'
	replace runsumsubcat`l'=0 if missing(runsumsubcat`l')
	bysort iregion year: egen subcat`l'=max(runsumsubcat`l')
	drop runsumsubcat`l'
}

/*
egen sumcat=rowtotal(cat1-cat6)
egen sumsubcat=rowtotal(subcat*)
count if sumcat != sumsubcat
*/

bysort iregion year: gen patent_count=_N
bysort iregion year: gen region_year_index = _n
keep if region_year_index == 1
drop patent_id region_year_index mainclass_id subclass_id sequence class subcat cat
// We have 535,695 observations now

sort iregion year
bysort iregion: gen pool_dup_patent_count=sum(dup_patent_count)
replace pool_dup_patent_count = pool_dup_patent_count - dup_patent_count
bysort iregion: gen pool_patent_count=sum(patent_count)
replace pool_patent_count = pool_patent_count - patent_count

replace country="Hong Kong" if (region=="Hong Kong" & country!="Hong Kong")
sort year
egen yrank = rank(-patent_count), by(year)
egen poolyrank = rank(-pool_patent_count), by(year)

tsset iregion year, yearly
gen mean12 = L11.patent_count + L10.patent_count + L9.patent_count + L8.patent_count + L7.patent_count + L6.patent_count + L5.patent_count + L4.patent_count + L3.patent_count + L2.patent_count + L1.patent_count + patent_count
replace mean12=mean12/12

sort iregion
egen rate12 = mean(patent_count) if (year > 2000 & year <= 2012), by(iregion)

sort year
egen patent_count_year = sum(patent_count), by(year)
sort year yrank
bysort year: gen running_patent_count = sum(patent_count)
gen running_ratio = running_patent_count / patent_count_year

sort yrank year
save `destdir'patents.regionyear.dta, replace
export delimited using `destdir'patents.regionyear.csv, replace

local destdir /Users/aiyenggar/datafiles/patents/
use `destdir'patents.regionyear.dta, clear
sort region year pool_patent_count
keep region year patent_count pool_patent_count cat* subcat*
order region year patent_count pool_patent_count

foreach var of varlist cat* subcat* {
  gen d`var' = 1 if `var' > 0
  replace d`var' = 0 if missing(d`var')
}
export delimited using `destdir'regionyear.csv, replace

log close

// br if (!missing(rate12) & rate12 >= 200.0)
/*
gen sum5 = L5.patent_region_count + L4.patent_region_count + L3.patent_region_count + L2.patent_region_count + L1.patent_region_count
gen rate3 = (patent_region_count*100)/sum3
egen yrank3 = rank(-rate3), by(year)
gen rate5 = (patent_region_count*100)/sum5
egen yrank5 = rank(-rate5), by(year)
*/

