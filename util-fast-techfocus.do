use 20190318-intermediate-for-test.dta, clear
egen class_numid = group(class) if !strpos(class,"No longer published") & !strpos(class,"-0T")
bysort uaid year class_numid: gen patents_in_class=_N if !missing(class_numid)
bysort uaid year: gen patents_in_uayear=_N
bysort uaid year class_numid: keep if _n==1
gen sqf_class = (patents_in_class/patents_in_uayear) * (patents_in_class/patents_in_uayear)
bysort uaid year: gen tempsum=sum(sqf_class)
bysort uaid year: egen focus0=max(tempsum)
bysort uaid year: keep if _n == 1
gen diverse0=1-focus0
keep uaid year focus0 diverse0
save tech2.dta, replace

use 20190314-ua3-CalcDistTrue-urbanarea-year-estimation.dta, clear
keep if citation_type==100 & !missing(techclass_focus)
keep year uaid urban_area techclass*
order year uaid urban_area techclass*
save techfinal.dta, replace

merge 1:1 year uaid using temp2.dta, keep(match master) nogen
count if abs(uspc_focus-techclass_focus) > 0.000001
