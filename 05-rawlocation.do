set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

import delimited `datadir'rawlocation.tsv, varnames(1) encoding(UTF-8) clear
replace latlong="" if latlong=="NULL"
split latlong, parse(|)
rename latlong1 latitude
rename latlong2 longitude
destring latitude longitude, replace
replace city = substr(city, 1, 32)
compress city
rename id rawlocation_id
drop if missing(latitude) | missing(longitude)
gen latlong1=string(latitude)+","+string(longitude)
save rawlocation.dta, replace

use `destdir'rawlocation.dta, clear
drop location_id state city country latlong
bysort latlong1: keep if _n == 1
keep latlong1 latitude longitude
order latlong1 latitude longitude
export delimited using spatialjoin.csv, replace
