local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'a.e.o.t.n.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.tcorrelation.tex) digits(2) no key(a.e.o.t.n.tcorrelation) title("Correlations and Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal    lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.tsummary.tex) labels key(a.e.o.t.n.tsummary) title("Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace 
/* 
Include the below in the tex file as notes 
\multicolumn{13}{l}{\footnotesize Note: The above statistics were computed on the sample that was included in the regression with dependent variable as total citations received}\\
*/

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.ncorrelation.tex) digits(2) no key(a.e.o.t.n.ncorrelation) title("Correlations and Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace
sutex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.nsummary.tex) labels key(a.e.o.t.n.nsummary) title("Summary Statistics for the Sample of All Citations Made (including Applicant, Examiner, and Others)") replace 

/* 
Include the below in the tex file as notes 
\multicolumn{13}{l}{\footnotesize Note: The above statistics were computed on the sample that was included in the regression with dependent variable as non-self citations received}\\
*/

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir'a.e.o.t.n.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for all citations \label{a.e.o.t.n.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
		
// Examiner citations only
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'e.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.tcorrelation.tex) digits(2) no key(e.tcorrelation) title("Correlation table for examiner only data set with dependent variable as total citations received ") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.tsummary.tex) labels key(e.tsummary) title("Summary statistics for examiner only data set with dependent variable as total citations received ") replace 

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.ncorrelation.tex) digits(2) no key(e.ncorrelation) title("Correlation table for examiner only data set with dependent variable as non-self citations received ") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.nsummary.tex) labels key(e.nsummary) title("Summary statistics for examiner only data set with dependent variable as non-self citations received ") replace 

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir'e.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for examiner citations  \label{e.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
		
// Applicant citations only
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'a.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.tcorrelation.tex) digits(2) no key(a.tcorrelation) title("Correlation table for applicant only data set with dependent variable as total citations received ") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.tsummary.tex) labels key(a.tsummary) title("Summary statistics for applicant only data set with dependent variable as total citations received ") replace 

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal    lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.ncorrelation.tex) digits(2) no key(a.ncorrelation) title("Correlation table for applicant only data set with dependent variable as non-self citations received ") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal    lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.nsummary.tex) labels key(a.nsummary) title("Summary statistics for applicant only data set with dependent variable as non-self citations received ") replace 

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir'a.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for applicant citations  \label{a.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
		
// Other citations only
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'o.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.tcorrelation.tex) digits(2) no key(o.tcorrelation) title("Correlation table for other citations only data set with dependent variable as total citations received ") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.tsummary.tex) labels key(o.tsummary) title("Summary statistics for other citations only data set with dependent variable as total citations received ") replace 

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.ncorrelation.tex) digits(2) no key(o.ncorrelation) title("Correlation table for other citations only data set with dependent variable as non-self citations received ") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.nsummary.tex) labels key(o.nsummary) title("Summary statistics for other citations only data set with dependent variable as non-self citations received ") replace 

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir'o.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for other citations \label{o.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")
		
		

local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'a.patents_by_urbanareas.dta, clear
keep if year>=2001 & year<=2012
sort region year

gen nla=round(rcit_made_localinternal*100,.01)
label variable nla "Local-Internal"
gen nlap=round(rcit_made_localexternal*100,.01)
label variable nlap "Local-External"
gen nlpa=round(rcit_made_nonlocalinternal*100,.01)
label variable nlpa "Non-Local-Internal"
gen nlpap=round(rcit_made_nonlocalexternal*100,.01)
label variable nlpap "Non-Local-External"
gen nl=round(rcit_made_local*100,.01)
label variable nl "Local Flows"
gen na=round(rcit_made_internal*100,.01)
label variable na "Internal Flows"
gen nother=round(rcit_made_other*100,.01)
label variable nother "Other Flows"


graph twoway (connected nla year if region=="Bangalore", mlabel(nla) msymbol(d)) ///
	(connected nla year if region=="Beijing", msymbol(t)) ///
	(connected nla year if region=="Tel Aviv-Yafo", msymbol(s)) ///
	(connected nla year if region=="Boston", msymbol(x))  ///
	(connected nla year if region=="San Jose3", mlabel(nla) msymbol(oh)), ///
	ytitle("Percentage of Backward Citations", size(small)) xtitle("Year", size(small)) ///
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title(" " " " " ", justification(right)) ///
	note("Data Source: patentsview.org, naturalearthdata.com") ///
	legend(size(small) cols(3) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Boston) label(5 San Jose))
//graph2tex, epsfile(SMSSameRegionSameAssigneeFlows) ht(5) caption(Same Region Same Assignee Flows)
graph export SMSSameRegionSameAssigneeFlows.png, replace

graph twoway (connected nlap year if region=="Bangalore", mlabel(nlap) msymbol(d)) ///
	(connected nlap year if region=="Beijing", msymbol(t)) ///
	(connected nlap year if region=="Tel Aviv-Yafo",  msymbol(s)) ///
	(connected nlap year if region=="Boston",  msymbol(x)) ///
	(connected nlap year if region=="San Jose3", mlabel(nlap) msymbol(oh)), ///
	ytitle("Percentage of Backward Citations", size(small)) xtitle("Year", size(small)) /// 
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title(" " " " " ", justification(right)) ///
	note("Data Source: patentsview.org, naturalearthdata.com") ///
	legend(size(small) cols(3) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Boston) label(5 San Jose))
//graph2tex, epsfile(SMSSameRegionDiffAssigneeFlows) ht(5) caption(Same Region Different Assignee Flows)
graph export SMSSameRegionDiffAssigneeFlows.png, replace

graph twoway (connected nlpa year if region=="Bangalore", mlabel(nlpa) msymbol(d)) ///
	(connected nlpa year if region=="Beijing",  msymbol(t)) ///
	(connected nlpa year if region=="Tel Aviv-Yafo", mlabel(nlpa) msymbol(s)) ///
	(connected nlpa year if region=="Boston",  msymbol(x)) ///
	(connected nlpa year if region=="San Jose3",  msymbol(oh)), ///
	ytitle("Percentage of Backward Citations", size(small)) xtitle("Year", size(small)) /// 
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title(" " " " " ", justification(right)) ///
	note("Data Source: patentsview.org, naturalearthdata.com") ///
	legend(size(small) cols(3) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Boston) label(5 San Jose))
//graph2tex, epsfile(SMSDiffRegionSameAssigneeFlows) ht(5) caption(Different Region Same Assignee Flows)
graph export SMSDiffRegionSameAssigneeFlows.png, replace

graph twoway (connected nlpap year if region=="Bangalore", msymbol(d)) ///
	(connected nlpap year if region=="Beijing",  msymbol(t)) ///
	(connected nlpap year if region=="Tel Aviv-Yafo", mlabel(nlpap) msymbol(s)) ///
	(connected nlpap year if region=="Boston",  msymbol(x)) ///
	(connected nlpap year if region=="San Jose3", mlabel(nlpap) msymbol(oh)), ///
	ytitle("Percentage of Backward Citations", size(small)) xtitle("Year", size(small)) ///  
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title(" " " " " ", justification(right)) ///
	note("Data Source: patentsview.org, naturalearthdata.com") ///
	legend(size(small) cols(3) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Boston) label(5 San Jose))
//graph2tex, epsfile(SMSDiffRegionDiffAssigneeFlows) ht(5) caption(Different Region Different Assignee Flows)
graph export SMSDiffRegionDiffAssigneeFlows.png, replace
