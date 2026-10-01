clear all

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day17"



graph set window fontface "Abel"


*** https://www.globalforestwatch.org/dashboards/global/?category=forest-change&location=WyJnbG9iYWwiXQ%3D%3D
import excel using  "global_05212025.xlsx", clear first sheet("Country drivers")

cap drop F-N
tab year

gen drive = ""
replace drive = "hardcomm" 		if driver == "Hard commodities"
replace drive = "logging" 		if driver == "Logging"
replace drive = "othernat" 		if driver == "Other natural disturbances"
replace drive = "permagri" 		if driver == "Permanent agriculture"
replace drive = "settlement" 	if driver == "Settlements & Infrastructure"
replace drive = "shift" 		if driver == "Shifting cultivation"
replace drive = "wildfire" 		if driver == "Wildfire"

drop driver
drop threshold

ren tc_loss_ha tc_loss_ha_

reshape wide tc_loss_ha_, i(country year) j(drive) string

recode tc* (.=0)

compress
save tcloss_drivers.dta, replace



**** 

import excel using  "global_05212025.xlsx", clear first sheet("Country tree cover loss")

keep if threshold==30
drop threshold
reshape long tc_loss_ha_, i(country) j(year)

ren tc_loss_ha_ tc_loss_ha_total
merge 1:1 country year using tcloss_drivers

drop if _m!=3
drop _m

compress
egen double _check = rowtotal(tc_loss_ha_hardcomm- tc_loss_ha_wildfire)

drop if _check==0

gen double tc_loss_ha_unknown = tc_loss_ha_total - _check


ren tc_loss_ha* y*

tab year
drop year

collapse (sum) y* (mean) extent_2000_ha area_ha, by(country)


drop y_total
reshape long y_, i(country) j(reason) string


gen double _forest_share = (extent_2000_ha / area_ha) * 100

gen double _share = (y_ / extent_2000_ha) * 100


cap drop reason2

gen reason2 = .
replace reason2 = 1 if reason=="permagri"
replace reason2 = 2 if reason=="shift"
replace reason2 = 3 if reason=="logging"
replace reason2 = 4 if reason=="hardcomm"
replace reason2 = 5 if reason=="settlement"

replace reason2 = 6 if reason=="othernat"
replace reason2 = 7 if reason=="wildfire"
replace reason2 = 8 if reason=="unknown"



lab de r2 1 "Permanent agriculture" 2 "Shifting cultivation" 3 "Logging" 4 "Hard commodities" 5 "Settlements & Infrastructure" 6 "Other natural disturbances" 7 "Widfire" 8 "Unknown" , replace
lab val reason2 r2

cap drop _total
bysort country: egen _total = sum(_share)

cap drop _group
egen _group = group(_total)

summ _group, meanonly
replace _group = r(max) + 1 - _group


sort _group


replace country = "D.R. Congo" if country == "Democratic Republic of the Congo"


polarbar _share if _forest_share > 10 & _total > 5, by(country) stack(reason2) sort palette(tab Green-Orange-Teal) showtotal labnear rotatelab ra(60)  ///
	labsize(1.1) labgap(15) circlabformat(%5.0f) lw(0.03) lc(black) labc(gs14) legsize(1.5) circc(gs3) circlabs(1.1) circlabc(gs10) circles(3)	///
	cfill(black) clc(black) clw(0.02)  ///
	plotregion(margin(t-6 b-6 l-6 r-6)) ///
	title("{fontface Merriweather Bold:Drivers of tree cover loss}", size(4)) aspect(0.97)	///
	subtitle("2001-2024 forest loss by main drivers as a % of 2000 forest cover", size(1.5)) ///
	note("#30DayChartChallenge 2026 Day17: Remake, Day13: Ecosystems. Data: Global Forest Watch (GFW) database." "Only countries with at 10% land area as forests and at least 5% total losses are shown. @AsjadNaqvi.", size(1.3)) ///
	scheme(neon)
	
	
graph export "30daychartchallenge_day17.png", replace wid(3000)	














