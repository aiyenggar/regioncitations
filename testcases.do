use "/Users/aiyenggar/processed/patents/citation.dta", clear
keep if patent_application_year == 2010 | patent_application_year == 2005 | patent_application_year == 2000
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

use "/Users/aiyenggar/processed/patents/citation.dta", clear
gen kp = 1 if citation_id=="7042440" 
replace kp = 0 if missing(kp)
bysort patent_id: replace kp = sum(kp)
by patent_id: replace kp = kp[_N]
keep if kp != 0
drop kp
export delimited citation200k.csv, replace

use "/Users/aiyenggar/processed/patents/citation.dta", clear
keep if patent_id == "4478836" | patent_id == "6108066" | patent_id == "6116691" | patent_id == "6124731" | patent_id == "6120002" | patent_id == "6122539" | patent_id == "6126790" | patent_id == "9460691" | patent_id == "3930680" | patent_id == "4368286" | patent_id == "3930513" | patent_id == "3931910" | patent_id == "5046259"
save test_citation.dta, replace
levelsof patent_id, local(files)
foreach f of local files {
	export delimited `f'-citation.csv if patent_id=="`f'", replace
	}

/* 
9460691 receives no citations
8227965 has multiple inventors across 2 locations US and JP 
3930513 shows a less than 1 flow
*/
/*
7042440 for dv
keep if cnt_assignee <= 3
keep if all_patents_cited <= 10
keep if cnt_inventor > 1 & cnt_inventor < 5

6715423 No pre-cutoff patents, 3 patents cited, 2 assignees, 2 inventors (Tokyo, Koganei)
7899652 No pre-cutoff patents, 4 patents cited, 2 assignees, 3 inventors (1 AL, 2 MI)
8166254 1 pre-cutoff patent, 8 patents cited, 1 assignee, 3 inventors (3 MN) - Q5 example, single type flows
9226521
6213093
*/
