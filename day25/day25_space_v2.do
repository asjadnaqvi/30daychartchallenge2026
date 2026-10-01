clear

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day25"

graph set window fontface "Abel"  // set graph font here


******** get the actual data


*eurostatdata lan_lcv_ovw, clear stub(y) noflags
*save "lan_lcv_ovw.dta", replace


use lan_lcv_ovw, clear




keep if unit=="KM2"

keep if geo=="AT"


compress

drop freq*
drop unit*

*drop y2009-y2018

compress

tab landcover

drop if landcover=="TOTAL"

drop if inlist(landcover, "B00_PI", "B10-50_PI", "B70-80_PI" )

drop if y2022==.



gen level = .
replace level = 1 if regexm(landcover, "^[A-Z]00$")
replace level = 2 if regexm(landcover, "^[A-Z][1-9]0$")
replace level = 3 if regexm(landcover, "^[A-Z][0-9][1-9]$")



forval i = 1/3 {
	gen lvl`i' 			= landcover_label if level==`i'
	gen double val`i' 	= y2022 if level==`i'
	
}


carryforward lvl1 val1 lvl2 val2, replace


drop if val3==.


*bysort lvl2: egen _check1 = sum(val3)

net install sunburst, from("D:\Dropbox\STATA - SUNBURST\installation") replace

sunburst val3, by(lvl1 lvl2 lvl3) full labprop wrap(16 16 25) labsize(0.9 0.9 1.3) rad(0.01 30 60 110) labscale(0.7) scheme(neon) share ///
	title("{fontface Merriweather Bold:Landcover by classifications in Austria in 2022}", size(3.5)) lc(black) palette(CET C6) lw(0.05 0.04 0.008) 	///
	note("#30DayChartChallenge 2026 Day25: Space. Data: Eurostat. @AsjadNaqvi") rotate(0)

graph export "30daychartchallenge_day25.png", replace wid(2000)










