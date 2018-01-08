use "/Users/aiyenggar/datafiles/patents/a.e.o.t.n.patents_by_urbanareas_stata12.dta", clear
bysort region: egen totalpool=max(pool)
order year region country2 totalpool patents pool cat* subcat*
keep if totalpool>1000
saveold "/Users/aiyenggar/datafiles/patents/regions1000_stata12.dta", replace version(12)

keep if (country2=="IN" | country2=="IL")
saveold "/Users/aiyenggar/datafiles/patents/ILIN1000_stata12.dta", replace version(12)

br if (region=="Bangalore" | region=="Haifa" | region=="Tel Aviv-Yafo")

use "/Users/aiyenggar/datafiles/patents/rawinventor_urban_areas.dta", clear
gen isrindflag=1 if (country_loc=="IN" | country_loc=="IL")
replace isrindflag=0 if missing(isrindflag)
bysort patent_id: egen isrindsum=sum(isrindflag)
order year patent_id inventor_id region country_loc isrindflag isrindsum
drop if isrindsum==0
keep patent_id inventor_id region city_rawloc country_loc year name_first name_last date 
rename region region_inventor
rename city_rawloc city_inventor
rename country_loc country2_inventor
rename year year_appl
rename date date_appl
replace name_first = substr(trim(name_first), 1, 32)
compress name_first
replace name_last = substr(trim(name_last), 1, 32)
compress name_last
gen name_inventor=name_first + " " + name_last
compress name_inventor
drop name_first name_last
order patent_id inventor_id name_inventor country2_inventor region_inventor city_inventor year_appl date_appl
sort patent_id
saveold "/Users/aiyenggar/datafiles/patents/isrind_patents.dta", version(12) replace

use "/Users/aiyenggar/datafiles/patents/rawassignee_urban_areas.dta"
keep patent_id assignee region country_loc city_rawloc
replace assignee = substr(trim(assignee), 1, 64)
compress assignee
rename region region_assignee
rename country_loc country2_assignee
rename city_rawloc city_assignee
rename assignee name_assignee
sort patent_id
saveold "/Users/aiyenggar/datafiles/patents/rawassignee_simplified.dta", version(12) replace

import delimited "/Users/aiyenggar/datafiles/patents/patentid_grantdate.csv", delimiter(comma) stringcols(1 3) encoding(ISO-8859-1)clear
drop if v1=="id"
rename v1 patent_id
rename v3 date_grant
gen temp = date(date_grant,"YMD")
gen year_grant=year(temp)
drop v2
replace patent_id = substr(trim(patent_id), 1, 16)
compress patent_id
replace date_grant = substr(trim(date_grant), 1, 16)
compress date_grant
drop temp
sort patent_id
saveold "/Users/aiyenggar/datafiles/patents/patentid_grantdate.dta", version(12) replace


use "/Users/aiyenggar/datafiles/patents/isrind_patents.dta", clear
sort patent_id
joinby patent_id using "/Users/aiyenggar/datafiles/patents/rawassignee_simplified.dta", unmatched(master)
drop _merge
sort patent_id
joinby patent_id using "/Users/aiyenggar/datafiles/patents/patentid_grantdate.dta", unmatched(master)
drop _merge
drop city*
order patent_id inventor_id name_inventor name_assignee year_appl year_grant region_inventor country2_inventor region_assignee country2_assignee
saveold "/Users/aiyenggar/datafiles/patents/israel-india-patents.dta", version(12) replace
