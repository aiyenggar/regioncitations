local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'a.e.o.t.n.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.tcorrelation.tex) digits(2) no key(a.e.o.t.n.tcorrelation) title("Correlation table for all citations with dependent variable as total citations received") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.tsummary.tex) labels key(a.e.o.t.n.tsummary) title("Summary statistics for all citations with dependent variable as total citations received") replace 

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.ncorrelation.tex) digits(2) no key(a.e.o.t.n.ncorrelation) title("Correlation table for all citations  with dependent variable as non-self citations received") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.e.o.t.n.nsummary.tex) labels key(a.e.o.t.n.nsummary) title("Summary statistics for all citations with dependent variable as non-self citations received") replace 

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir're.a.e.o.t.n.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for all citations \label{a.e.o.t.n.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include random effects, year dummies and technology subcategory controls")

		
		
// Examiner citations only
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'e.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.tcorrelation.tex) digits(2) no key(e.tcorrelation) title("Correlation table for examiner only data set with dependent variable as total citations received ") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.tsummary.tex) labels key(e.tsummary) title("Summary statistics for examiner only data set with dependent variable as total citations received ") replace 

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.ncorrelation.tex) digits(2) no key(e.ncorrelation) title("Correlation table for examiner only data set with dependent variable as non-self citations received ") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(e.nsummary.tex) labels key(e.nsummary) title("Summary statistics for examiner only data set with dependent variable as non-self citations received ") replace 

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir're.e.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for examiner citations  \label{e.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include random effects, year dummies and technology subcategory controls")

		
		
// Applicant citations only
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'a.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.tcorrelation.tex) digits(2) no key(a.tcorrelation) title("Correlation table for applicant only data set with dependent variable as total citations received ") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.tsummary.tex) labels key(a.tsummary) title("Summary statistics for applicant only data set with dependent variable as total citations received ") replace 

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.ncorrelation.tex) digits(2) no key(a.ncorrelation) title("Correlation table for applicant only data set with dependent variable as non-self citations received ") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.nsummary.tex) labels key(a.nsummary) title("Summary statistics for applicant only data set with dependent variable as non-self citations received ") replace 

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir're.a.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for applicant citations  \label{a.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include random effects, year dummies and technology subcategory controls")

		
		
// Other citations only
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'o.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.tcorrelation.tex) digits(2) no key(o.tcorrelation) title("Correlation table for other citations only data set with dependent variable as total citations received ") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.tsummary.tex) labels key(o.tsummary) title("Summary statistics for other citations only data set with dependent variable as total citations received ") replace 

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model2

xtnbreg cit_recd_total  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.ncorrelation.tex) digits(2) no key(o.ncorrelation) title("Correlation table for other citations only data set with dependent variable as non-self citations received ") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(o.nsummary.tex) labels key(o.nsummary) title("Summary statistics for other citations only data set with dependent variable as non-self citations received ") replace 

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "U.S. Locations"
est store model20

xtnbreg cit_recd_nonself  rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-U.S. Locations"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir're.o.model123192021.tex, ///
		title("Negative binomial regresssion analysis of invention quality for other citations \label{o.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include random effects, year dummies and technology subcategory controls")
		
		
