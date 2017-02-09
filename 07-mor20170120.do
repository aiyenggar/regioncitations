local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/sms2017-images/
cd `reportdir'
use `destdir'patents_by_region.dta, clear

eststo clear
xtset regionid year

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers"), i(regionid) fe
//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers")
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (MSA-UC)"
est store model1

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid != 188), i(regionid) fe
//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid != 188)
estadd local Groups `e(N_g)'
estadd local Sample "Non-US (MSA-UC)"
est store model2

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid == 188), i(regionid) fe
//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal   lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid != 188)
estadd local Groups `e(N_g)'
estadd local Sample "US Locations (MSA-UC)"
est store model5

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers"), i(regionid) fe 
//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers")
estadd local Groups `e(N_g)'
estadd local Sample "All Locations (MSA-UC)"
est store model3

xtnbreg cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid != 188), i(regionid) fe 
//reg lncit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool d2002-d2012 percentsubcat* if (year>=2001 & year<=2012 & region_source=="MSA-Urban Centers" & countryid != 188)
estadd local Groups `e(N_g)'
estadd local Sample "Non-US (MSA-UC)"
est store model4

esttab model1 model2 using `reportdir'model12.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model12}") ///
		order(cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool ) ///
		label longtable replace wide p(3) not nostar compress nogaps nopa noomitted ///
		drop (d* percent*) scalars("Sample")

esttab model1 model3 using `reportdir'model13.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model13}") ///
		order(cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool ) ///
		label longtable replace wide p(3) not nostar compress nogaps nopa noomitted ///
		drop (d* percent*) scalars("Sample")

esttab model2 model4 using `reportdir'model24.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model24}") ///
		order(cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool ) ///
		label longtable replace wide p(3) not nostar compress nogaps nopa noomitted ///
		drop (d* percent*) scalars("Sample")

esttab model3 model4 using `reportdir'model34.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model34}") ///
		order(cit_recd_total rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal intr_localinternal_ipr_score intr_localexternal_ipr_score intr_nonlocalinternal_ipr_score intr_nonlocalexternal_ipr_score lncit_made_total lnpatents lnpool ) ///
		label longtable replace wide p(3) not nostar compress nogaps nopa noomitted ///
		drop (d* percent*) scalars("Sample")

