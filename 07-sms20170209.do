local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'ae.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

// DV is Total Citations Received
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(ae.tcorrelation.tex) digits(2) no key(ae.tcorrelation) title("Correlation table for applicant and examiner citations data set with DV as Total Citations Received") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(ae.tsummary.tex) labels key(ae.tsummary) title("Summary statistics for applicant and examiner citations data set with DV as Total Citations Received") replace 

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model2

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(ae.ncorrelation.tex) digits(2) no key(ae.ncorrelation) title("Correlation table for applicant and examiner citations  data set with DV as Non-Self Citations Received") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(ae.nsummary.tex) labels key(ae.nsummary) title("Summary statistics for applicant and examiner citations  data set with DV as Non-Self Citations Received") replace 

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model20

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir'ae.model123192021.tex, ///
		title("NB Regression Analysis of Invention Quality for Applicant \& Examiner Citations \label{ae.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
		
// Examiner citations only
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/code/articles/qepaper/
cd `reportdir'
use `destdir'e.patents_by_urbanareas.dta, clear
eststo clear
xtset regionid year

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool, file(e.correlation.tex) digits(2) sig no replace
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool, file(e.summary.tex) labels replace

// DV is Total Citations Received
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model1

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model2

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model19

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model20

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir'e.model123192021.tex, ///
		title("NB Regression Analysis of Invention Quality for Examiner Citations Only \label{e.model123192021}") ///
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
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model1

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.tcorrelation.tex) digits(2) no key(a.tcorrelation) title("Correlation table for applicant only data set with DV as Total Citations Received") replace  
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.tsummary.tex) labels key(a.tsummary) title("Summary statistics for applicant only data set with DV as Total Citations Received") replace 

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model2

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model3


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model19

corrtex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.ncorrelation.tex) digits(2) no key(a.ncorrelation) title("Correlation table for applicant only data set with DV as Non-Self Citations Received") replace 
sutex cit_recd_total cit_recd_nonself cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other rcit_made_local rcit_made_internal  lncit_made_total lnpatents lnpool if e(sample) == 1, file(a.nsummary.tex) labels key(a.nsummary) title("Summary statistics for applicant only data set with DV as Non-Self Citations Received") replace 

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model20

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model21


