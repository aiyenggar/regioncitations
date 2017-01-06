cap log close
log using knowledge-flows.log, append
set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/knowledge-flows-images/
cd `reportdir'


// rawinventor_region is inventor data for each patent, no filtering for 2012 or before
use `destdir'rawinventor_region.dta, clear
count if missing(region)
// 78 of 13,734,673 because of missing region
count if !missing(region)
// 13,734,595 of 13,734,673

gen region_known = 1 if !missing(region)
replace region_known = 0 if missing(region_known)

bysort patent_id: egen sum_region_known = sum(region_known)
bysort patent_id: gen num_inventors=_N
bysort patent_id: gen index=_n
drop region_known
keep if index==1
//keep patent_id region region_source  year sum_region_known num_inventors

codebook num_inventors
// range [1, 76] 49 unique values. 90% percentile is 4 inventors

count if num_inventors > 10
// 21,431 patents with greater than 10 inventors

count if num_inventors == sum_region_known
codebook country
// unique values:  191                      missing "":  89,689/5,915,050
codebook region_source
// 5,914,976 of 5,915,050 patents (%) have all inventors' region information available
// 4,907,123  "MSA-Urban Centers"
// 918,355  "PatentsView"
// 89,572  "rawlocation.tsv (PatentsView)"


count if sum_region_known == 0
// 7 of 5,915,050 patents (%) are such that none of the inventor regions are within the MSA/Urban Centres database

count if num_inventors == 1
// 2,458,926 of 5,915,050 patents (41.57%) are invented by a single inventor
count if num_inventors == 2
// 1,461,199 of 5,915,050 patents (24.70%) are invented by two inventors
count if num_inventors == 3
// 912,297 of 5,915,050 patents (15.42%) are invented by three inventors
count if num_inventors == 4
// 516,619 of 5,915,050 patents (8.73%) are invented by four inventors
count if num_inventors >= 5
// 566,009 of 5,915,050 patents (9.56%) are invented by five or more inventors

count if (sum_region_known == 0 & num_inventors == 1)
// 5 of 5,915,050 patents (%) of patents are single inventor patents, the region of the inventor of which is unavailable

hist num_inventors if sum_region_known == 0, discrete width(1) percent
codebook num_inventors if sum_region_known == 0
// 2 unique values in the range [1,2] among the 7 patents that we do not have region information on

count if (num_inventors-1) == sum_region_known
// 70 of 5,915,050 patents (%) patents have one inventor's region unknown
hist year if (num_inventors-1) == sum_region_known, discrete width(1) percent

count if (num_inventors-2) == sum_region_known
// 4 of 5,915,050 patents (%) patents have two inventor's region unknown
hist year if (num_inventors-2) == sum_region_known, discrete width(1) percent

count if (num_inventors-3) >= sum_region_known
// 0 of 5,915,050 patents (%) patents have three or more inventor's region unknown

count  if (year < 1976 | year > 2012)
// 417,178 patents with years outside the bracket of interest. Many are absurd years, probably typos

set more off
local destdir /Users/aiyenggar/datafiles/patents/
local reportdir /Users/aiyenggar/OneDrive/code/articles/knowledge-flows-images/
cd `reportdir'

use `destdir'rawinventor_region.dta, clear

bysort patent_id region: gen patent_region_index=_n
bysort region year: gen total_region_count=_N
keep if patent_region_index == 1
bysort region year: gen patent_region_count=_N
bysort region year: gen region_index = _n
keep if region_index == 1
drop inventor_id
gen average_count_per_patent = total_region_count/patent_region_count

gen neg = -total_region_count
sort neg
keep region region_source total_region_count patent_region_count average_count_per_patent year country

drop if (year < 1976 | year > 2012)
// drop if total_region_count < 15

