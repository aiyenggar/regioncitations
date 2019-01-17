use "/Users/aiyenggar/processed/patents/rawinventor_urbanareas.dta", clear

gen latitude1=round(latitude,.1)
gen longitude1=round(longitude,.1)
gen latlong1=string(latitude1)+","+string(longitude1)
bysort latlong1: gen index1 = _n
bysort latlong1: gen count1 = _N
bysort latlong1 (urban_area) : gen urban_area2 = urban_area[_N]

