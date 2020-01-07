set more off
local datadir ~/data/20180528-patentsview/
local destdir ~/processed/regioncitations/
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

// Import cleaned/raw files from patentsview
import delimited `datadir'application.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save application.dta, replace

import delimited `datadir'nber.tsv, varnames(1) encoding(UTF-8) clear
sort patent_id
save `destdir'nber.dta, replace

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
drop uuid name country
replace citation_id = trim(citation_id)
compress citation_id
save uspatentcitation.dta, replace

import delimited `datadir'uspc_current.tsv, varnames(1) encoding(UTF-8) clear
drop uuid
save uspc_current.dta, replace

import delimited `datadir'cpc_current.tsv, varnames(1) encoding(UTF-8) clear
drop uuid
rename subsection_id class_id
rename group_id subclass_id
split subgroup_id, g(group_id) parse(/)
gen maingroup_id = group_id1 + "/00"
gen twodigsubgroup_id = group_id1 + "/" + substr(group_id2,1,2)
rename group_id1 slashprior_id
rename group_id2 slashpost_id
tostring patent_id, replace
sort patent_id
order patent_id section_id class_id subclass_id maingroup_id subgroup_id twodigsubgroup_id
save cpc_current.dta, replace

import delimited `datadir'cpc_group.tsv,  varnames(1) encoding(UTF-8) clear
sort id
rename id subclass_id
save cpc_subclass.dta, replace

import delimited `datadir'cpc_subgroup.tsv,  varnames(1) encoding(UTF-8) clear
sort id
rename id subgroup_id
split subgroup_id, g(group_id) parse(/)
gen maingroup_id = group_id1 + "/00"
rename group_id1 slashprior_id
rename group_id2 slashpost_id
order subgroup_id maingroup_id title
save cpc_subgroup.dta, replace