replace country="Hong Kong" if (region=="Hong Kong" & country!="Hong Kong")
merge m:1 country using `destdir'country_ipr.dta, keep(match) nogenerate

egen yrank = rank(-patent_region_count), by(year)

graph hbar patent_region_count if (yrank <= 10 & year==2007), over(region, sort(yrank year)) ytitle("Number of patents") title("Top Inventor Locations (2007)")
graph2tex, epsfile(2007top10) ht(5) caption(Top Inventor Locations (2007))

graph hbar patent_region_count if (yrank <= 10 & year==2008), over(region, sort(yrank year)) ytitle("Number of patents") title("Top Inventor Locations (2008)")
graph2tex, epsfile(2008top10) ht(5) caption(Top Inventor Locations (2008))

graph hbar patent_region_count if (yrank <= 10 & year==2009), over(region, sort(yrank year)) ytitle("Number of patents") title("Top Inventor Locations (2009)")
graph2tex, epsfile(2009top10) ht(5) caption(Top Inventor Locations (2009))

graph hbar patent_region_count if (yrank <= 10 & year==2010), over(region, sort(yrank year)) ytitle("Number of patents") title("Top Inventor Locations (2010)")
graph2tex, epsfile(2010top10) ht(5) caption(Top Inventor Locations (2010))

graph hbar patent_region_count if (yrank <= 10 & year==2011), over(region, sort(yrank year)) ytitle("Number of patents") title("Top Inventor Locations (2011)")
graph2tex, epsfile(2011top10) ht(5) caption(Top Inventor Locations (2011))

graph hbar patent_region_count if (yrank <= 10 & year==2012), over(region, sort(yrank year)) ytitle("Number of patents") title("Top Inventor Locations (2012)")
graph2tex, epsfile(2012top10) ht(5) caption(Top Inventor Locations (2012))

sort region year
bysort region: gen cumulative=sum(patent_region_count)

egen iregion = group(region)
// 72,845 unique regions

tsset iregion year, yearly
gen sum3 = L3.patent_region_count + L2.patent_region_count + L1.patent_region_count
gen sum5 = L5.patent_region_count + L4.patent_region_count + L3.patent_region_count + L2.patent_region_count + L1.patent_region_count

gen rate3 = (patent_region_count*100)/sum3
egen yrank3 = rank(-rate3), by(year)
gen rate5 = (patent_region_count*100)/sum5
egen yrank5 = rank(-rate5), by(year)

graph hbar rate5 if (yrank5 <= 10 & year==2010), over(region, sort(yrank5 year)) ytitle("Patenting Rate relative to 5 Year Sum") title("Top Inventor Locations (2010)")
graph2tex, epsfile(r52010top10) ht(5) caption(Top Inventor Locations (2010))

graph hbar rate5 if (yrank5 <= 10 & year==2011), over(region, sort(yrank5 year)) ytitle("Patenting Rate relative to 5 Year Sum") title("Top Inventor Locations (2011)")
graph2tex, epsfile(r52011top10) ht(5) caption(Top Inventor Locations (2011))

graph hbar rate5 if (yrank5 <= 10 & year==2012), over(region, sort(yrank5 year)) ytitle("Patenting Rate relative to 5 Year Sum") title("Top Inventor Locations (2012)")
graph2tex, epsfile(r52012top10) ht(5) caption(Top Inventor Locations (2012))

graph hbar rate3 if (yrank3 <= 10 & year==2010), over(region, sort(yrank3 year)) ytitle("Patenting Rate relative to 3 Year Sum") title("Top Inventor Locations (2010)")
graph2tex, epsfile(r32010top10) ht(5) caption(Top Inventor Locations (2010))

graph hbar rate3 if (yrank3 <= 10 & year==2011), over(region, sort(yrank3 year)) ytitle("Patenting Rate relative to 3 Year Sum") title("Top Inventor Locations (2011)")
graph2tex, epsfile(r32011top10) ht(5) caption(Top Inventor Locations (2011))

graph hbar rate3 if (yrank3 <= 10 & year==2012), over(region, sort(yrank3 year)) ytitle("Patenting Rate relative to 3 Year Sum") title("Top Inventor Locations (2012)")
graph2tex, epsfile(r32012top10) ht(5) caption(Top Inventor Locations (2012))

save `destdir'patents_by_region.dta, replace
export delimited using `destdir'patents_by_region.csv, replace

log close


cd /Users/aiyenggar/datafiles/patents/
use "/Users/aiyenggar/datafiles/patents/patents_by_region.dta", clear

