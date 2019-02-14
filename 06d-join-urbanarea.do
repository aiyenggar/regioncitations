set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

import delimited `destdir'latlong_urbanarea_2.csv, encoding(ISO-8859-1)clear
keep if distance < 30.01
bysort l_latlongid: gen near_points=_N
rename r_latlongid latlongid
sort latlongid
merge m:1 latlongid using latlong_urbanarea_1.dta
keep if _merge==3
drop _merge latitude longitude

by l_latlongid ua1, sort: gen nvals = _n == 1
by l_latlongid: replace nvals = sum(nvals)
by l_latlongid: replace nvals = nvals[_N]

/* You could take a dump at this point for further analysis */
sort l_latlongid distance
by l_latlongid: gen index = _n
keep if index == 1
gen ua3 = ua1 if nvals > 1
gen ua2 = ua1 if nvals == 1
label var ua2 "ID of unique Urban Area within 30km"
label var ua3 "ID of closest Urban Area within 30km"
keep l_latlongid ua2 ua3
order l_latlongid ua2 ua3
rename l_latlongid latlongid

export delimited using `destdir'nearby.csv, replace
save `destdir'nearby.dta, replace

use `destdir'latlong_urbanarea_1.dta, clear
merge 1:1 latlongid using nearby.dta, keep(match master) nogen

save `destdir'latlong_urbanarea.dta, replace
export delimited using latlong_urbanarea.csv, replace

/* 
	32580 of 127782 fall within ua1. 
	40568 fall within ua2 (being within 30km from exactly 1 urban area)
	51910 lie within 30km from 1 or more urban areas, 11342 of which are within
		30km of more than 1 urban area
	Total of 73148 locations (ua1 and ua2)
*/
