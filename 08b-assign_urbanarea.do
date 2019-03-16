global destdir ~/processed/patents/
global date : display %tdCYND daily("$S_DATE", "DMY")

use ${destdir}citation.dta, clear
sort application_year patent_id
export delimited using ${destdir}${date}-citation.csv, replace

use ${destdir}patent_assignee_year.dta, clear
keep patent_id assignee_numid
tostring assignee_numid, generate(assigneelist)
bysort patent_id: replace assigneelist = assigneelist[_n-1] + "," + assigneelist if _n > 1
bysort patent_id: keep if _n == _N
drop assignee_numid
save ${destdir}${date}-assignee.dta, replace

// global uacut "ua3 ua2 ua1"
global uacut "ua3"
foreach uastr in $uacut {
	di "Beginning `uastr'"
	
	/* The urban area attribution strategy goes here, also used in 09-patent-urbanarea.do */
	use ${destdir}patent_inventor_urbanarea.dta, clear
	gen uaid = `uastr'
	/* country as received from patent_inventor_urbanarea.dta (source rawlocation.dta) is not fully reliable */
	/* this step is out of step, in that the basic processing needs to be done before uaid_country.dta is available */
	rename country rawcountry
	/* uaid_country.dta should ideally be generated from the naturalearth data */
	merge m:1 uaid using ${destdir}uaid_country.dta, keep(match master) nogen
	drop urban_area /* save space, uaid will do the job */
	sort patent_id
	save ${date}-`uastr'-patent.dta, replace

	keep patent_id inventor_id uaid latlongid
	tostring uaid, generate(ualist)
	bysort patent_id: replace ualist = ualist[_n-1] + "," + ualist if _n > 1

	tostring latlongid, generate(latlonglist)
	bysort patent_id: replace latlonglist = latlonglist[_n-1] + "," + latlonglist if _n > 1

	bysort patent_id: keep if _n == _N
	drop inventor_id uaid latlongid
	save ${destdir}${date}-`uastr'-inventor.dta, replace
	
	use ${destdir}${date}-assignee.dta, clear
	merge 1:1 patent_id using ${destdir}${date}-`uastr'-inventor.dta
	/* We are missing assignee information for 6,807 patents (_merge==2) */
	/* We are missing inventor information for 868 patents (_merge==1) */
	drop _merge
	export delimited ${destdir}${date}-`uastr'-patent_list_location_assignee.csv, replace
}
