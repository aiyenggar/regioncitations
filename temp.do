levels nber_cat, local(catlev)
foreach icat of local catlev {
	bysort uaid year: gen runsumcat`icat'=sum(1)  if nber_cat==`icat'
	replace runsumcat`icat'=0 if missing(runsumcat`icat')
	bysort uaid year: egen cat`icat'=max(runsumcat`icat')
	drop runsumcat`icat'
}

levels nber_subcat, local(subcatlev)
foreach l of local subcatlev {
	bysort uaid year: gen runsumsubcat`l'=sum(1)  if nber_subcat==`l'
	replace runsumsubcat`l'=0 if missing(runsumsubcat`l')
	bysort uaid year: egen subcat`l'=max(runsumsubcat`l')
	drop runsumsubcat`l'
}


foreach var of varlist classidcnt* {
  gen f`var' = `var'/pat_cnt
  gen fsq`var' = f`var'*f`var'
}

egen techclass_focus = rowtotal(fsq*)
gen techclass_diversity = 1 - techclass_focus
drop fclassidcnt* fsqclassidcnt* classidcnt*

foreach var of varlist cat* subcat* {
  gen d`var' = 1 if `var' > 0
  replace d`var' = 0 if missing(d`var')
}


levels class_numid, local(classlev)
foreach l of local classlev {
	di "Processing class_numid `l'"
	bysort uaid year: gen runsumclass`l'=sum(1)  if class_numid==`l'
	replace runsumclass`l'=0 if missing(runsumclass`l')
	bysort uaid year: egen classidcnt`l'=max(runsumclass`l')
	drop runsumclass`l'
}


keep *year patent_id citation_id
bysort application_year: gen num_patents_year=_N
bysort application_year citation_year: gen num_patents_cited=_N
bysort application_year citation_year: keep if _n==1
drop patent_id citation_id
gen percent_missing= (num_patents_cited*100)/num_patents_year
save years2.dta, replace
