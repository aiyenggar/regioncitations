set more off
local destdir ~/processed/patents/
cd `destdir'

use `destdir'uspc_current.dta, clear
/* We start with 22,880,877 observations, primarily because most 
   patents have multiple class assignments. */
keep if sequence == 0
drop sequence
/* 6,610,258 patents remain */
sort mainclass_id
rename mainclass_id class
rename subclass_id subclass
merge m:1 class using `destdir'nber_class_match.dta
/* 5,108,545 of the 6,610,258 entries are matched */
/* class 287 723 903 930 935 968 976 977 984 987 are found in no patents */
/* Provide a new catergory (8) and subcategory (81) for all design patents */
replace cat=8 if (strpos(class,"D")==1 & strpos(subclass,"D")==1 & missing(cat))
replace subcat=81 if (strpos(class,"D")==1 & strpos(subclass,"D")==1 & missing(subcat))
keep if _merge == 1 | _merge == 3
drop _merge
sort patent_id
save `destdir'patent_technology_classification.dta, replace

use `destdir'rawlocation.dta, clear
keep rawlocation_id country latlong
sort latlong
merge m:1 latlong using `destdir'latlongid.dta, keep(match master) nogen
drop latlong
merge m:1 latlongid using `destdir'latlong_urbanarea.dta, keep(match master) nogen
sort rawlocation_id
save `destdir'rawlocation_urbanarea.dta, replace

use `destdir'rawinventor.dta, clear
/* We start with 15,752,110 observations */
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
/* 1 observation has patent_id as NULL leaving 15,752,109 matched entries */
drop if patent_id=="NULL"
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
keep patent_id inventor_id rawlocation_id year sequence
rename sequence inventorseq
sort rawlocation_id
drop if missing(rawlocation_id)
/* 287 observations have an empty rawlocation_id  */
/* 15,751,822 of the initial 15,752,109 remain */
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanarea.dta
/* 3562 rawlocation_id go unmatched, leaving 15,748,260 matched entries */
replace ua1 = -2 if _merge==1
replace ua2 = -2 if _merge==1
replace ua3 = -2 if _merge==1
replace latlongid = -2 if _merge==1
drop if _merge == 2 /* from using */
/* We retain all 15,751,822 observations but set ua1, ua2, ua3 to -2 for the unmatched */
drop  _merge rawlocation_id
order year patent_id inventor_id ua* 
sort patent_id
save `destdir'patent_inventor_urbanarea.dta, replace
count if ua1 < 0 /* 4,314,067 of 15,751,822 */
count if ua2 < 0 /* 2,035,898 of 15,751,822 */
count if ua3 < 0 /* 1,320,707 of 15,751,822 */
tab year if ua1 <= -1 & ua2 <= -1 & ua3 <= -1
/*
. tab year if ua1 <= -1 & ua2 <= -1 & ua3 <= -1

       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       1075 |          3        0.00        0.00
       1076 |          3        0.00        0.00
       1077 |          2        0.00        0.00
       1682 |          3        0.00        0.00
       1901 |          1        0.00        0.00
       1915 |          1        0.00        0.00
       1943 |          2        0.00        0.00
       1947 |          1        0.00        0.00
       1951 |          1        0.00        0.00
       1953 |          1        0.00        0.00
       1956 |          1        0.00        0.00
       1958 |          2        0.00        0.00
       1959 |          2        0.00        0.00
       1961 |          3        0.00        0.00
       1962 |          2        0.00        0.00
       1963 |          9        0.00        0.00
       1964 |          1        0.00        0.00
       1965 |         13        0.00        0.00
       1966 |          7        0.00        0.00
       1967 |         14        0.00        0.01
       1968 |         22        0.00        0.01
       1969 |         30        0.00        0.01
       1970 |         86        0.01        0.02
       1971 |        232        0.02        0.03
       1972 |        474        0.04        0.07
       1973 |      2,289        0.17        0.24
       1974 |      9,609        0.73        0.97
       1975 |     15,167        1.15        2.12
       1976 |     15,321        1.16        3.28
       1977 |     13,634        1.03        4.31
       1978 |     13,585        1.03        5.34
       1979 |     13,597        1.03        6.37
       1980 |     13,527        1.02        7.39
       1981 |     13,325        1.01        8.40
       1982 |     14,042        1.06        9.47
       1983 |     13,513        1.02       10.49
       1984 |     15,313        1.16       11.65
       1985 |     16,934        1.28       12.93
       1986 |     18,054        1.37       14.30
       1987 |     20,142        1.53       15.82
       1988 |     23,106        1.75       17.57
       1989 |     24,060        1.82       19.39
       1990 |     25,088        1.90       21.29
       1991 |     25,793        1.95       23.25
       1992 |     26,392        2.00       25.24
       1993 |     27,492        2.08       27.33
       1994 |     31,759        2.40       29.73
       1995 |     36,800        2.79       32.52
       1996 |     37,655        2.85       35.37
       1997 |     44,351        3.36       38.73
       1998 |     44,202        3.35       42.07
       1999 |     46,083        3.49       45.56
       2000 |     49,259        3.73       49.29
       2001 |     52,153        3.95       53.24
       2002 |     49,199        3.73       56.97
       2003 |     40,474        3.06       60.03
       2004 |     37,535        2.84       62.87
       2005 |     37,792        2.86       65.73
       2006 |     39,175        2.97       68.70
       2007 |     41,394        3.13       71.84
       2008 |     42,559        3.22       75.06
       2009 |     41,409        3.14       78.19
       2010 |     44,088        3.34       81.53
       2011 |     46,725        3.54       85.07
       2012 |     50,477        3.82       88.89
       2013 |     49,006        3.71       92.60
       2014 |     43,060        3.26       95.86
       2015 |     32,651        2.47       98.33
       2016 |     18,307        1.39       99.72
       2017 |      3,678        0.28      100.00
       2018 |          9        0.00      100.00
       2987 |          1        0.00      100.00
       9183 |          3        0.00      100.00
       9186 |          1        0.00      100.00
------------+-----------------------------------
      Total |  1,320,704      100.00

*/

