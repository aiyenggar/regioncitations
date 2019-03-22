set more off
local destdir ~/processed/patents/
cd `destdir'

import delimited `destdir'latlong_urbanarea_2.csv, encoding(ISO-8859-1)clear
keep if distance < 30.01
bysort l_latlongid: gen near_points=_N
rename r_latlongid latlongid /* this fields is known to be mapped on to an urban area */
sort latlongid
merge m:1 latlongid using latlong_urbanarea_1.dta, keep(match master) nogen
drop latitude longitude

by l_latlongid ua1, sort: gen nvals = _n == 1
by l_latlongid: replace nvals = sum(nvals)
by l_latlongid: replace nvals = nvals[_N]

sort l_latlongid distance
by l_latlongid: keep if _n == 1

gen ua3 = ua1 if nvals > 1
gen ua2 = ua1 if nvals == 1
label var ua2 "UAID of unique urban area within 30km"
label var ua3 "UAID of closest urban area within 30km"
keep l_latlongid ua2 ua3
order l_latlongid ua2 ua3
rename l_latlongid latlongid
save `destdir'nearby.dta, replace

use `destdir'latlong_urbanarea_1.dta, clear
label var ua1 "urban area id of perfect match"
merge 1:1 latlongid using nearby.dta, keep(match master) nogen
order latlongid latitude longitude ua1 ua2 ua3
sort latlongid
replace ua2 = ua1 if missing(ua2)
label var ua2 "UAID of perfect match or of unique urban area within 30km"
replace ua3 = ua2 if missing(ua3)
label var ua3 "UAID of perfect match or of closest urban area within 30km"
save `destdir'latlong_urbanarea.dta, replace /* both dta and csv are used. csv during processing of citations */
export delimited using latlong_urbanarea.csv, replace
count if ua1 != -1 /* 32580 of 127782 */
count if ua2 != -1 /* 73149 of 127782 */
count if ua3 != -1 /* 84490 of 127782 */
