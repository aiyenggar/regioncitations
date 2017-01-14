cap log close
set more off
local destdir /Users/aiyenggar/datafiles/patents/
cd `destdir'
log using knowledge-flows.log, append

use `destdir'bcit.dta, clear


use `destdir'fcit.dta, clear
