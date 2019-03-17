set more off
global destdir ~/processed/patents/

//local inputprefix "20190314-ua1"
//local inputprefix "20190314-ua2"
local inputprefix "20190314-ua3"

use ${destdir}`inputprefix'-patent.dta, clear
/* We start with 15,751,822 entries */
keep year patent_id inventor_id uaid country
label variable uaid "urban area id per uaid.dta"

bysort uaid year: gen inv_cnt=_N if uaid >= 0
label variable inv_cnt "[ua-year] number of non-unique inventors"
bysort patent_id uaid: gen index1 = _n if uaid >= 0
label variable index1 "[ua] index of patent-inventor"
bysort patent_id uaid: gen ua_inv_cnt = _N if uaid >= 0
label variable ua_inv_cnt "[ua] count of patent-inventor"
bysort patent_id: gen pat_inv_cnt = _N
label variable pat_inv_cnt "[patent] number of inventors"
bysort patent_id: egen ua_pat_inv_cnt = sum(ua_inv_cnt) if index1 == 1
label variable ua_pat_inv_cnt "[patent] number of inventors located in any urban area"
gen ua_share = ua_pat_inv_cnt/pat_inv_cnt if index1 == 1
label variable ua_share "[patent] share of inventors in urban areas"
keep if index1 == 1
/* We drop 7,841,067 observations, leaving 7,702,947 patent-ua observations */
drop index1 inventor_id
bysort uaid year: egen avg_ua_share = mean(ua_share)
label variable avg_ua_share "[ua-year] share of inventors in urban areas (avg)"
sort patent_id

merge m:1 patent_id using ${destdir}patent_technology_classification.dta, keep(match master) nogen
/* 47,859 observations are not matched and 7,655,088 are matched
About 37k of the 47k non matched are from 2014 onwards */
drop patent_id pat_inv_cnt ua_pat_inv_cnt ua_share ua_inv_cnt
rename cat nber_cat
rename subcat nber_subcat
sort uaid year

levels nber_cat, local(catlev)
foreach icat of local catlev {
	bysort uaid year: gen runsumcat`icat'=sum(1)  if nber_cat==`icat'
	replace runsumcat`icat'=0 if missing(runsumcat`icat')
	bysort uaid year: egen cat`icat'=max(runsumcat`icat')
	drop runsumcat`icat'
}

levels nber_subcat, local(subcatlev)
foreach l of local subcatlev {
	bysort uaid year: gen runsumsubcat`l'=sum(1)  if nber_subcat==`l'
	replace runsumsubcat`l'=0 if missing(runsumsubcat`l')
	bysort uaid year: egen subcat`l'=max(runsumsubcat`l')
	drop runsumsubcat`l'
}

egen class_numid = group(class) if !strpos(class,"No longer published") & !strpos(class,"-0T")
 
levels class_numid, local(classlev)
foreach l of local classlev {
	di "Processing class_numid `l'"
	bysort uaid year: gen runsumclass`l'=sum(1)  if class_numid==`l'
	replace runsumclass`l'=0 if missing(runsumclass`l')
	bysort uaid year: egen classidcnt`l'=max(runsumclass`l')
	drop runsumclass`l'
}

/* We drop those observations missing urban area */
drop if uaid < 0
bysort uaid year: gen pat_cnt=_N
label variable pat_cnt "[ua-year] count of patents"

drop class subclass nber_cat nber_subcat
bysort uaid year: keep if _n == 1
/* We are now down to 59,807 observations */


foreach var of varlist classidcnt* {
  gen f`var' = `var'/pat_cnt
  gen fsq`var' = f`var'*f`var'
}

egen techclass_focus = rowtotal(fsq*)
gen techclass_diversity = 1 - techclass_focus
drop fclassidcnt* fsqclassidcnt* classidcnt*

foreach var of varlist cat* subcat* {
  gen d`var' = 1 if `var' > 0
  replace d`var' = 0 if missing(d`var')
}

sort uaid year
bysort uaid: gen pat_pool=sum(pat_cnt)
replace pat_pool = pat_pool - pat_cnt
label variable pat_pool "[ua-year] pool of patents"
order year uaid pat_cnt pat_pool inv_cnt avg_ua_share techclass*
save ${destdir}`inputprefix'-ua_year_patents.dta, replace


/*bysort patent_id index_urbanarea (ua2_patentinventor_total): replace ua2_patentinventor_total = ua2_patentinventor_total[1] if missing(ua2_patentinventor_total)
 Note that the above replacement will only happen for those observations where
   index_urbanarea (urban_area) is set. Those not in an urban_area will not have this */


