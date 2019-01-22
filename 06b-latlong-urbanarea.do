set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

import delimited `destdir'one-many-latlong-urbanarea.csv, varnames(1) encoding(ISO-8859-1) clear
sort latlong max_areakm
bysort latlong: keep if _n==_N /* We map to the urbanarea largest in area */
keep latlong latitude longitude name_conve max_pop_al max_areakm
rename name_conve urban_area
rename max_pop_al population
rename max_areakm areakm
sort latlong
save `destdir'latlong_urbanarea.dta, replace
export delimited using latlong_urbanarea.csv, replace
