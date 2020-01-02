use "/Users/aiyenggar/processed/patents/citation.dta", clear
keep if year_application == 2010 | year_application == 2005 | year_application == 2000
bysort patent_id: keep if _n <= 10
egen myid = group(patent_id)
keep if mod(myid, 17) == 3
drop myid
sort patent_id
export delimited citation268k.csv, replace

use "/Users/aiyenggar/processed/patents/citation.dta", clear
keep if patent_id=="6715423" | patent_id=="7899652" | patent_id=="8166254" | patent_id=="6122808" | patent_id=="6213093" | patent_id=="9226521" | patent_id=="6135089" | patent_id=="7535209" | patent_id=="9226521"
sort patent_id
export delimited citation100.csv, replace

/*
keep if cnt_assignee <= 3
keep if all_patents_cited <= 10
keep if cnt_inventor > 1 & cnt_inventor < 5

6715423 No pre-cutoff patents, 3 patents cited, 2 assignees, 2 inventors (Tokyo, Koganei)
7899652 No pre-cutoff patents, 4 patents cited, 2 assignees, 3 inventors (1 AL, 2 MI)
8166254 1 pre-cutoff patent, 8 patents cited, 1 assignee, 3 inventors (3 MN) - Q5 example, single type flows
9226521
6213093
*/
