clear

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"

graph set window fontface "Abel"  // set graph font here


******** get the actual data


*eurostatuse2 prc_hicp_minr, clear stub(y) noflags
*save "prc_hicp_minr.dta", replace


use "prc_hicp_minr.dta", clear

tab geo
keep if length(geo)==2
drop if inlist(geo, "US", "TR", "UK", "XK", "EA")

tab unit
tab unit_label
keep if unit=="I15"
drop unit*

tab freq
drop freq*

tab coicop18
keep if coicop18=="CP0722"

*drop coicop*



egen _check = rownonmiss(y*)
tab _check

drop if _check < 100
drop _check

ren geo_label countryname


replace countryname = "Czech Republic"  if countryname == "Czechia"
replace countryname = "Slovak Republic" if countryname == "Slovakia"
replace countryname = "Macedonia, FYR"  if countryname ==  "North Macedonia"



merge 1:1 countryname using flourish_icons.dta

list countryname if _m==1
*list countryname if _m==2

drop if _m==2
drop _m


replace countryname = "Czechia" 	    if countryname == "Czech Republic"
replace countryname = "Slovakia" 		if countryname == "Slovak Republic"
replace countryname = "North Macedonia" if countryname == "Macedonia, FYR"


drop y1996m1- y2019m12


// export for flourish

export delim using prc_hicp_minr_clean.csv, replace 
export excel using prc_hicp_minr_clean.xlsx, replace first(var)  keepcellfmt 

