cap log close
log using knowledge-flows.log, append
set more off
local destdir ~/datafiles/patents/

use `destdir'rawinventor_urban_areas.dta, clear

sort region
egen iregion = group(region)
sort iregion year
bysort iregion year: gen dup_patent_count=_N

gen rflag = 0 if missing(iregion)
replace rflag = 1 if missing(rflag)
sort patent_id
bysort patent_id: egen defined_regions = sum(rflag)

sort patent_id iregion
bysort patent_id iregion: gen patent_region_index=_n
/* Keep only entry per patent region (this may not be so because of multiple inventors from the same location on the same patent) */
keep if patent_region_index == 1
drop inventor_id patent_region_index

// Add any patent level information here
merge m:1 patent_id using `destdir'nber.dta, keep(match master) nogen
sort iregion year
// We have 8,198,219 observations now

levels category_id, local(catid)
foreach icat of local catid {
	bysort iregion year: gen runsumcat`icat'=sum(1)  if category_id==`icat'
	replace runsumcat`icat'=0 if missing(runsumcat`icat')
	bysort iregion year: egen cat`icat'=max(runsumcat`icat')
	drop runsumcat`icat'
}

levels subcategory_id, local(subcatid)
foreach l of local subcatid {
	bysort iregion year: gen runsumsubcat`l'=sum(1)  if subcategory_id==`l'
	replace runsumsubcat`l'=0 if missing(runsumsubcat`l')
	bysort iregion year: egen subcat`l'=max(runsumsubcat`l')
	drop runsumsubcat`l'
}

drop category_id subcategory_id
bysort iregion year: gen patent_count=_N
bysort iregion year: gen region_year_index = _n
keep if region_year_index == 1

keep year region iregion patent_count dup_patent_count cat* subcat* country_loc country_rawloc
order year region iregion patent_count dup_patent_count cat* subcat* country*
drop if missing(region)
save `destdir'urbanareas.year.patents.nber.dta, replace
// We have 57,456 observations now

use `destdir'urbanareas.year.patents.nber.dta, clear
sort iregion year
egen rate12 = mean(patent_count) if (year > 2000 & year <= 2012), by(iregion)
bysort iregion: gen pool_dup_patent_count=sum(dup_patent_count)
replace pool_dup_patent_count = pool_dup_patent_count - dup_patent_count
bysort iregion: gen pool_patent_count=sum(patent_count)
replace pool_patent_count = pool_patent_count - patent_count

sort year
egen yrank = rank(-patent_count), by(year)
egen poolyrank = rank(-pool_patent_count), by(year)
egen patent_count_year = sum(patent_count), by(year)

sort year yrank
bysort year: gen running_patent_count = sum(patent_count)
gen running_ratio = running_patent_count / patent_count_year

sort region year pool_patent_count
keep region year patent_count pool_patent_count cat* subcat*
order region year patent_count pool_patent_count

foreach var of varlist cat* subcat* {
  gen d`var' = 1 if `var' > 0
  replace d`var' = 0 if missing(d`var')
}
export delimited using `destdir'urbanareas.year.csv, replace

log close









// br if (!missing(rate12) & rate12 >= 200.0)
/*

tsset iregion year, yearly
gen mean12 = L11.patent_count + L10.patent_count + L9.patent_count + L8.patent_count + L7.patent_count + L6.patent_count + L5.patent_count + L4.patent_count + L3.patent_count + L2.patent_count + L1.patent_count + patent_count
replace mean12=mean12/12


gen sum5 = L5.patent_region_count + L4.patent_region_count + L3.patent_region_count + L2.patent_region_count + L1.patent_region_count
gen rate3 = (patent_region_count*100)/sum3
egen yrank3 = rank(-rate3), by(year)
gen rate5 = (patent_region_count*100)/sum5
egen yrank5 = rank(-rate5), by(year)
*/
