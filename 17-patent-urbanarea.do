global destdir ~/processed/patents/
global date : display %tdCYND daily("$S_DATE", "DMY")
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
	sort patent_id inventor_id
	save ${date}-`uastr'-patent.dta, replace
	
	keep patent_id inventor_id uaid latlongid
	export delimited ${date}-`uastr'-patent.csv, replace
}
