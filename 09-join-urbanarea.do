set more off
local destdir ~/processed/patents/
cd `destdir'

import delimited `destdir'latlong-distance.csv, encoding(ISO-8859-1)clear
bysort l_latlongid: gen near_points=_N
rename r_latlongid latlongid /* this latlongid is known to be mapped onto an urban area */
sort latlongid
merge m:1 latlongid using latlong-urbanarea-1.dta, keep(match master) nogen
drop latitude longitude

by l_latlongid ua1, sort: gen nvals = _n == 1
by l_latlongid: replace nvals = sum(nvals)
by l_latlongid: replace nvals = nvals[_N]

sort l_latlongid distance
/* retain the urban area of the point that is closest to it. There may be other ways to do this */
by l_latlongid: keep if _n == 1

gen ua3 = ua1 if nvals > 1
gen ua2 = ua1 if nvals == 1
label var ua2 "UAID of unique urban area within 30km"
label var ua3 "UAID of closest urban area within 30km"
keep l_latlongid ua2 ua3
order l_latlongid ua2 ua3
rename l_latlongid latlongid
save `destdir'nearby.dta, replace

use `destdir'latlong-urbanarea-1.dta, clear
label var ua1 "urban area id of perfect match"
merge 1:1 latlongid using nearby.dta, keep(match master) nogen
order latlongid latitude longitude ua1 ua2 ua3
sort latlongid
replace ua2 = ua1 if missing(ua2)
label var ua2 "UAID of perfect match or of unique urban area within 30km"
replace ua3 = ua2 if missing(ua3)
label var ua3 "UAID of perfect match or of closest urban area within 30km"
save `destdir'latlong-urbanarea.dta, replace /* both dta and csv are used. csv during processing of citations */
export delimited using latlong-urbanarea.csv, replace
count if ua1 != -1 /* 32580 of 127782 */
count if ua2 != -1 /* 74,128 now, previously 73149 of 127782 */
count if ua3 != -1 /* 87,517 now, previously 84490 of 127782 */
