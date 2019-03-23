/* This file has the code to generate regression results interactions with technology diversification measures */

local sampleendyear = 2010
local citationcategorystartyear = 2002
local allcitationscategory = 100
local applicantcitationscategory = 2
local examinercitationscategory = 3
local quintile_levels 10
local geosample "ua3"
local distest "dis"
local inputprefix "20190314-`geosample'"
local fileprefix = "`inputprefix'-`distest'"
local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/
local sourcefile `destdir'`fileprefix'-urbanarea-year-estimation.dta
local mid=49
est drop _all

local stylelist "ALL UNIQ"
foreach style of local stylelist {
	local yearlist "1980 1990"
	foreach samplestartyear of local yearlist {
		local divlist "uspc_diversification nber_cat_diversification nber_subcat_diversification"
			foreach divvar of local divlist {
				local mlist=""
				use `sourcefile', clear
				keep if citation_type==`allcitationscategory' & countstyle=="`style'"
				xtset uaid year
				local yearmin = `samplestartyear'
				local dyearstart = `yearmin'+1
				local yearmax = `sampleendyear'
				xtile quintile=pat_pool, n(`quintile_levels')

				/* Generate interaction variables */
				gen div=`divvar'
				label variable div "Technology Diversification"
				gen sqdiv=div*div
				label variable sqdiv "Square(Technology Diversification)"
				gen intq1=rcit_made_localinternal * div
				label variable intq1 "1 x Technology Diversification"
				gen sqintq1=rcit_made_localinternal * sqdiv
				label variable sqintq1 "1 x sq(Technology Diversification)"
				gen intq2=rcit_made_localexternal * div
				label variable intq2 "2 x Technology Diversification"
				gen sqintq2=rcit_made_localexternal * sqdiv
				label variable sqintq2 "2 x sq(Technology Diversification)"
				gen intq4=rcit_made_nonlocalinternal * div
				label variable intq4 "3 x Technology Diversification"
				gen sqintq4=rcit_made_nonlocalinternal * sqdiv
				label variable sqintq4 "3 x sq(Technology Diversification)"
				gen intq5=rcit_made_other * div
				label variable intq5 "4 x Technology Diversification"
				gen sqintq5=rcit_made_other * sqdiv
				label variable sqintq5 "4 x sq(Technology Diversification)"
				/* Completed generating variables */

				local varlist "1 10"
				foreach l of local varlist {
					local percent = (`quintile_levels'-`l'+1)*100/`quintile_levels'
					local pooldesc "Top-`percent'-percent"
					xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & quintile >= `l'), i(uaid) fe
					estadd local Groups `e(N_g)'
					estadd local Locations "All"
					estadd local PeriodStart `yearmin'
					estadd local PeriodEnd `yearmax'
					estadd local Citations "All"
					estadd local FlowCount "`style'"
					estadd local PatentPool `pooldesc'
					estadd local Technology "`divvar'"
					estadd local Model "`mid'"
					local modelname = "Model`mid'"
					local mid=`mid'+1
					est store `modelname'
					local mlist="`mlist' `modelname'"
					local myfileprefix = "`fileprefix'-`modelname'"
					corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other div sqdiv lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
					filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
					sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  div sqdiv lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
					filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace

					xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other div intq1 intq2 intq4 intq5 lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & quintile >= `l'), i(uaid) fe
					estadd local Groups `e(N_g)'
					estadd local Locations "All"
					estadd local PeriodStart `yearmin'
					estadd local PeriodEnd `yearmax'
					estadd local Citations "All"
					estadd local FlowCount "`style'"
					estadd local Technology "`divvar'"
					estadd local Model "`mid'"
					local modelname = "Model`mid'"
					local mid=`mid'+1
					est store `modelname'
					local mlist="`mlist' `modelname'"
					local myfileprefix = "`fileprefix'-`modelname'"
					corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other div sqdiv lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
					filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
					sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  div sqdiv lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
					filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace

					xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other div intq1 intq2 intq4 intq5 sqintq1 sqdiv sqintq2 sqintq4 sqintq5 lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & quintile >= `l'), i(uaid) fe
					estadd local Groups `e(N_g)'
					estadd local Locations "All"
					estadd local PeriodStart `yearmin'
					estadd local PeriodEnd `yearmax'
					estadd local Citations "All"
					estadd local FlowCount "`style'"
					estadd local Technology "`divvar'"
					estadd local Model "`mid'"
					local modelname = "Model`mid'"
					local mid=`mid'+1
					est store `modelname'
					local mlist="`mlist' `modelname'"
					local myfileprefix = "`fileprefix'-`modelname'"
					corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other div sqdiv lnpool if e(sample) == 1, file(temp.tex) digits(2) noscreen   key(`myfileprefix'-correlation) title("Correlations and Summary Statistics (`modelname')") replace  
					filefilter temp.tex `reportdir'`myfileprefix'-correlation.tex, from("{table}") to("{sidewaystable}") replace
					sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  div sqdiv lnpool if e(sample) == 1, minmax file(temp.tex) labels key(`myfileprefix'-summary) title("Summary Statistics (`modelname')") replace 
					filefilter temp.tex `reportdir'`myfileprefix'-summary.tex, from("{table}") to("{sidewaystable}") replace
				} /* quintile list */						
				esttab `mlist' using temp.tex, ///
				title("Negative Binomial Regression Analysis of Invention Quality (All Locations, All Citations, `yearmin'-`yearmax', `divvar') \label{`fileprefix'-model}") ///
				label replace p(3) not nostar noomitted compress nogaps ///
				drop (d* percent*) scalars("Groups" "PatentPool" "FlowCount" "Model" "Technology") addnotes("Reference category is Share Citations Made[Different Urban Area, Different Assignee]" "All models include region fixed effects, year dummies and technology subcategory controls")
				filefilter temp.tex `reportdir'`fileprefix'-`style'-`samplestartyear'-`divvar'-interactions-model.tex, from("{table}") to("{sidewaystable}") replace
			} /* diversification */
	} /* samplestartyear */
} /* countstyle */
