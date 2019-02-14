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
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanarea.dta, keep(match master) nogen
/* 3562 rawlocation_id go unmatched, leaving 15,748,260 matched entries */
/* We retain all 15,751,822 observations including the unmatched */
drop  rawlocation_id
order year patent_id inventor_id ua* 
sort patent_id
save `destdir'patent_inventor_urbanarea.dta, replace
export delimited using `destdir'patent_inventor_urbanarea.csv, replace
/* Of 15,751,822 patent-inventor observations, 4,310,505 are missing ua1, and
	2,032,338 are missing both ua1 and ua2 
	1,317,142 are missing ua1, ua2 and ua3 */
tab year if ua1 == -1 & missing(ua2) & missing(ua3)
/*
. tab year if ua1 == -1 & missing(ua2) & missing(ua3)

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
       1969 |         29        0.00        0.01
       1970 |         86        0.01        0.02
       1971 |        232        0.02        0.03
       1972 |        474        0.04        0.07
       1973 |      2,286        0.17        0.24
       1974 |      9,593        0.73        0.97
       1975 |     15,128        1.15        2.12
       1976 |     15,280        1.16        3.28
       1977 |     13,609        1.03        4.31
       1978 |     13,550        1.03        5.34
       1979 |     13,540        1.03        6.37
       1980 |     13,478        1.02        7.39
       1981 |     13,277        1.01        8.40
       1982 |     13,971        1.06        9.46
       1983 |     13,446        1.02       10.48
       1984 |     15,221        1.16       11.64
       1985 |     16,874        1.28       12.92
       1986 |     17,976        1.36       14.28
       1987 |     20,062        1.52       15.81
       1988 |     23,007        1.75       17.55
       1989 |     23,967        1.82       19.37
       1990 |     24,979        1.90       21.27
       1991 |     25,704        1.95       23.22
       1992 |     26,320        2.00       25.22
       1993 |     27,374        2.08       27.30
       1994 |     31,613        2.40       29.70
       1995 |     36,577        2.78       32.48
       1996 |     37,419        2.84       35.32
       1997 |     44,094        3.35       38.66
       1998 |     43,969        3.34       42.00
       1999 |     45,828        3.48       45.48
       2000 |     48,949        3.72       49.20
       2001 |     51,820        3.93       53.13
       2002 |     49,031        3.72       56.85
       2003 |     40,416        3.07       59.92
       2004 |     37,534        2.85       62.77
       2005 |     37,792        2.87       65.64
       2006 |     39,175        2.97       68.62
       2007 |     41,394        3.14       71.76
       2008 |     42,559        3.23       74.99
       2009 |     41,409        3.14       78.13
       2010 |     44,088        3.35       81.48
       2011 |     46,725        3.55       85.03
       2012 |     50,477        3.83       88.86
       2013 |     49,006        3.72       92.58
       2014 |     43,060        3.27       95.85
       2015 |     32,651        2.48       98.33
       2016 |     18,307        1.39       99.72
       2017 |      3,678        0.28      100.00
       2018 |          9        0.00      100.00
       2987 |          1        0.00      100.00
       9183 |          3        0.00      100.00
       9186 |          1        0.00      100.00
------------+-----------------------------------
      Total |  1,317,142      100.00

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
sort rawlocation_id
drop if missing(rawlocation_id) | rawlocation_id=="NULL"
/* 7,707 rows have an empty rawlocation_id or rawlocation_id as NULL*/
/* 5,895,704 of the initial 5,903,411 remain */
merge 1:1 rawlocation_id using `destdir'rawlocation_urbanarea.dta, keep(match master) nogen
/* 335 entries are not matched, but all 5,895,704 entries are retained */
drop rawlocation_id
egen assignee_numid = group(assignee_id) if strlen(assignee_id) > 0
save `destdir'patent_assignee_urbanarea.dta, replace

bysort assignee_numid: gen patent_count=_N if !missing(assignee_numid)
bysort assignee_numid: keep if _n == 1 | missing(assignee_numid)
gsort - patent_count
keep assignee_numid assignee_id assignee country patent_count
save `destdir'assignee_id.dta, replace

use `destdir'patent_assignee_urbanarea.dta, clear
drop assignee_id /* assignee_numid will do the job for the comparisons */
order year patent_id assignee_numid ua*
sort patent_id
save `destdir'patent_assignee_urbanarea.dta, replace
export delimited using `destdir'patent_assignee_urbanarea.csv, replace
tab year if ua1 == -1 & missing(ua2) & missing(ua3)
/*
/* Of 5,895,704 patent-assignee observations, 1,168,875 are missing ua1, and
	565,810 are missing both ua1 and ua2 
	417,840 are missing ua1, ua2 and ua3 */

. tab year if ua1 == -1 & missing(ua2) & missing(ua3)

       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       1075 |          1        0.00        0.00
       1682 |          1        0.00        0.00
       1900 |          1        0.00        0.00
       1959 |          1        0.00        0.00
       1961 |          1        0.00        0.00
       1962 |          1        0.00        0.00
       1963 |          1        0.00        0.00
       1965 |          4        0.00        0.00
       1966 |          1        0.00        0.00
       1967 |          1        0.00        0.00
       1968 |          3        0.00        0.00
       1969 |          4        0.00        0.00
       1970 |         21        0.01        0.01
       1971 |         63        0.02        0.02
       1972 |        132        0.03        0.06
       1973 |        571        0.14        0.19
       1974 |      2,470        0.59        0.78
       1975 |      3,714        0.89        1.67
       1976 |      3,632        0.87        2.54
       1977 |      3,328        0.80        3.34
       1978 |      3,464        0.83        4.17
       1979 |      3,387        0.81        4.98
       1980 |      3,557        0.85        5.83
       1981 |      3,386        0.81        6.64
       1982 |      3,561        0.85        7.49
       1983 |      3,408        0.82        8.31
       1984 |      3,919        0.94        9.25
       1985 |      4,188        1.00       10.25
       1986 |      4,522        1.08       11.33
       1987 |      5,158        1.23       12.56
       1988 |      5,777        1.38       13.95
       1989 |      6,170        1.48       15.42
       1990 |      6,289        1.51       16.93
       1991 |      6,238        1.49       18.42
       1992 |      6,670        1.60       20.02
       1993 |      6,937        1.66       21.68
       1994 |      7,898        1.89       23.57
       1995 |      8,690        2.08       25.65
       1996 |      9,708        2.32       27.97
       1997 |     10,582        2.53       30.50
       1998 |     10,759        2.57       33.08
       1999 |     12,693        3.04       36.12
       2000 |     16,825        4.03       40.14
       2001 |     18,770        4.49       44.64
       2002 |     17,628        4.22       48.85
       2003 |     14,594        3.49       52.35
       2004 |     14,021        3.36       55.70
       2005 |     14,482        3.47       59.17
       2006 |     15,559        3.72       62.89
       2007 |     15,886        3.80       66.69
       2008 |     15,432        3.69       70.39
       2009 |     15,284        3.66       74.05
       2010 |     15,933        3.81       77.86
       2011 |     17,307        4.14       82.00
       2012 |     17,562        4.20       86.20
       2013 |     18,619        4.46       90.66
       2014 |     17,156        4.11       94.77
       2015 |     13,188        3.16       97.92
       2016 |      7,305        1.75       99.67
       2017 |      1,374        0.33      100.00
       2018 |          2        0.00      100.00
       9183 |          1        0.00      100.00
------------+-----------------------------------
      Total |    417,840      100.00
*/

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

