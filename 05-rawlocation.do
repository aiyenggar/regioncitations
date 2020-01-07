set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/regioncitations/
cd `destdir'

import delimited `datadir'rawlocation.tsv, varnames(1) encoding(UTF-8) clear
replace latlong="" if latlong=="NULL"
/* 3897 observations have empty latlong */
split latlong, parse(|)
rename latlong1 latitude
rename latlong2 longitude
destring latitude longitude, replace
replace city = substr(city, 1, 32)
compress city
rename id rawlocation_id
drop if missing(latitude) | missing(longitude)
/* 24,987,652 of 24,991,550 remain */
replace latlong=string(latitude)+","+string(longitude)
save rawlocation.dta, replace

use `destdir'rawlocation.dta, clear
drop location_id state city country
bysort latlong: keep if _n == 1
keep latlong latitude longitude
order latlong latitude longitude
export delimited using latlongidmap.csv, replace
