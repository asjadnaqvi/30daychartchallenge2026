clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"


*** day 1: parts of whole ****

*eurostatuse2 nrg_bal_c, clear stub(y) noflags

use nrg_ind_id3cf, clear


tab freq
drop freq*

tab unit
drop unit*

tab partner
drop partner*

tab siec

tab geo

keep if geo=="AT"

drop y2011-y2022

replace siec_label = "Oil and petroleum products" if siec_label == "Oil and petroleum products (excluding biofuel portion)"

reshape long y, i(siec* geo*) j(year)

gen _total = 100
drop if y==0

waffle y if year==2010, by(siec_label) normvar(_total) cols(5) ///
	format(%6.2f) palette(black) msym(triangle Oh) msize(1 0.5) ndsym(Oh) ///
	note("") xsize(5) ysize(1)


drop if siec_label=="Total"	
	
gen _mylab = siec_label + " (" + string(year) + ")"

gen _mylab2 = string(year) + " - " + siec_label 


waffle y , by(_mylab) normvar(_total) cols(2)  subtitle(, pos(6) size(3.2) nobox) ///
	format(%6.2f) palette(black) msym(triangle) msize(1.1) ndsize(0.8) ndsym(+) ///
	note("") xsize(1) ysize(2)	
	
	
waffle y , by(_mylab2) normvar(_total) cols(4)  subtitle(, pos(6) size(3) nobox) ///
	format(%6.2f) palette(black) msym(triangle) msize(0.8) ndsize(0.8) ndsym(+) ///
	title("{fontface Merriweather Bold:Austria's fuel import dependency on non-EU countries (2010 vs 2023)}", size(5))	///
	note("Source: Eurostat energy balances. #30DayChartChallenge 2026 Day2: Pictogram. @AsjadNaqvi", size(2)) ///
	xsize(2) ysize(1)		
	
	
graph export 30daychartchallenge_day2.png, replace wid(4000)
	
	
graph use day2.gph	
	
graph export 30daychartchallenge_day2_v2.png, replace wid(4000)
		
	
	
	
	
	
	