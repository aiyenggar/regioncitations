cap log close
log using "/Users/aiyenggar/Google Drive/log/knowledge-flows.log", append
set more off
local destdir ~/processed/patents/

/* Do this analysis over three loops. ua1 as urban_area, 
  ua1+ua2 as urban_area, and ua1+ua2+ua3 as urban_area */

use `destdir'patent_inventor_urbanarea.dta, clear
/* We start with 15,751,822 entries */
sort urban_area
egen index_urbanarea = group(urban_area)
sort index_urbanarea year
bysort index_urbanarea year: gen dup_patent_count=_N

sort patent_id index_urbanarea
bysort patent_id index_urbanarea: gen patent_region_index=_n if !missing(index_urbanarea)
bysort patent_id index_urbanarea: gen patent_region_count=_N if !missing(index_urbanarea)
bysort patent_id: gen inventor_count=_N
/* inventor_count counts the total number of inventors on a patent irrespective
   of whether the inventor is mapped to an urban_area or not */
bysort patent_id: egen ua2_patentinventor_total = sum(patent_region_count) if patent_region_index == 1
/* The variable ua2_patentinventor_total represents the total number of
   inventors on the patent who are located within an(y) urban_area. This is
   different from the number of inventors by the number of inventors who are
   outside an urban_area */
bysort patent_id index_urbanarea (ua2_patentinventor_total): replace ua2_patentinventor_total = ua2_patentinventor_total[1] if missing(ua2_patentinventor_total) 
/* Note that the above replacement will only happen for those observations where
   index_urbanarea (urban_area) is set. Those not in an urban_area will not have this */
   
gen share_urban_area = ua2_patentinventor_total/inventor_count
label variable share_urban_area "[patent] share of inventors in urbanareas"

replace city="" if city=="NULL"
gen latlong1=string(round(latitude,0.1))+","+string(round(longitude,0.1)) if missing(index_urbanarea) & !missing(latitude) & !missing(longitude)
egen icity = group(latlong1) if missing(index_urbanarea) & !missing(latlong1)
/* We want the city measures to be set only when region is unavailable */
sort icity year
bysort icity year: gen city_year_count=_N if missing(index_urbanarea)
sort patent_id icity
bysort patent_id icity: gen patent_city_index=_n if missing(index_urbanarea) & !missing(latlong)
bysort patent_id icity: gen patent_city_count=_N if missing(index_urbanarea) & !missing(latlong)


gen geo_count=patent_region_count
replace geo_count=patent_city_count if missing(geo_count)
gen geo_strength=round(geo_count/inventor_count,0.01)
bysort index_urbanarea year: egen mean_invention_weight = mean(geo_strength)
bysort index_urbanarea year: egen mean_inventor_count = mean(geo_count)
bysort index_urbanarea year: egen mean_share_urban_area = mean(share_urban_area)
label variable mean_share_urban_area "[urbanarea-year] share of inventors in urbanareas (avg)"

/* 
3562 observations (patent-inventor) are such that no geographical information
is available. Those observations will be dropped. Only a few of those are such 
that all inventors of the patent will be dropped. For many, some patent-inventor
observations will be retained and only those that lack any geographical information
will be dropped.
*/

/* Keep only one entry per patent region (this may not be so because of 
multiple inventors from the same location on the same patent). geo_strenth
may be used if the relative number of patent-inventor is to be known.  geo_count
 specifies the total number of patent-inventor observations for that patent */

keep if patent_region_index == 1 | patent_city_index == 1
/* Of the 15,751,822 observations, 3,562 observations are 
 missing(patent_region_index) & missing(patent_city_index).
 We are now left with 9,170,120 observations */
drop inventor_id inventorseq patent_region_index patent_city_index 
save patent.urbanarea.dta, replace

merge m:1 patent_id using `destdir'patent_technology_classification.dta, keep(match master) nogen
/* 55,657 observations are not matched and 9,114,463 are matched 
It seems that the nber file is out of date by a very significant margin */
rename cat nber_cat
rename subcat nber_subcat
save patent.urbanarea.technology.dta, replace

sort index_urbanarea year

levels nber_cat, local(catlev)
foreach icat of local catlev {
	bysort index_urbanarea year: gen runsumcat`icat'=sum(1)  if nber_cat==`icat'
	replace runsumcat`icat'=0 if missing(runsumcat`icat')
	bysort index_urbanarea year: egen cat`icat'=max(runsumcat`icat')
	drop runsumcat`icat'
}

levels nber_subcat, local(subcatlev)
foreach l of local subcatlev {
	bysort index_urbanarea year: gen runsumsubcat`l'=sum(1)  if nber_subcat==`l'
	replace runsumsubcat`l'=0 if missing(runsumsubcat`l')
	bysort index_urbanarea year: egen subcat`l'=max(runsumsubcat`l')
	drop runsumsubcat`l'
}


/* We drop those observations missing urbanarea */
drop if missing(index_urbanarea)
/* Without the nber step, 3,462,342 observations deleted and 6,695,613 remain */
bysort index_urbanarea year: gen patent_count=_N
bysort index_urbanarea year: keep if _n == 1
/* We are now down to 72,836 observations */
foreach var of varlist cat* subcat* {
  gen d`var' = 1 if `var' > 0
  replace d`var' = 0 if missing(d`var')
}

drop patent_id
order year urban_area mean_share_urban_area mean_invention_weight mean_inventor_count patent_count dup_patent_count dcat* dsubcat* country* latitude longitude

sort index_urbanarea year
egen rate12 = mean(patent_count) if (year > 2000 & year <= 2012), by(index_urbanarea)
bysort index_urbanarea: gen pool_dup_patent_count=sum(dup_patent_count)
replace pool_dup_patent_count = pool_dup_patent_count - dup_patent_count
bysort index_urbanarea: gen pool_patent_count=sum(patent_count)
replace pool_patent_count = pool_patent_count - patent_count

sort year
egen yrank = rank(-patent_count), by(year)
egen poolyrank = rank(-pool_patent_count), by(year)
egen patent_count_year = sum(patent_count), by(year)

sort year yrank
bysort year: gen running_patent_count = sum(patent_count)
gen running_ratio = running_patent_count / patent_count_year

sort urban_area year pool_patent_count
order urban_area year patent_count pool_patent_count cat* subcat* dcat* dsubcat* mean_*  latitude longitude

save urbanarea.year.dta, replace
export delimited using `destdir'urbanarea.year.csv, replace

log close

// br if (!missing(rate12) & rate12 >= 200.0)
/*

tsset index_urbanarea year, yearly
gen mean12 = L11.patent_count + L10.patent_count + L9.patent_count + L8.patent_count + L7.patent_count + L6.patent_count + L5.patent_count + L4.patent_count + L3.patent_count + L2.patent_count + L1.patent_count + patent_count
replace mean12=mean12/12


gen sum5 = L5.patent_region_count + L4.patent_region_count + L3.patent_region_count + L2.patent_region_count + L1.patent_region_count
gen rate3 = (patent_region_count*100)/sum3
egen yrank3 = rank(-rate3), by(year)
gen rate5 = (patent_region_count*100)/sum5
egen yrank5 = rank(-rate5), by(year)
*/
