set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

import delimited `destdir'one-many-latlong-urbanarea.csv, varnames(1) encoding(ISO-8859-1) clear
rename name_conve urban_area
rename max_pop_al population
rename max_areakm areakm
rename join_fid uaid
label var uaid "Urban Area ID"
rename target_fid latlongid
label var latlongid "Geo Point ID"
drop join_count
save `destdir'one-many-latlong-urbanarea.dta, replace

bysort uaid: keep if _n==1
keep urban_area population areakm uaid
export delimited using `destdir'uaid.csv, replace
save `destdir'uaid.dta, replace

use `destdir'one-many-latlong-urbanarea.dta, clear
bysort latlongid: keep if _n == 1
keep latlong latlongid
export delimited using `destdir'latlongid.csv, replace
save `destdir'latlongid.dta, replace

use `destdir'one-many-latlong-urbanarea.dta, clear
sort latlongid area
bysort latlong: keep if _n==_N /* We map to the urbanarea largest in area */
sort latlongid
rename uaid ua1
keep latlongid ua1 latitude longitude
save `destdir'latlong_urbanarea_1.dta, replace
export delimited using latlong_urbanarea_1.csv, replace

