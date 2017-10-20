use "/Users/aiyenggar/datafiles/patents/a.e.o.t.n.patents_by_urbanareas_stata12.dta", clear
bysort region: egen totalpool=max(pool)
order year region country2 totalpool patents pool cat* subcat*
keep if totalpool>1000
save "/Users/aiyenggar/datafiles/patents/regions1000_stata12.dta", replace

keep if (country2=="IN" | country2=="IL")
save "/Users/aiyenggar/datafiles/patents/ILIN1000_stata12.dta", replace

br if (region=="Bangalore" | region=="Haifa" | region=="Tel Aviv-Yafo")
