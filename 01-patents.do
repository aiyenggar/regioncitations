cap log close
log using knowledge-flows.log, append
set more off

local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/knowledge-flows-images/
cd `reportdir'

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


sort iregion year
bysort iregion year: gen patent_count=_N
bysort iregion year: gen region_year_index = _n
keep if region_year_index == 1
drop patent_id region_year_index
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

sort region year pool_patent_count
keep region year patent_count pool_patent_count
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

