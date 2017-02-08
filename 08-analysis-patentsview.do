
local allcountries "IN US CN JP"
foreach co of local allcountries {
	di "Country statistics for country `co'"
	levels state if country=="`co'" & year > 2000, local(allstates)
	foreach st of local allstates { 
	di "Region statistics for state `st'"
	tab region if state=="`st'" & country=="`co'" & year > 2000, sort missing 
}
}
	
tab city if state=="Andhra Pradesh", sort missing
tab city if state=="AP", sort missing
tab city if state=="Karnataka", sort missing
tab city if state=="KA", sort missing
tab city if state=="Kerala", sort missing
tab city if state=="CA" & country=="US", sort missing
tab city if state=="PA" & country=="US", sort missing
tab city if state=="MI" & country=="US", sort missing
tab city if state=="Fukuoka" & country=="JP", sort missing
tab city if state=="Fukushima" & country=="JP", sort missing

tab country if missing(state), sort missing
br if missing(country)

use location.dta, clear
keep if city=="Abdullapur" | city=="Abbigeri" | city == "KA" | city=="Achankovil" | city=="Shigajima" | city=="Kanagawa"
levels id, local(lid)
rename id location_id
rename city lcity
rename state lstate
rename country lcountry
save "/Users/aiyenggar/datafiles/patents/l1.dta", replace

use rawlocation.dta, clear
local lid "egwqgkx88c27 ettjalhzighb mnpzwz8ygu8y p7q2t55h4tn7 q6npd0y9p5hu vqam144555pm"
gen t=0
foreach laa of local lid {
	replace t=1 if location_id=="`laa'"
}
keep if t==1
merge m:1 location_id using l1.dta
drop _merge t
rename id rawlocation_id
save "/Users/aiyenggar/datafiles/patents/rl1.dta", replace

use rawinventor.dta, clear
merge 1:1 rawlocation_id using rl1.dta, keep(3)
drop _merge
export delimited using "/Users/aiyenggar/datafiles/patents/rawinventor.rawlocation.location.select.csv", replace

