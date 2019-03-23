set more off
global destdir ~/processed/patents/

//local inputprefix "20190314-ua1"
//local inputprefix "20190314-ua2"
local inputprefix "20190314-ua3"

use ${destdir}`inputprefix'-patent.dta, clear
/* We start with 15,751,822 entries */

keep year patent_id inventor_id uaid country
label variable uaid "urban area id per uaid.dta"

bysort uaid year inventor_id: gen inventor_index=_n if uaid >= 0
replace inventor_index=0 if inventor_index > 1
bysort uaid year: egen uniq_inv=sum(inventor_index)
label variable uniq_inv "[ua-year] number of unique inventors"
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
bysort uaid year: gen pat_cnt=_N
label variable pat_cnt "[ua-year] count of patents"
bysort uaid year: egen avg_ua_share = mean(ua_share)
label variable avg_ua_share "[ua-year] share of inventors in urban areas (avg)"
sort patent_id

merge m:1 patent_id using ${destdir}patent_technology_classification.dta, keep(match master) nogen
/* 47,859 observations are not matched and 7,655,088 are matched
About 37k of the 47k non matched are from 2014 onwards */
drop pat_inv_cnt ua_pat_inv_cnt ua_share ua_inv_cnt
rename cat nber_cat
rename subcat nber_subcat
rename class uspc_class
rename subclass uspc_subclass
sort uaid year

egen id_uspc_class = group(uspc_class) if !strpos(uspc_class,"No longer published") & !strpos(uspc_class,"-0T")
bysort uaid year id_uspc_class: gen patents_in_class=_N if !missing(id_uspc_class)
gen sqf_class = (patents_in_class/pat_cnt) * (patents_in_class/pat_cnt)
bysort uaid year id_uspc_class: replace sqf_class=0 if _n > 1
bysort uaid year: gen uspc_tempsum=sum(sqf_class)
bysort uaid year: egen uspc_focus=max(uspc_tempsum)
gen uspc_differentiation=1-uspc_focus

bysort uaid year nber_cat: gen patents_in_category=_N if !missing(nber_cat)
gen catpercent = (100*patents_in_category)/pat_cnt
gen sqf_category = (patents_in_category/pat_cnt) * (patents_in_category/pat_cnt)
bysort uaid year nber_cat: replace sqf_category=0 if _n > 1
bysort uaid year: gen nber_cat_tempsum=sum(sqf_category)
bysort uaid year: egen nber_cat_focus=max(nber_cat_tempsum)
gen nber_cat_differentiation=1-nber_cat_focus

bysort uaid year nber_subcat: gen patents_in_subcategory=_N if !missing(nber_subcat)
gen subcatpercent = (100*patents_in_subcategory)/pat_cnt
gen sqf_subcategory = (patents_in_subcategory/pat_cnt) * (patents_in_subcategory/pat_cnt)
bysort uaid year nber_subcat: replace sqf_subcategory=0 if _n > 1
bysort uaid year: gen nber_subcat_tempsum=sum(sqf_subcategory)
bysort uaid year: egen nber_subcat_focus=max(nber_subcat_tempsum)
gen nber_subcat_differentiation=1-nber_subcat_focus
preserve

bysort uaid year nber_cat: keep if _n==1
keep uaid year nber_cat catpercent
levels nber_cat, local(levelcat)
foreach lcat of local levelcat {
	gen tempcat`lcat'=catpercent if nber_cat==`lcat'
	replace tempcat`lcat'=0 if missing(tempcat`lcat')
	bysort uaid year: egen percentcat`lcat' = max(tempcat`lcat')
	drop tempcat`lcat'
}
drop nber_cat catpercent
bysort uaid year: keep if _n ==1
save tempcatpercent.dta, replace

restore
preserve
bysort uaid year nber_subcat: keep if _n==1
keep uaid year nber_subcat subcatpercent
levels nber_subcat, local(levelsubcat)
foreach lsubcat of local levelsubcat {
	gen tempsubcat`lsubcat'=subcatpercent if nber_subcat==`lsubcat'
	replace tempsubcat`lsubcat'=0 if missing(tempsubcat`lsubcat')
	bysort uaid year: egen percentsubcat`lsubcat' = max(tempsubcat`lsubcat')
	drop tempsubcat`lsubcat'
}
drop nber_subcat subcatpercent
bysort uaid year: keep if _n ==1
save tempsubcatpercent.dta, replace

restore
merge m:1 uaid year using tempcatpercent.dta, keep(match master) nogen
merge m:1 uaid year using tempsubcatpercent.dta, keep(match master) nogen
save ${destdir}`inputprefix'-patent-technology.dta, replace

drop uspc_class uspc_subclass nber_cat nber_subcat inventor_index patent_id *tempsum sqf_class sqf_category sqf_subcategory id_uspc_class catpercent subcatpercent patents_in_class patents_in_category patents_in_subcategory
sort uaid year
bysort uaid year: keep if _n == 1
bysort uaid: gen pat_pool=sum(pat_cnt)
replace pat_pool = pat_pool - pat_cnt
label variable pat_pool "[ua-year] pool of patents"
order year uaid pat_cnt pat_pool *_focus *_differentiation
save ${destdir}`inputprefix'-ua-year-patents.dta, replace
