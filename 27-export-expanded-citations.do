local destdir "/Users/aiyenggar/processed/patents/"

local varlist "1 2 3 4 5 6 7"
foreach l of local varlist {
	import delimited "`destdir'20190314-ua3-dis-expanded-citation-made-`l'.csv", varnames(1) encoding(UTF-8) clear
	save "`destdir'20190314-ua3-dis-expanded-citation-made-`l'.dta", replace
}
