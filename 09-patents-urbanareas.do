cap log close
log using "/Users/aiyenggar/Google Drive/log/knowledge-flows.log", append
set more off
local destdir ~/processed/patents/

use `destdir'rawinventor_urbanareas.dta, clear
/* We start with 15,751,822 entries */
sort urban_area
egen iregion = group(urban_area)
sort iregion year
bysort iregion year: gen dup_patent_count=_N

sort patent_id iregion
bysort patent_id iregion: gen patent_region_index=_n if !missing(iregion)
bysort patent_id iregion: gen patent_region_count=_N if !missing(iregion)
bysort patent_id: gen inventor_count=_N
bysort patent_id: egen total_patentinventor_region = sum(patent_region_count) if patent_region_index == 1
bysort patent_id iregion (total_patentinventor_region): replace total_patentinventor_region = total_patentinventor_region[1] if missing(total_patentinventor_region) 
gen share_urban_area = total_patentinventor_region/inventor_count

replace city_rawloc="" if city_rawloc=="NULL"
gen latlong=string(round(latitude,0.1))+","+string(round(longitude,0.1)) if missing(iregion) & !missing(latitude) & !missing(longitude)
egen icity = group(latlong) if missing(iregion) & !missing(latlong)
/* We want the city measures to be set only when region is unavailable */
sort icity year
bysort icity year: gen city_year_count=_N if missing(iregion)
sort patent_id icity
bysort patent_id icity: gen patent_city_index=_n if missing(iregion) & !missing(latlong)
bysort patent_id icity: gen patent_city_count=_N if missing(iregion) & !missing(latlong)


gen geo_count=patent_region_count
replace geo_count=patent_city_count if missing(geo_count)
gen geo_strength=round(geo_count/inventor_count,0.01)
bysort iregion year: egen mean_invention_weight = mean(geo_strength)
bysort iregion year: egen mean_inventor_count = mean(geo_count)
bysort iregion year: egen mean_share_urban_area = mean(share_urban_area)
/* 
3562 observations (patent-inventor) are such that no geographical information
is available. Those observations will be dropped. Only a few of those are such 
that all inventors of the patent will be dropped. For many, some patent-inventor
observations will be retained and only those that lack any geographical information
will be dropped.
*/

/* Keep only entry per patent region (this may not be so because of 
multiple inventors from the same location on the same patent). geo_strenth
may be used if the relative number of patent-inventor is to be known.  geo_count
 specifies the total number of patent-inventor observations for that patent */

keep if patent_region_index == 1 | patent_city_index == 1
/* Of the 15,751,822 observations, 3,562 observations are 
 missing(patent_region_index) & missing(patent_city_index), and 5,593,867
 observations have  patent_region_index > 1 & patent_city_index > 1. 
 We retain only one observation per patent-inventor-region with geo_strength and geo_count
 accounting for contextual information. We are now left with 10,157,955 observations */
drop inventor_id patent_region_index patent_city_index 
drop location_id city_rawloc date
save urbanareas.year.patents.dta, replace
// Add any patent level information here



/* The nber section - lot of missing data */
merge m:1 patent_id using `destdir'nber.dta, keep(match master) nogen
/* 2,383,547 observations are not matched and  7,774,408 are matched 
It seems that the nber file is out of date by a very significant margin */

sort iregion year

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
foreach var of varlist cat* subcat* {
  gen d`var' = 1 if `var' > 0
  replace d`var' = 0 if missing(d`var')
}

/* End of nber section - lot of missing data */



drop if missing(iregion)
/* Without the nber step, 3,462,342 observations deleted and 6,695,613 remain */
bysort iregion year: gen patent_count=_N
bysort iregion year: keep if _n == 1
/* We are now down to 60,456 observations */
keep year urban_area patent_count dup_patent_count /*cat* subcat**/ country_rawloc mean_* iregion
order year urban_area mean_invention_weight mean_inventor_count patent_count dup_patent_count /*cat* subcat**/ country* 


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


sort urban_area year pool_patent_count
/*
keep region year patent_count pool_patent_count latlong icity geo_count geo_strength cat* subcat*
*/
order urban_area year patent_count pool_patent_count

save urbanareas.year.dta, replace
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
