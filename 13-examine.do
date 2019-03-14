set more off
global destdir ~/processed/patents/
local inputprefix "20190314"
import delimited ${destdir}`inputprefix'-ua3-CalcDistTrue-ErrAss.csv, encoding(ISO-8859-1) clear
merge m:1 patent_id using ${destdir}application.dta, keep(match master) nogen
drop if patent_id=="NULL"
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
//keep year patent_id error num_lines
gsort - num_lines
save ${destdir}`inputprefix'-ua3-CalcDistTrue-ErrAss.dta, replace 

keep if !missing(year) & error==-2
sort patent_id
merge 1:m patent_id using ${destdir}rawinventor.dta, keep(match master) nogen
bysort inventor_id: gen invcnt=_N
bysort inventor_id: gen invind=_n
bysort patent_id: gen patind=_n
count if patind == 1 /* 922,976 unique patents */
count if invind==1 /* 806,610 unique inventor_id for the 922,976 patents */
drop uuid rawlocation_id
gsort - invcnt
order year patent_id inventor_id invcnt num_lines
tab invcnt if invind==1 /* 616,262 inventor_id on 1 patent,  105,310 inventor_id on 2 patents, 36,235 inventor_id on 3 patents, 17,023 inventor_id on 4 patents: total 96.06 of all inventors whose patents do not have an assignee */
save ${destdir}missing_assignee.dta, replace

count if missing(year) /* 2,625,274 of 3,555,635 are missing year, in other words no info on patent */
tab year if !missing(year)

/* 
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
        975 |          1        0.00        0.00
       1074 |          2        0.00        0.00
       1877 |          1        0.00        0.00
       1878 |          1        0.00        0.00
       1885 |          1        0.00        0.00
       1893 |          1        0.00        0.00
       1897 |          1        0.00        0.00
       1901 |          1        0.00        0.00
       1904 |          1        0.00        0.00
       1918 |          1        0.00        0.00
       1929 |          1        0.00        0.00
       1931 |          1        0.00        0.00
       1938 |          1        0.00        0.00
       1943 |          1        0.00        0.00
       1944 |          6        0.00        0.00
       1945 |          2        0.00        0.00
       1946 |          1        0.00        0.00
       1948 |          3        0.00        0.00
       1950 |          1        0.00        0.00
       1951 |          1        0.00        0.00
       1952 |          2        0.00        0.00
       1953 |          1        0.00        0.00
       1954 |          1        0.00        0.00
       1955 |          2        0.00        0.00
       1957 |          2        0.00        0.00
       1958 |          6        0.00        0.00
       1959 |          6        0.00        0.01
       1960 |          2        0.00        0.01
       1961 |          4        0.00        0.01
       1962 |         14        0.00        0.01
       1963 |          6        0.00        0.01
       1964 |          2        0.00        0.01
       1965 |         10        0.00        0.01
       1966 |          7        0.00        0.01
       1967 |         13        0.00        0.01
       1968 |         14        0.00        0.01
       1969 |         41        0.00        0.02
       1970 |         71        0.01        0.03
       1971 |        198        0.02        0.05
       1972 |        397        0.04        0.09
       1973 |      1,729        0.19        0.28
       1974 |      8,987        0.97        1.25
       1975 |     17,225        1.87        3.12
       1976 |     19,642        2.13        5.24
       1977 |     19,349        2.10        7.34
       1978 |     18,636        2.02        9.36
       1979 |     18,078        1.96       11.32
       1980 |     17,291        1.87       13.19
       1981 |     15,653        1.70       14.88
       1982 |     15,223        1.65       16.53
       1983 |     15,103        1.64       18.17
       1984 |     17,149        1.86       20.03
       1985 |     18,413        1.99       22.02
       1986 |     19,593        2.12       24.14
       1987 |     21,356        2.31       26.46
       1988 |     23,210        2.51       28.97
       1989 |     24,213        2.62       31.59
       1990 |     25,353        2.75       34.34
       1991 |     24,519        2.66       36.99
       1992 |     24,001        2.60       39.59
       1993 |     25,631        2.78       42.37
       1994 |     29,403        3.18       45.55
       1995 |     31,237        3.38       48.94
       1996 |     31,575        3.42       52.36
       1997 |     35,583        3.85       56.21
       1998 |     33,391        3.62       59.83
       1999 |     32,593        3.53       63.36
       2000 |     28,604        3.10       66.46
       2001 |     25,061        2.71       69.17
       2002 |     25,084        2.72       71.89
       2003 |     22,883        2.48       74.37
       2004 |     20,717        2.24       76.61
       2005 |     19,480        2.11       78.72
       2006 |     18,263        1.98       80.70
       2007 |     18,439        2.00       82.70
       2008 |     17,249        1.87       84.57
       2009 |     17,631        1.91       86.47
       2010 |     18,578        2.01       88.49
       2011 |     18,913        2.05       90.54
       2012 |     19,445        2.11       92.64
       2013 |     19,828        2.15       94.79
       2014 |     18,688        2.02       96.81
       2015 |     16,131        1.75       98.56
       2016 |     10,829        1.17       99.73
       2017 |      2,451        0.27      100.00
       2018 |          7        0.00      100.00
       2976 |          1        0.00      100.00
       9177 |          1        0.00      100.00
------------+-----------------------------------
      Total |    923,247      100.00

*/

tab error if missing(year)
/*
      error |      Freq.     Percent        Cum.
------------+-----------------------------------
         -3 |  2,625,270      100.00      100.00
         -2 |          4        0.00      100.00
------------+-----------------------------------
      Total |  2,625,274      100.00
*/

tab error if !missing(year)
/*
      error |      Freq.     Percent        Cum.
------------+-----------------------------------
         -3 |        271        0.03        0.03
         -2 |    922,976       99.97      100.00
------------+-----------------------------------
      Total |    923,247      100.00

*/


import delimited ${destdir}`inputprefix'-ua3-CalcDistTrue-ErrInv.csv, encoding(ISO-8859-1) clear
merge m:1 patent_id using ${destdir}application.dta, keep(match master) nogen
drop if patent_id=="NULL"
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
keep year patent_id error num_lines
gsort - num_lines
save ${destdir}`inputprefix'-ua3-CalcDistTrue-ErrInv.dta, replace 
count if missing(year) /* 2,625,270 of 2,626,125 are missing year */
tab year if !missing(year)
tab error if missing(year) /* All 2,625,270 are Key Errors */
