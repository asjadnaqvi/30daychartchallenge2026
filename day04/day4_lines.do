clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"


*** day 4: lines ****

*** income by quintile
*eurostatuse2 prc_hicp_minr, clear stub(y) noflags


use prc_hicp_minr, clear

tab freq
drop freq*

tab unit
keep if unit=="RCH_A"

tab coicop18
keep if length(coicop18)==5

tab geo geo_label
drop if inlist(geo, "EA19", "EA20", "EA21", "EEA", "EU27_2020", "XK", "EA", "EU" )
drop if inlist(geo, "LU","RO", "GE", "MT", "SE")
drop if inlist(geo, "MK","ME", "LT", "LV", "EE")
drop if inlist(geo, "HR", "CY", "RS")

drop y1996m1- y2025m12
drop y2026m3

drop if y2026m2==.

gsort geo -y2026m2
by geo: gen _rank1 = _n

gsort geo y2026m2
by geo: gen _rank2 = _n

gen _rank = .
replace _rank = 1 if _rank1 <=5 
replace _rank = 1 if _rank2 <=5 


replace coicop18_label = "Water supply and miscellaneous dwelling services" if coicop18_label=="Water supply and miscellaneous services relating to the dwelling"



polarspike y2026m2 if _rank1<=5, by(coicop18_label) over(geo_label) labgap(18) labsize(0.95) format(%6.1f) palette(CET C1) offset(15)
	

*polarspike y2026m2 if _rank==1, by(coicop18_label) over(geo_label) labgap(10) labsize(1) format(%6.1f) palette(CET C7)
	

polarspike y2026m2 if inlist(geo,"AT","DE"), by(coicop18_label) over(geo_label)  labgap(18) labsize(0.95) format(%6.1f) palette(CET C1) offset(15)
	
	

	
*****	
	
use prc_hicp_minr, clear

tab freq
drop freq*


keep if coicop18=="CP0451" // Electricity, gas and other fuels

keep if unit=="I15"
drop unit*


drop if inlist(geo, "EA19", "EA20", "EA21", "EEA", "EU27_2020", "XK", "EA", "EU" )
drop if inlist(geo, "LU","RO", "GE", "MT", "SE")
drop if inlist(geo, "MK","ME", "LT", "LV", "EE")
drop if inlist(geo, "HR", "CY", "RS")

keep coicop18* geo*  y2019m2  y2026m2

drop if y2019m2==.	
drop if y2026m2==.	


gen double _change = (y2026m2/y2019m2 - 1) * 100

gen zeros = 0
gen ones = 1

cap drop _mylab
gen _mylab = geo_label  + " (" + string(_change, "%5.1fc") + "%)"



/*
twoway ///
	(pcspike zeros zeros _change ones, lwidth(thin)) ///
	(scatter _change ones, mcolor(none) mlabel(_mylab) mlabsize(1.6))	///
		, ///
		xscale(off) xscale(range(0 1.2)) ///
		legend(off)
*/

labrepel _change ones,  mlabsize(1.6) seed(122)  label(_mylab) direction(y) 	
replace _xcoord = _xcoord + 0.04		

/*		
twoway ///
	(pcspike zeros zeros _change ones, lwidth(thin)) ///
	(scatter _ycoord _xcoord, mcolor(none) mlabel(_mylab) mlabsize(1.6))	///
	(pcspike _change ones _ycoord _xcoord, lcolor(gs10) lw(0.1))	///
		, ///
		xscale(off) xscale(range(0 1.2)) ///
		legend(off)		ysize(1.5) xsize(1)
*/
		
cap drop _cuts		
xtile _cuts = _change, n(10)		


levelsof _cuts, local(lvls)
local items = r(r)

foreach x of local lvls {
	
	colorpalette matplotlib spring, nograph n(`items')
	
	local mylines `mylines' (pcspike zeros zeros _change ones if _cuts==`x', lwidth(thin) lc("`r(p`x')'")) 
	
	local mydots `mydots' (scatter _ycoord _xcoord if _cuts==`x', mcolor(none) mlabc("`r(p`x')'") mlabel(_mylab) mlabsize(1.7))	///
	
	
}
		
		
twoway ///
	`mylines' ///
	`mydots'	///
	(pcspike _change ones _ycoord _xcoord, lcolor(gs5) lw(0.1))	///
		, ///
		xscale(off) xscale(range(0 1.2)) ///
		legend(off)		ysize(1.5) xsize(1.1) ///
		title("{fontface Merriweather Bold:Electricity Prices}", size(4.5))	///
		subtitle("Percentage change from Feb 2019 to Feb 2026", size(3))	///
		note("#30DayChartChallenge 2026 Day4: Slope. Data source: Eurostat monthly HICP data. @AsjadNaqvi", size(1.6) )	///
		scheme(neon)

graph export 30daychartchallenge_day4.png, replace wid(4000)
	
		
		
	
/*****	
	
*eurostatuse2 nrg_pc_204, clear stub(y) noflags	

use nrg_pc_204, clear

tab freq
drop freq*

tab nrg_cons
keep if nrg_cons=="TOT_KWH"
drop nrg*

tab unit
drop unit*


tab tax
keep if tax=="I_TAX"
drop tax*

tab currency
keep if currency=="EUR"
drop currency*


tab siec
drop siec*

tab geo
drop if inlist(geo, "EA19", "EA20", "EA21", "EEA", "EU27_2020", "XK", "EA", "EU" )








	
	
	
	
	
	
	