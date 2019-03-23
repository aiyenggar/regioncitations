/* This file has the code to generate regression results for papers sent out 2019 and later*/

local sampleendyear = 2010
local citationcategorystartyear = 2002
local allcitationscategory = 100
local applicantcitationscategory = 2
local examinercitationscategory = 3
local quintile_levels 5
local geosample "ua3"
local distest "dis"
//local distest "nod"
local inputprefix "20190314-`geosample'"
local fileprefix = "`inputprefix'-`distest'"
local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/
local sourcefile `destdir'`fileprefix'-urbanarea-year-estimation.dta
local mid=1
est drop _all

/*
One table with:
Model 1: DV - All Received. All. samplestartyear onward. All.
Model 2: DV - All Received. U.S. Locations. samplestartyear onward. All.
Model 3: DV - All Received. Non-U.S. Locations. samplestartyear onward. All.
Model 4: DV - Nonself Citations Received. All. samplestartyear onward. All.
Model 5: DV - All Received. All. citationcategorystartyea onward. All.
Model 6: DV - All Received. All. citationcategorystartyear onward. Applicant Citations.
Model 7: DV - All Received. All. citationcategorystartyear onward. Examiner Citations.
*/

local stylelist "ALL UNIQ"
foreach style of local stylelist {
	local yearlist "1980 1990"
	foreach samplestartyear of local yearlist {
		local mlist=""
		use `sourcefile', clear
		keep if citation_type==`allcitationscategory' & countstyle=="`style'"
		xtset uaid year
		local yearmin = `samplestartyear'
		local dyearstart = `yearmin'+1
		local yearmax = `sampleendyear'

		xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
		estadd local Groups `e(N_g)'
		estadd local Locations "All"
		estadd local PeriodStart `yearmin'
		estadd local PeriodEnd `yearmax'
		estadd local Citations "All"
		estadd local FlowCount "`style'"
		estadd local Model "`mid'"
		local modelname = "Model`mid'"
		local mid=`mid'+1
		est store `modelname'
		local mlist="`mlist' `modelname'"
		local myfileprefix = "`fileprefix'-`modelname'"
		corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
		filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
		sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
		filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace

		xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country=="US"), i(uaid) fe
		estadd local Groups `e(N_g)'
		estadd local Locations "U.S."
		estadd local PeriodStart `yearmin'
		estadd local PeriodEnd `yearmax'
		estadd local Citations "All"
		estadd local FlowCount "`style'"
		estadd local Model "`mid'"
		local modelname = "Model`mid'"
		local mid=`mid'+1
		est store `modelname'
		local mlist="`mlist' `modelname'"
		local myfileprefix = "`fileprefix'-`modelname'"
		corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
		filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
		sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
		filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace


		xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & country!="US"), i(uaid) fe
		estadd local Groups `e(N_g)'
		estadd local Locations "Non-U.S."
		estadd local PeriodStart `yearmin'
		estadd local PeriodEnd `yearmax'
		estadd local Citations "All"
		estadd local FlowCount "`style'"
		estadd local Model "`mid'"
		local modelname = "Model`mid'"
		local mid=`mid'+1
		est store `modelname'
		local mlist="`mlist' `modelname'"
		local myfileprefix = "`fileprefix'-`modelname'"
		corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
		filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
		sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
		filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace


		xtnbreg cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
		estadd local Groups `e(N_g)'
		estadd local Locations "All"
		estadd local PeriodStart `yearmin'
		estadd local PeriodEnd `yearmax'
		estadd local Citations "All"
		estadd local FlowCount "`style'"
		estadd local Model "`mid'"
		local modelname = "Model`mid'"
		local mid=`mid'+1
		est store `modelname'
		local mlist="`mlist' `modelname'"
		local myfileprefix = "`fileprefix'-`modelname'"
		corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
		filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
		sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
		filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace


		local yearmin = `citationcategorystartyear'
		local dyearstart = `yearmin'+1
		local yearmax = `sampleendyear'

		use `sourcefile', clear
		keep if citation_type==`allcitationscategory' & countstyle=="`style'"
		xtset uaid year
		xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
		estadd local Groups `e(N_g)'
		estadd local Locations "All"
		estadd local PeriodStart `yearmin'
		estadd local PeriodEnd `yearmax'
		estadd local Citations "All"
		estadd local FlowCount "`style'"
		estadd local Model "`mid'"
		local modelname = "Model`mid'"
		local mid=`mid'+1
		est store `modelname'
		local mlist="`mlist' `modelname'"
		local myfileprefix = "`fileprefix'-`modelname'"
		corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
		filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
		sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
		filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace

		use `sourcefile', clear
		keep if citation_type==`applicantcitationscategory' & countstyle=="`style'"
		xtset uaid year
		xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
		estadd local Groups `e(N_g)'
		estadd local Locations "All"
		estadd local PeriodStart `yearmin'
		estadd local PeriodEnd `yearmax'
		estadd local Citations "Applicant"
		estadd local FlowCount "`style'"
		estadd local Model "`mid'"
		local modelname = "Model`mid'"
		local mid=`mid'+1
		est store `modelname'
		local mlist="`mlist' `modelname'"
		local myfileprefix = "`fileprefix'-`modelname'"
		corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
		filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
		sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
		filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace

		use `sourcefile', clear
		keep if citation_type==`examinercitationscategory' & countstyle=="`style'"
		xtset uaid year
		xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax'), i(uaid) fe
		estadd local Groups `e(N_g)'
		estadd local Locations "All"
		estadd local PeriodStart `yearmin'
		estadd local PeriodEnd `yearmax'
		estadd local Citations "Examiner"
		estadd local FlowCount "`style'"
		estadd local Model "`mid'"
		local modelname = "Model`mid'"
		local mid=`mid'+1
		est store `modelname'
		local mlist="`mlist' `modelname'"
		local myfileprefix = "`fileprefix'-`modelname'"
		corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
		filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
		sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
		filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace

		esttab `mlist' using temp.tex, ///
				title("Negative Binomial Regression Analysis of Invention Quality \label{`fileprefix'-model}") ///
				label replace p(3) not nostar noomitted compress nogaps ///
				drop (d* percent*) scalars("Groups" "Locations" "PeriodStart" "PeriodEnd" "Citations" "FlowCount" "Model") addnotes("Reference category is Share Citations Made[Different Urban Area, Different Assignee]" "All models include region fixed effects, year dummies and technology subcategory controls")
		filefilter temp.tex `reportdir'`fileprefix'-`style'-`samplestartyear'-base-model.tex, from("{table}") to("{sidewaystable}") replace

		/* pool table */

		use `sourcefile', clear
		keep if citation_type==`allcitationscategory' & countstyle=="`style'"
		xtset uaid year

		local yearmin = `samplestartyear'
		local dyearstart = `yearmin'+1
		local yearmax = `sampleendyear'
		xtile quintile=pat_pool, n(`quintile_levels')
		order pat_pool quintile
		local mlist ""
		levels quintile, local(qlevel)
		foreach l of local qlevel {
			local percent = (`quintile_levels'-`l'+1)*100/`quintile_levels'
			local pooldesc "Top-`percent'-percent"
			xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & quintile >= `l'), i(uaid) fe
			estadd local Groups `e(N_g)'
			estadd local Locations "All"
			estadd local PeriodStart `yearmin'
			estadd local PeriodEnd `yearmax'
			estadd local Citations "All"
			estadd local PatentPool `pooldesc'
			estadd local FlowCount "`style'"
			estadd local Model "`mid'"
			local modelname = "Model`mid'"
			local mid=`mid'+1
			est store `modelname'
			local mlist="`mlist' `modelname'"
			local myfileprefix = "`fileprefix'-`modelname'"
			corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
			filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
			sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
			filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace
		}

		esttab `mlist' using temp.tex, ///
				title("Negative Binomial Regression Analysis of Invention Quality \label{`fileprefix'-model}") ///
				label replace p(3) not nostar noomitted compress nogaps ///
				drop (d* percent*) scalars("Groups" "Locations" "PeriodStart" "PeriodEnd" "Citations" "PatentPool" "FlowCount" "Model") addnotes("Reference category is Share Citations Made[Different Urban Area, Different Assignee]" "All models include region fixed effects, year dummies and technology subcategory controls")
		filefilter temp.tex `reportdir'`fileprefix'-`style'-`samplestartyear'-quintile-model.tex, from("{table}") to("{sidewaystable}") replace
	}
}