use `destdir'rawassignee.dta, clear
gen assignee = organization if !missing(organization)
replace assignee = name_first + " " + name_last if missing(assignee)
replace assignee = substr(assignee, 1, 48)
compress assignee
drop name_first name_last organization
rename sequence assigneeseq
rename type assigneetype
drop uuid
/* We start with 5,903,411 entries */
merge m:1 patent_id using `destdir'application.dta, keep(match master) nogen
/* All entries are matched, leaving 5,903,411 matched entries */
gen appl_date = date(date,"YMD")
gen year=year(appl_date)
rename number application_id
keep year patent_id assignee_id assignee assigneetype assigneeseq rawlocation_id

egen assignee_numid = group(assignee_id) if strlen(assignee_id) > 0
save `destdir'temp_patent_assignee_year.dta, replace

bysort assignee_numid: gen patent_count=_N if !missing(assignee_numid)
bysort assignee_numid: keep if _n == 1 | missing(assignee_numid)
gsort - patent_count
keep assignee_numid assignee_id assignee patent_count /* country */
save `destdir'assignee_id.dta, replace

use `destdir'temp_patent_assignee_year.dta, clear
drop assignee_id /* assignee_numid will do the job for the comparisons */
order year patent_id assignee_numid
sort patent_id
replace assignee_numid = -1 if missing(assignee_numid)
save `destdir'patent_assignee_year.dta, replace

tab assigneetype if year > 2000
tab assigneetype
/* 
 
 tab assigneetype if year > 2000
assigneetyp |
          e |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        222        0.01        0.01
          2 |  1,678,904       47.22       47.23
          3 |  1,828,166       51.42       98.65
          4 |     16,467        0.46       99.12
          5 |     13,801        0.39       99.51
          6 |     13,244        0.37       99.88
          7 |      3,888        0.11       99.99
          8 |          2        0.00       99.99
          9 |        109        0.00       99.99
         12 |         89        0.00       99.99
         13 |        134        0.00      100.00
         14 |         65        0.00      100.00
         15 |         52        0.00      100.00
         16 |          2        0.00      100.00
         17 |          2        0.00      100.00
------------+-----------------------------------
      Total |  3,555,147      100.00

tab assigneetype

assigneetyp |
          e |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        734        0.01        0.01
          1 |          9        0.00        0.01
          2 |  2,954,197       50.11       50.12
          3 |  2,817,041       47.78       97.90
          4 |     36,218        0.61       98.52
          5 |     25,515        0.43       98.95
          6 |     43,726        0.74       99.69
          7 |     12,950        0.22       99.91
          8 |         22        0.00       99.91
          9 |        249        0.00       99.91
         12 |      1,262        0.02       99.94
         13 |        587        0.01       99.95
         14 |      2,688        0.05       99.99
         15 |        485        0.01      100.00
         16 |          7        0.00      100.00
         17 |         12        0.00      100.00
         18 |          1        0.00      100.00
         19 |          1        0.00      100.00
------------+-----------------------------------
      Total |  5,895,704      100.00
	  
*/

