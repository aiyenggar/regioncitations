set more off
global destdir ~/processed/patents/
local inputprefix "20200104-ua3"
local distest "dis"
local baseprefix "${destdir}`inputprefix'-"
local prefix "${destdir}`inputprefix'-`distest'-"

import delimited "`prefix'flows.csv", encoding(ISO-8859-1) clear
gen flow = q1 + q2 + q3 + q4 + q5
bysort patent_id: gen total_flow = sum(flow)
by patent_id: replace total_flow = round(total_flow[_N],0.0001)
save "`prefix'patent-flows.dta", replace

collapse (sum) sq1=q1 sq2=q2 sq3=q3 sq4=q4 sq5=q5, by(uaid year)
save "`prefix'explanatory-variables.dta", replace
