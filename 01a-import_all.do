set more off
local datadir ~/data/patentsview/
local destdir ~/datafiles/patents/
cd `destdir'

import delimited `datadir'application.tsv, varnames(1) encoding(UTF-8) clear
save application.dta, replace

import delimited `datadir'uspatentcitation.tsv, varnames(1) encoding(UTF-8) clear
save uspatentcitation.dta, replace

import delimited `datadir'rawassignee.tsv, varnames(1) encoding(UTF-8) clear
gen ntype = real(type)
drop type
rename ntype type
drop  if patent_id=="" & assignee_id==""
//replace assignee_id=organization if assignee=="" & (type==2 | type==3)
save rawassignee.dta, replace

import delimited `datadir'rawinventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id sequence
save rawinventor.dta, replace

import delimited `datadir'location.tsv, varnames(1) encoding(UTF-8) clear
save location.dta, replace

import delimited `datadir'rawlocation.tsv, varnames(1) encoding(UTF-8) clear
sort id
replace city = subinstr(city, `"""',  "", .)
replace city = substr(city, 1, 32)
compress city
save rawlocation.dta, replace

import delimited `datadir'patent_inventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save patent_inventor.dta, replace

import delimited `datadir'locationid_region.csv, varnames(1) encoding(UTF-8) clear
rename id location_id
save locationid_region.dta, replace

import delimited `datadir'locationid_urban_areas.csv, varnames(1) encoding(UTF-8) clear
rename id location_id
replace city = subinstr(city, `"""',  "", .)
replace city = substr(city, 1, 32)
compress city
drop x y
save `destdir'locationid_urban_areas.dta, replace

import delimited `datadir'nber.tsv, varnames(1) encoding(UTF-8) clear
save `destdir'nber.dta, replace

use `destdir'uspatentcitation.dta
preserve
keep if category == "cited by applicant"
save uspatentcitation.applicant.dta, replace
export delimited using uspatentcitation.applicant.csv, replace

restore
preserve
keep if category == "cited by examiner"
save uspatentcitation.examiner.dta, replace
export delimited using uspatentcitation.examiner.csv, replace

restore
preserve
keep if category == "cited by applicant" | category == "cited by examiner"
save uspatentcitation.applicant.examiner.dta, replace
export delimited using uspatentcitation.applicant.examiner.csv, replace

restore
preserve
keep if category == "cited by other"
save uspatentcitation.other.dta, replace

restore
preserve
keep if category == "cited by third party"
save uspatentcitation.thirdparty.dta, replace

restore
keep if category == ""
save uspatentcitation.blank.dta, replace

/* Use this only when you need an integrated region */
/*

import delimited `datadir'uspc_current.tsv, varnames(1) encoding(UTF-8) clear
save `destdir'uspc_current.dta
sort sequence
duplicates drop patent_id, force
sort patent_id
save `destdir'primary.uspc_current.dta, replace

import delimited `datadir'locationid_country.csv, varnames(1) encoding(UTF-8) clear
save `destdir'locationid_country.dta, replace


use locationid_region.dta, clear
gen region_source = "MSA-Urban Centers" if !missing(region)
replace region_source = "PatentsView" if missing(region)

gen new_region = country if region_source=="PatentsView"
replace new_region = new_region + ", " + state if (region_source=="PatentsView" & !missing(state))
replace new_region = new_region + ", " + city if (region_source=="PatentsView" & !missing(city))
replace region=new_region if region_source=="PatentsView"
rename country country2
keep location_id region region_source latitude longitude country2
merge 1:1 location_id using locationid_country
drop ipr_score
drop _merge
save temp.dta, replace

drop if missing(country)
duplicates drop country2, force
keep country2 country
rename country mcountry
save map.dta, replace

use temp.dta, clear
merge m:1 country2 using map.dta
drop _merge
// 55 observations don't still have a country name, 21 unique country codes
replace country=mcountry if (missing(country) & !missing(mcountry))
replace country=mcountry if (region_source=="PatentsView" & country != mcountry)
replace country="United States" if (region=="Brownsville-Harlingen, TX" & country!="United States")
replace country="United States" if (region=="Watertown-Fort Drum, NY" & country!="United States")
replace country="United States" if (region=="Tucson, AZ" & country!="United States")
replace country="United States" if (region=="El Paso, TX" & country!="United States")
replace country="United States" if (region=="McAllen-Edinburg-Mission, TX" & country!="United States")
replace country="United States" if (region=="Ogdensburg-Massena, NY" & country!="United States")
replace country="United States" if (region=="Rio Grande City, TX" & country!="United States")
replace country="United States" if (region=="Bellingham, WA" & country!="United States")
replace country="Hong Kong" if (region=="Hong Kong" & country!="Hong Kong")
drop country2 mcountry
save `destdir'locationid.latlong.region.dta, replace
export delimited using `destdir'locationid.latlong.region.csv, replace
rm map.dta
rm temp.dta

*/

/* end integrated region */
