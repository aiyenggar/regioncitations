local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/citations-20170114/
cd `reportdir'
use `destdir'patents_by_region.dta, clear

keep if country=="India" & dsubcat31==1
sort year
keep year region regionid patents
bysort year: egen countrypatents=sum(patents)
duplicates drop year, force
keep year region regionid countrypatents
gen countrypool=sum(countrypatents)
gen lncountrypool=ln(countrypool)

sort year
graph twoway (connected countrypatents year, msymbol(d)) (connected countrypool year, msymbol(o)), legend(cols(1) label(1 Patents in Year for HJT Subcategory 31) label(2 Pool of Patents by Year for HJT Subcategory 31))
graph twoway (connected countrypatents year if year<=2010, mlabel(countrypatents) msymbol(d)), legend(cols(1) label(1 Patents in Year for HJT Subcategory 31))
graph twoway (connected countrypatents year if year<=2000, mlabel(countrypatents) msymbol(d)), title(Patents in Year for HJT Subcategory 31) legend(cols(1) label(1 Patents in Year for HJT Subcategory 31))
graph twoway (connected countrypatents year if year<=1995, mlabel(countrypatents) msymbol(d)), title(Patents in Year for HJT Subcategory 31) legend(cols(1) label(1 Patents in Year for HJT Subcategory 31))

graph twoway (connected patents year, mlabel(patents)), legend(cols(1) label(1 Patents in Year))
graph twoway (connected  year, mlabel(patents)), legend(cols(1) label(1 Patents in Year))