esttab model1 model5 model2 using `reportdir'model152.tex, ///
		title("Effect of Geographic Distribution of Citations Made on Citations Received \label{model152}") ///
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


graph twoway (connected nla year if region=="Bangalore", mlabel(nla) msymbol(d)) (connected nla year if region=="Beijing", msymbol(t)) ///
	(connected nla year if region=="Tel Aviv-Yafo", msymbol(s)) (connected nla year if region=="Austin-Round Rock, TX", msymbol(sh)) ///
	(connected nla year if region=="Boston-Cambridge-Newton, MA-NH", msymbol(x)) (connected nla year if region=="San Francisco-Oakland-Hayward, CA", msymbol(o)) ///
	(connected nla year if region=="San Jose-Sunnyvale-Santa Clara, CA", mlabel(nla) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Region Same Assignee Flows") ///
	note("Data Source: PatentsView.org, Merged MSA-Natural Earth Data") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin-Round Rock) label(5 Boston-Cambridge-Newton) label(6 San Francisco-Oakland-Hayward) label(7 San Jose-Sunnyvale-Santa Clara))
graph2tex, epsfile(SameRegionSameAssigneeFlows) ht(5) caption(Same Region Same Assignee Flows)
graph export SameRegionSameAssigneeFlows.png, replace

graph twoway (connected nlap year if region=="Bangalore", mlabel(nlap) msymbol(d)) (connected nlap year if region=="Beijing", msymbol(t)) ///
	(connected nlap year if region=="Tel Aviv-Yafo",  msymbol(s)) (connected nlap year if region=="Austin-Round Rock, TX",  msymbol(sh)) ///
	(connected nlap year if region=="Boston-Cambridge-Newton, MA-NH",  msymbol(x)) (connected nlap year if region=="San Francisco-Oakland-Hayward, CA",  msymbol(o)) ///
	(connected nlap year if region=="San Jose-Sunnyvale-Santa Clara, CA", mlabel(nlap) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") /// 
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Region Different Assignee Flows") ///
	note("Data Source: PatentsView.org, Merged MSA-Natural Earth Data") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin-Round Rock) label(5 Boston-Cambridge-Newton) label(6 San Francisco-Oakland-Hayward) label(7 San Jose-Sunnyvale-Santa Clara))
graph2tex, epsfile(SameRegionDiffAssigneeFlows) ht(5) caption(Same Region Different Assignee Flows)
graph export SameRegionDiffAssigneeFlows.png, replace

graph twoway (connected nlpa year if region=="Bangalore", mlabel(nlpa) msymbol(d)) (connected nlpa year if region=="Beijing",  msymbol(t)) ///
	(connected nlpa year if region=="Tel Aviv-Yafo", mlabel(nlpa) msymbol(s)) (connected nlpa year if region=="Austin-Round Rock, TX",  msymbol(sh)) ///
	(connected nlpa year if region=="Boston-Cambridge-Newton, MA-NH",  msymbol(x)) (connected nlpa year if region=="San Francisco-Oakland-Hayward, CA", msymbol(o)) ///
	(connected nlpa year if region=="San Jose-Sunnyvale-Santa Clara, CA",  msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") /// 
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Different Region Same Assignee Flows") ///
	note("Data Source: PatentsView.org, Merged MSA-Natural Earth Data") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin-Round Rock) label(5 Boston-Cambridge-Newton) label(6 San Francisco-Oakland-Hayward) label(7 San Jose-Sunnyvale-Santa Clara))
graph2tex, epsfile(DiffRegionSameAssigneeFlows) ht(5) caption(Different Region Same Assignee Flows)
graph export DiffRegionSameAssigneeFlows.png, replace

graph twoway (connected nlpap year if region=="Bangalore", msymbol(d)) (connected nlpap year if region=="Beijing",  msymbol(t)) ///
	(connected nlpap year if region=="Tel Aviv-Yafo", mlabel(nlpap) msymbol(s)) (connected nlpap year if region=="Austin-Round Rock, TX", msymbol(sh)) ///
	(connected nlpap year if region=="Boston-Cambridge-Newton, MA-NH",  msymbol(x)) (connected nlpap year if region=="San Francisco-Oakland-Hayward, CA",  msymbol(o)) ///
	(connected nlpap year if region=="San Jose-Sunnyvale-Santa Clara, CA", mlabel(nlpap) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///  
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Different Region Different Assignee Flows") ///
	note("Data Source: PatentsView.org, Merged MSA-Natural Earth Data") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin-Round Rock) label(5 Boston-Cambridge-Newton) label(6 San Francisco-Oakland-Hayward) label(7 San Jose-Sunnyvale-Santa Clara))
graph2tex, epsfile(DiffRegionDiffAssigneeFlows) ht(5) caption(Different Region Different Assignee Flows)
graph export DiffRegionDiffAssigneeFlows.png, replace

graph twoway (connected nl year if region=="Bangalore", mlabel(nl) msymbol(d)) (connected nl year if region=="Beijing",  msymbol(t)) ///
	(connected nl year if region=="Tel Aviv-Yafo",  msymbol(s)) (connected nl year if region=="Austin-Round Rock, TX", msymbol(sh)) ///
	(connected nl year if region=="Boston-Cambridge-Newton, MA-NH",  msymbol(x)) (connected nl year if region=="San Francisco-Oakland-Hayward, CA",  msymbol(o)) ///
	(connected nl year if region=="San Jose-Sunnyvale-Santa Clara, CA", mlabel(nl) msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///  
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Region Flows (Aggregated over Assignees)") ///
	note("Data Source: PatentsView.org, Merged MSA-Natural Earth Data") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin-Round Rock) label(5 Boston-Cambridge-Newton) label(6 San Francisco-Oakland-Hayward) label(7 San Jose-Sunnyvale-Santa Clara))
graph2tex, epsfile(SameRegionFlows) ht(5) caption(Same Region Flows)
graph export SameRegionFlows.png, replace

graph twoway (connected na year if region=="Bangalore",  msymbol(d)) (connected na year if region=="Beijing",  msymbol(t)) ///
	(connected na year if region=="Tel Aviv-Yafo", mlabel(na) msymbol(s)) (connected na year if region=="Austin-Round Rock, TX", mlabel(na) msymbol(sh)) ///
	(connected na year if region=="Boston-Cambridge-Newton, MA-NH",  msymbol(x)) (connected na year if region=="San Francisco-Oakland-Hayward, CA",  msymbol(o)) ///
	(connected na year if region=="San Jose-Sunnyvale-Santa Clara, CA",  msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Same Assignee Flows (Aggregated over Regions)") ///
	note("Data Source: PatentsView.org, Merged MSA-Natural Earth Data") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin-Round Rock) label(5 Boston-Cambridge-Newton) label(6 San Francisco-Oakland-Hayward) label(7 San Jose-Sunnyvale-Santa Clara))
graph2tex, epsfile(SameAssigneeFlows) ht(5) caption(Same Assignee Flows)
graph export SameAssigneeFlows.png, replace

graph twoway (connected nother year if region=="Bangalore",  msymbol(d)) (connected nother year if region=="Beijing",  msymbol(t)) ///
	(connected nother year if region=="Tel Aviv-Yafo", mlabel(nother) msymbol(s)) (connected nother year if region=="Austin-Round Rock, TX", mlabel(nother) msymbol(sh)) ///
	(connected nother year if region=="Boston-Cambridge-Newton, MA-NH",  msymbol(x)) (connected nother year if region=="San Francisco-Oakland-Hayward, CA",  msymbol(o)) ///
	(connected nother year if region=="San Jose-Sunnyvale-Santa Clara, CA",  msymbol(oh)), ///
	ytitle("Normalized Citations (percent)") xtitle("Year of Citation") ///
	ylabel(, angle(horizontal)) yscale(titlegap(*+10)) ///
	title("Other Flows") ///
	note("Data Source: PatentsView.org, Merged MSA-Natural Earth Data") ///
	legend(cols(1) label(1 Bangalore) label(2 Beijing) label(3 Tel Aviv-Yafo) label(4 Austin-Round Rock) label(5 Boston-Cambridge-Newton) label(6 San Francisco-Oakland-Hayward) label(7 San Jose-Sunnyvale-Santa Clara))
graph2tex, epsfile(OtherFlows) ht(5) caption(Other Flows)
graph export OtherFlows.png, replace


