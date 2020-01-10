set more off
global destdir ~/processed/regioncitations/

use ${destdir}patent-inventor-uaid.dta, clear
rename application_year year
bysort uaid year patent_id: keep if _n == 1
keep uaid year patent_id
merge m:1 patent_id using ${destdir}patent_technology_classification.dta, keep(match master) nogen
drop if missing(id_uspc_class) | missing(nber_cat) | missing(nber_subcat) | missing(year) | uaid < 0
drop uspc_class /* to ensure we only use id_uspc_class */
bysort uaid year: gen pat_cnt=_N /* This pat_cnt is valid only for technology diversification calculations. It is not the same as pat_cnt for the uaid year because those patents with unknown technology classifications are dropped */

bysort uaid year id_uspc_class: gen patents_in_class=_N 
bysort uaid year nber_cat: gen patents_in_category=_N 

gen P_i = patents_in_class/pat_cnt
bysort uaid year id_uspc_class: gen c_dt = P_i * ln(1/P_i) if _n == 1
by uaid year: gen total_diversification = sum(c_dt)
by uaid year: replace total_diversification = total_diversification[_N]

gen P_j = patents_in_category/pat_cnt
bysort uaid year nber_cat: gen c_du = P_j * ln(1/P_j) if _n == 1
by uaid year: gen unrelated_diversification = sum(c_du)
by uaid year: replace unrelated_diversification = unrelated_diversification[_N]

gen P_ij = patents_in_class/patents_in_category
bysort uaid year nber_cat id_uspc_class: gen c_pij = P_ij * ln(1/P_ij) if _n == 1
by uaid year nber_cat: gen dr_j = sum(c_pij)
by uaid year nber_cat: replace dr_j = dr_j[_N]

bysort uaid year nber_cat: gen c_dr = dr_j * P_j if _n == 1
by uaid year: gen related_diversification = sum(c_dr)
by uaid year: replace related_diversification = related_diversification[_N]

gen sqf_class = (patents_in_class/pat_cnt) * (patents_in_class/pat_cnt)
bysort uaid year id_uspc_class: replace sqf_class=0 if _n > 1
bysort uaid year: gen uspc_tempsum=sum(sqf_class)
bysort uaid year: egen uspc_focus=max(uspc_tempsum)
gen uspc_diversification=1-uspc_focus

gen catpercent = (100*patents_in_category)/pat_cnt
gen sqf_category = (patents_in_category/pat_cnt) * (patents_in_category/pat_cnt)
bysort uaid year nber_cat: replace sqf_category=0 if _n > 1
bysort uaid year: gen nber_cat_tempsum=sum(sqf_category)
bysort uaid year: egen nber_cat_focus=max(nber_cat_tempsum)
gen nber_cat_diversification=1-nber_cat_focus

bysort uaid year nber_subcat: gen patents_in_subcategory=_N
gen subcatpercent = (100*patents_in_subcategory)/pat_cnt
gen sqf_subcategory = (patents_in_subcategory/pat_cnt) * (patents_in_subcategory/pat_cnt)
bysort uaid year nber_subcat: replace sqf_subcategory=0 if _n > 1
bysort uaid year: gen nber_subcat_tempsum=sum(sqf_subcategory)
bysort uaid year: egen nber_subcat_focus=max(nber_subcat_tempsum)
gen nber_subcat_diversification=1-nber_subcat_focus

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
bysort uaid year: keep if _n == 1
merge m:1 uaid year using tempcatpercent.dta, keep(match master) nogen
merge m:1 uaid year using tempsubcatpercent.dta, keep(match master) nogen
keep uaid year total_diversification unrelated_diversification related_diversification uspc_diversification nber_cat_diversification nber_subcat_diversification percentcat* percentsubcat*
rm tempcatpercent.dta
rm tempsubcatpercent.dta
save technology_diversification.dta, replace

use ${destdir}patent-inventor-uaid.dta, clear
/* We start with 15,748,151 entries */
rename application_year year
keep year patent_id inventor_id uaid country
label variable uaid "urban area id as per uaid.dta"

bysort uaid year inventor_id: gen inventor_index=_n if uaid >= 0
replace inventor_index=0 if inventor_index > 1
bysort uaid year: egen uniq_inv=sum(inventor_index)
label variable uniq_inv "[ua-year] number of unique inventors"
bysort uaid year: gen inv_cnt=_N if uaid >= 0
label variable inv_cnt "[ua-year] number of non-unique inventors"
bysort patent_id uaid: gen index1 = _n if uaid >= 0
label variable index1 "[ua] index of patent-inventor"
bysort patent_id uaid: gen ua_inv_cnt = _N if uaid >= 0
label variable ua_inv_cnt "[ua-patent] count of inventors"
bysort patent_id: gen pat_inv_cnt = _N
label variable pat_inv_cnt "[patent] number of inventors"
bysort patent_id: egen ua_pat_inv_cnt = sum(ua_inv_cnt) if index1 == 1
label variable ua_pat_inv_cnt "[patent] number of inventors located in any urban area"
gen ua_share = ua_inv_cnt/pat_inv_cnt
label variable ua_share "[patent] share of inventors in the urban area"
keep if index1 == 1
/* We drop 7,841,067 observations, leaving 7,702,947 patent-ua observations */
drop index1 inventor_id
bysort uaid year: gen pat_cnt=_N
label variable pat_cnt "[ua-year] count of patents"
bysort uaid year: egen avg_ua_share = mean(ua_share)
label variable avg_ua_share "[ua-year] share of inventors in urban areas (avg)"
sort patent_id

joinby patent_id using assignee-year.dta, unmatched(master)
drop assignee_id assigneetype assigneeseq assignee
bysort uaid year assignee_numid: gen assignee_index=_n if !missing(assignee_numid)
replace assignee_index=0 if assignee_index > 1
bysort uaid year: egen uniq_ass=sum(assignee_index)
label variable uniq_ass "[ua-year] number of unique assignees"
bysort uaid year: gen ass_cnt=_N if !missing(assignee_numid)
label variable ass_cnt "[ua-year] number of non-unique assignees"
bysort patent_id uaid: gen index1 = _n if uaid >= 0
label variable index1 "[ua] index of patent-inventor location"
keep if index1 == 1
drop index1 assignee_numid _merge

bysort uaid year: keep if _n == 1
merge 1:1 uaid year using technology_diversification.dta, keep(match master) nogen
bysort uaid: gen pat_pool=sum(pat_cnt)
replace pat_pool = pat_pool - pat_cnt
label variable pat_pool "[ua-year] pool of patents"
keep uaid year country pat_pool pat_cnt avg_ua_share uniq_inv inv_cnt uniq_ass ass_cnt *diversification percentcat* percentsubcat*
order year uaid pat_cnt pat_pool *_diversification
save ${destdir}ua-year-patents.dta, replace