esttab model1 model2 model3 model19 model20 model21 using `reportdir'a.model123192021.tex, ///
		title("NB Regression Analysis of Invention Quality for Applicant Citations Only \label{a.model123192021}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

		
		
		
		
		
		
		
		
		
		
xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model10

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model11

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model12

esttab model10 model11 model12 using `reportdir'model101112.tex, ///
		title("Distribution of Citations Made on Total Citations Received (RE Models) \label{model101112}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent* _cons) scalars("Groups" "Sample") addnotes("All models include region random effects with year dummies and technology subcategory controls")

// End DV is Total Citations Received

// DV is Self Citations Received
xtnbreg cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model13

xtnbreg cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model14

xtnbreg cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model15

esttab model13 model14 model15 using `reportdir'model131415.tex, ///
		title("Effect of Nature of Citations Made on Self Citations Received*  \label{model131415}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		nostar drop (d* percent*) scalars("Groups" "Sample") ///
		addnotes("* Results reported are from a priliminary analysis" "All models include region fixed effects, year dummies and technology subcategory controls" "UC - Urban Centers definition obtained from naturalearthdata.com")


xtnbreg cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model16

xtnbreg cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model17

xtnbreg cit_recd_self rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model18

esttab model16 model17 model18 using `reportdir'model161718.tex, ///
		title("Distribution of Citations Made on Self Citations Received (RE Models)  \label{model161718}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent* _cons) scalars("Groups" "Sample") addnotes("All models include region random effects with year dummies and technology subcategory controls")

// End DV is Self Citations Received


// DV is Non-Self Citations Received
xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model19

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model20

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model21

esttab model19 model20 model21 using `reportdir'model192021.tex, ///
		title("Distribution of Citations Made on Non-Self Citations Received (FE Models)  \label{model192021}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

esttab model19 model20 model21 using `reportdir'model192021.csv, ///
		title("Distribution of Citations Made on Non-Self Citations Received (FE Models)  \label{model192021}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model22

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model23

xtnbreg cit_recd_nonself rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model24

esttab model22 model23 model24 using `reportdir'model222324.tex, ///
		title("Distribution of Citations Made on Non-Self Citations Received (RE Models) \label{model222324}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent* _cons) scalars("Groups" "Sample") addnotes("All models include region random effects with year dummies and technology subcategory controls")

// End DV is Non-Self Citations Received


// DV is Other Citations Received
xtnbreg cit_recd_other rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model25

xtnbreg cit_recd_other rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model26

xtnbreg cit_recd_other rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model27

esttab model25 model26 model27 using `reportdir'model252627.tex, ///
		title("Distribution of Citations Made on Other Citations Received (FE Models)  \label{model252627}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")


xtnbreg cit_recd_other rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model28

xtnbreg cit_recd_other rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 == "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model29

xtnbreg cit_recd_other rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) re
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model30

esttab model28 model29 model30 using `reportdir'model282930.tex, ///
		title("Distribution of Citations Made on Other Citations Received (RE Models) \label{model282930}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent* _cons) scalars("Groups" "Sample") addnotes("All models include region random effects with year dummies and technology subcategory controls")

// End DV is Other Citations Received

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012), i(regionid) fe 
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model4


xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & country2 != "US"), i(regionid) fe 
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model6

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* pop areakm if (year>=2001 & year<=2012 & pop!=0 & areakm != 0), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model7

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* pop areakm  if (year>=2001 & year<=2012 & pop!=0 & areakm != 0 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model8

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* pop areakm  if (year>=2001 & year<=2012 & pop!=0 & areakm != 0 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model9


xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* pop areakm if (year>=2001 & year<=2012 & pop!=0 & areakm != 0), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (UC)"
est store model7

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* pop areakm  if (year>=2001 & year<=2012 & pop!=0 & areakm != 0 & country2 == "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (UC)"
est store model8

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* pop areakm  if (year>=2001 & year<=2012 & pop!=0 & areakm != 0 & country2 != "US"), i(regionid) fe
estadd local Groups `e(N_g)'
estadd local Sample "Non-US Locations (UC)"
est store model9


esttab model1 model4 using `reportdir'model14.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model14}") ///
		label longtable replace p(3) not nostar compress nogaps noomitted wide ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")
//		order(rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool ) ///

esttab model3 model6 using `reportdir'model36.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model36}") ///
		label longtable replace p(3) not nostar compress nogaps noomitted wide ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")
//		order(rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool ) ///


esttab model7 model8 model9 using `reportdir'model789.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model789}") ///
		label longtable replace p(3) not noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "Sample") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_lnpatents intr_localexternal_lnpatents intr_nonlocalinternal_lnpatents intr_nonlocalexternal_lnpatents lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & !missing(rcit_made_localinternal) & !missing(rcit_made_localexternal) & !missing(rcit_made_nonlocalinternal) & !missing(rcit_made_nonlocalexternal))
//matrix _s=e(b)	
// from(_s, skip)
// & !missing(rcit_made_localinternal) & !missing(rcit_made_localexternal) & !missing(rcit_made_nonlocalinternal) & !missing(rcit_made_nonlocalexternal)



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



graph twoway (connected nla year if region=="Bangalore", mlabel(nla) msymbol(d)) (connected nla year if region=="Beijing", msymbol(t)) ///
	(connected nla year if region=="Tel Aviv-Yafo", msymbol(s)) (connected nla year if region=="Austin", msymbol(sh)) ///
	(connected nla year if region=="Boston", msymbol(x)) (connected nla year if region=="San Francisco1", msymbol(o)) ///
	(connected nla year if region=="San Jose3", mlabel(nla) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Region Same Assignee Flows") ///
	note("Data Source: patentsview.org, Natural Earth Urban Centers Database") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin) label(5 Boston) label(6 San Francisco) label(7 San Jose))
graph2tex, epsfile(UCSameRegionSameAssigneeFlows) ht(5) caption(Same Region Same Assignee Flows)
graph export UCSameRegionSameAssigneeFlows.png, replace

graph twoway (connected nlap year if region=="Bangalore", mlabel(nlap) msymbol(d)) (connected nlap year if region=="Beijing", msymbol(t)) ///
	(connected nlap year if region=="Tel Aviv-Yafo",  msymbol(s)) (connected nlap year if region=="Austin",  msymbol(sh)) ///
	(connected nlap year if region=="Boston",  msymbol(x)) (connected nlap year if region=="San Francisco1",  msymbol(o)) ///
	(connected nlap year if region=="San Jose3", mlabel(nlap) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") /// 
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Region Different Assignee Flows") ///
	note("Data Source: patentsview.org, Natural Earth Urban Centers Database") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin) label(5 Boston) label(6 San Francisco) label(7 San Jose))
graph2tex, epsfile(UCSameRegionDiffAssigneeFlows) ht(5) caption(Same Region Different Assignee Flows)
graph export UCSameRegionDiffAssigneeFlows.png, replace

graph twoway (connected nlpa year if region=="Bangalore", mlabel(nlpa) msymbol(d)) (connected nlpa year if region=="Beijing",  msymbol(t)) ///
	(connected nlpa year if region=="Tel Aviv-Yafo", mlabel(nlpa) msymbol(s)) (connected nlpa year if region=="Austin",  msymbol(sh)) ///
	(connected nlpa year if region=="Boston",  msymbol(x)) (connected nlpa year if region=="San Francisco1", msymbol(o)) ///
	(connected nlpa year if region=="San Jose3",  msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") /// 
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Different Region Same Assignee Flows") ///
	note("Data Source: patentsview.org, Natural Earth Urban Centers Database") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin) label(5 Boston) label(6 San Francisco) label(7 San Jose))
graph2tex, epsfile(UCDiffRegionSameAssigneeFlows) ht(5) caption(Different Region Same Assignee Flows)
graph export UCDiffRegionSameAssigneeFlows.png, replace

graph twoway (connected nlpap year if region=="Bangalore", msymbol(d)) (connected nlpap year if region=="Beijing",  msymbol(t)) ///
	(connected nlpap year if region=="Tel Aviv-Yafo", mlabel(nlpap) msymbol(s)) (connected nlpap year if region=="Austin", msymbol(sh)) ///
	(connected nlpap year if region=="Boston",  msymbol(x)) (connected nlpap year if region=="San Francisco1",  msymbol(o)) ///
	(connected nlpap year if region=="San Jose3", mlabel(nlpap) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///  
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Different Region Different Assignee Flows") ///
	note("Data Source: patentsview.org, Natural Earth Urban Centers Database") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin) label(5 Boston) label(6 San Francisco) label(7 San Jose))
graph2tex, epsfile(UCDiffRegionDiffAssigneeFlows) ht(5) caption(Different Region Different Assignee Flows)
graph export UCDiffRegionDiffAssigneeFlows.png, replace

graph twoway (connected nl year if region=="Bangalore", mlabel(nl) msymbol(d)) (connected nl year if region=="Beijing",  msymbol(t)) ///
	(connected nl year if region=="Tel Aviv-Yafo",  msymbol(s)) (connected nl year if region=="Austin", msymbol(sh)) ///
	(connected nl year if region=="Boston",  msymbol(x)) (connected nl year if region=="San Francisco1",  msymbol(o)) ///
	(connected nl year if region=="San Jose3", mlabel(nl) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///  
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Region Flows (Aggregated over Assignees)") ///
	note("Data Source: patentsview.org, Natural Earth Urban Centers Database") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin) label(5 Boston) label(6 San Francisco) label(7 San Jose))
graph2tex, epsfile(UCSameRegionFlows) ht(5) caption(Same Region Flows)
graph export UCSameRegionFlows.png, replace

graph twoway (connected na year if region=="Bangalore",  msymbol(d)) (connected na year if region=="Beijing",  msymbol(t)) ///
	(connected na year if region=="Tel Aviv-Yafo", mlabel(na) msymbol(s)) (connected na year if region=="Austin", mlabel(na) msymbol(sh)) ///
	(connected na year if region=="Boston",  msymbol(x)) (connected na year if region=="San Francisco1",  msymbol(o)) ///
	(connected na year if region=="San Jose3",  msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Assignee Flows (Aggregated over Regions)") ///
	note("Data Source: patentsview.org, Natural Earth Urban Centers Database") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin) label(5 Boston) label(6 San Francisco) label(7 San Jose))
graph2tex, epsfile(UCSameAssigneeFlows) ht(5) caption(Same Assignee Flows)
graph export UCSameAssigneeFlows.png, replace

graph twoway (connected nother year if region=="Bangalore",  msymbol(d)) (connected nother year if region=="Beijing",  msymbol(t)) ///
	(connected nother year if region=="Tel Aviv-Yafo", mlabel(nother) msymbol(s)) (connected nother year if region=="Austin", mlabel(nother) msymbol(sh)) ///
	(connected nother year if region=="Boston",  msymbol(x)) (connected nother year if region=="San Francisco1",  msymbol(o)) ///
	(connected nother year if region=="San Jose3",  msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Other Flows") ///
	note("Data Source: patentsview.org, Natural Earth Urban Centers Database") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin) label(5 Boston) label(6 San Francisco) label(7 San Jose))
graph2tex, epsfile(UCOtherFlows) ht(5) caption(Other Flows)
graph export UCOtherFlows.png, replace


