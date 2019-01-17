use "/Users/aiyenggar/processed/patents/latlong_urbanarea.dta", clear

count if missing(urban_area)

gen latlong01=string(round(latitude,.01))+","+string(round(longitude,.01)) 
bysort latlong01 (urban_area) : gen urban_area2 = urban_area[_N]
count if missing(urban_area2)

gen latlong1=string(round(latitude,.1))+","+string(round(longitude,.1))
bysort latlong1 (urban_area2) : gen urban_area3 = urban_area2[_N]
count if missing(urban_area3)

split latlong1, parse(,)
rename latlong11 lat1
rename latlong12 long1
order urban_area3 lat1 long1
sort lat1 long1

bysort latlong1: keep if _n == 1
keep urban_area3 lat1 long1 latlong1
destring lat1 long1, replace

drop if missing(urban_area3)
bysort urban_area3: keep if _n == 1
