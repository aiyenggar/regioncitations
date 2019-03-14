/* This file has the code to generate regression results various patent pool sized samples*/

/*
For each of two measures of a pool size cutoff
One table with:
Model 1: All regions
Model 2: Top 80% of regions
Model 3: Top 60% of regions
Model 4: Top 40% of regions
Model 5: Top 20% of regions
*/

local destdir /Users/aiyenggar/processed/patents/
local reportdir /Users/aiyenggar/code/articles/kf-results/
est drop _all
cd `reportdir'
local geosample "ua3"
local calcsample "True"

local inputprefix "20190314-`geosample'"
local distest "CalcDist`calcsample'"
local legendsample " (Mapping: `geosample', Distance Calculation: `calcsample')"
local sourcefile `destdir'`inputprefix'-`distest'-urbanarea-year-estimation.dta
local poolcutoff "PoolCutOff-Absolute"
//local poolcutoff "PoolCutOff-Terminal"

use `sourcefile', clear
keep if citation_type==100
xtset uaid year
local yearmin = 1990
local dyearstart = `yearmin'+1
local yearmax = 2013
local quintile_levels 5

xtile quintile=pat_pool, n(`quintile_levels')
order pat_pool quintile

levels quintile, local(qlevel)
foreach l of local qlevel {
	local percent = (`quintile_levels'-`l'+1)*100/`quintile_levels'
	
	xtnbreg cit_recd_total  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_other lnpool d`dyearstart'-d`yearmax' percentsubcat* if (year>=`yearmin' & year<=`yearmax' & quintile >= `l'), i(uaid) fe
	estadd local Groups `e(N_g)'
	estadd local SampleLocation "All Locations"
	estadd local SamplePeriod "`yearmin'-`yearmax'"
	estadd local SampleCitations "All Citations"
	local pooldesc "Top-`percent'-percent"
	estadd local SamplePool `pooldesc'
	est store model`l'
	
	corrtex cit_recd_total cit_recd_nonself  rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal rcit_made_other lncit_made_total lnpatents lnpool if e(sample) == 1, file(`reportdir'`inputprefix'-`yearmin'-`distest'-`poolcutoff'-`pooldesc'-correlation.tex) digits(2) no key(`inputprefix'-`yearmin'-`distest'-`poolcutoff'-`pooldesc'-correlation) title("Correlations and Summary Statistics (Sample:`inputprefix'-`yearmin'-`distest'-`poolcutoff'-`pooldesc')") replace  
	sutex cit_recd_total cit_recd_nonself   rcit_made_localinternal rcit_made_localexternal rcit_made_nonlocalinternal rcit_made_nonlocalexternal  rcit_made_other  lncit_made_total lnpatents lnpool if e(sample) == 1, minmax file(`reportdir'`inputprefix'-`yearmin'-`distest'-`poolcutoff'-`pooldesc'-summary.tex) labels key(`inputprefix'-`yearmin'-`distest'-`poolcutoff'-`pooldesc'-summary) title("Summary Statistics (Sample:`inputprefix'-`distest'-`poolcutoff'-`yearmin'-`pooldesc')") replace 
}

esttab model*  using `reportdir'`inputprefix'-`yearmin'-`distest'-`poolcutoff'-Levels`quintile_levels'-model.tex, ///
		title("Negative Binomial Regression Analysis of Invention Quality \label{`inputprefix'-`distest'-`poolcutoff'-Levels`quintile_levels'-model}") ///
		label replace p(3) not nostar noomitted compress nogaps ///
		drop (d* percent*) scalars("Groups" "SampleLocation" "SamplePeriod" "SampleCitations" "SamplePool") addnotes("All models include region fixed effects, year dummies and technology subcategory controls")

