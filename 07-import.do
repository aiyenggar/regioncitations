set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/patents/
cd `destdir'

/*
 Number of lines in each of the input files (for later comparison with .dta file)
  127783 latlong_urbanareas.tsv
 6647700 application.tsv
  389247 assignee.tsv
  128948 location.tsv
 5105938 nber.tsv
 6647700 patent.tsv
 5902218 patent_assignee.tsv
 15752164 patent_inventor.tsv
 5903412 rawassignee.tsv
 15752111 rawinventor.tsv
 24991550 rawlocation.tsv (24,987,652 not missing latitude or longitude)
 94726691 uspatentcitation.tsv
 22880878 uspc_current.tsv
*/

/* Import the latlong to urbanarea mapping generated through the 
QGIS spatial join and filling for nearby locations */
import delimited `destdir'filled_urbanarea.csv, varnames(1) encoding(ISO-8859-1) clear
gen urban_area2 = urban_area
replace urban_area2 = near_urbanarea if missing(urban_area) & mindist < 60.01
gen distance = mindist if missing(urban_area) & mindist < 60.01
summ distance
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
    distance |     77,916    22.55609    14.29296        .09      60.01
*/
order urban_area urban_area2 distance latlong
drop v1 latitude longitude mindist near_latlong near_urbanarea
sort latlong
save latlong_urbanarea.dta, replace

// Import cleaned/raw files from patentsview
import delimited `datadir'application.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save application.dta, replace

import delimited `datadir'assignee.tsv, varnames(1) encoding(UTF-8) clear
rename id assignee_id
save assignee.dta, replace

import delimited `datadir'location.tsv, varnames(1) encoding(UTF-8) clear
save location.dta, replace

import delimited `datadir'nber.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save `destdir'nber.dta, replace

import delimited `datadir'patent_assignee.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save patent_assignee.dta, replace

import delimited `datadir'patent_inventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save patent_inventor.dta, replace

import delimited `datadir'patent.tsv, varnames(1) encoding(UTF-8) clear
rename id patent_id
sort patent_id
save patentwithabstract.dta, replace
drop abstract
save patent.dta, replace

import delimited `datadir'rawassignee.tsv, varnames(1) encoding(UTF-8) clear
save rawassignee.dta, replace

import delimited `datadir'rawinventor.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id sequence
save rawinventor.dta, replace

import delimited `datadir'uspatentcitation.tsv, varnames(1) encoding(UTF-8) clear
save uspatentcitationfull.dta, replace
drop uuid name country
save uspatentcitation.dta, replace

use `destdir'uspatentcitation.dta
export delimited using uspatentcitation.csv, replace

preserve
keep if category == "cited by applicant"
save a.uspatentcitation.dta, replace
export delimited using a.uspatentcitation.csv, replace

restore
preserve
keep if category == "cited by examiner"
save e.uspatentcitation.dta, replace
export delimited using e.uspatentcitation.csv, replace

restore
preserve
keep if category == "cited by other"
save o.uspatentcitation.dta, replace
export delimited using o.uspatentcitation.csv, replace

restore
preserve
keep if category == "cited by third party"
save t.uspatentcitation.dta, replace
export delimited using t.uspatentcitation.csv, replace

restore
keep if category == "NULL"
save n.uspatentcitation.dta, replace
export delimited using n.uspatentcitation.csv, replace
