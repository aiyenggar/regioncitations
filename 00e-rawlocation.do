set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

import delimited `datadir'rawlocation.tsv, varnames(1) encoding(UTF-8) clear
replace location_id = id if (missing(location_id) | location_id=="NULL")
replace latlong="" if latlong=="NULL"
split latlong, parse(|)
rename latlong1 latitude
rename latlong2 longitude
destring latitude longitude, replace
replace city = substr(city, 1, 32)
compress city
sort location_id
save rawlocation.dta, replace

use `destdir'rawlocation.dta, clear
drop if missing(longitude) | missing(latitude)
bysort location_id: keep if _n==1
drop id state city country latlong
save locationid_spatialjoin.dta, replace
export delimited using locationid_spatialjoin.csv, replace
