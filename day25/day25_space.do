clear

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"

graph set window fontface "Abel"  // set graph font here


******** get the actual data


*eurostatuse2 lan_use_ovw, clear stub(y) noflags
*save "lan_use_ovw.dta", replace


use lan_use_ovw, clear



keep if geo=="AT"
keep if unit=="KM2"

compress

drop freq*
drop unit*


summ y2022 if landuse=="TOTAL"
gen _total = r(max)

drop if landuse=="TOTAL"
drop if landuse=="U340-370"
drop if landuse=="U364"
drop if landuse=="HENVI"

drop if landuse=="U400"

*drop y2009 y2015 y2018

foreach x in 2009 2012 2015 2018 2022 {
	
	egen double  _t`x' = sum(y`x')
	gen double _per`x' = 100 * y`x' / _t`x'
}



*gen diff = _check2 - _check1


drop if _t2012==.


drop _t*



reshape long y per, i(landuse-geo_label) j(year)

*egen group = group(year)


bumparea y year, by(landuse_label) xsize(3) ysize(1)


*polarbar per, by(year) stack(landuse_label)
