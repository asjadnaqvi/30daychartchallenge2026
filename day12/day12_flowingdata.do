clear

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"







**** merge with file


use "D:\Dropbox\WORLD BANK C3A DATA/03_split/OECD_DAC/DAC_table1.dta", clear


tab year
*keep if year==2024

tab aidtype
keep if aidtype_code==1015


tab fundflows
keep if flows==1140



drop if donor_id > 20000
drop if donor_id==918

drop if value < 0

drop if year==2025


/*
streamplot value_real year, by(donor) smooth(0) ///
	palette(CET C6) scheme(neon) labprop labsize(2.5) ///
	xsize(3) ysize(1) lc(black) labcolor(white)	///
	title("Real value of Bilateral Aid (USD millions) 1960-2024")	///
	note("#30DayChartChallenge 2026 Day 12:Flowing Data. @AsjadNaqvi")
*/



bumparea value_real year, by(donor) top(10) ///
	palette(CET C6) scheme(neon) labprop labsize(2.5) ///
	xsize(3) ysize(1) lc(black) labcolor(white)  offset(8)	///  	// recenter(bottom)
	title("{fontface Merriweather Bold:Bilateral Aid (USD millions, constant 2021 prices) 1960-2024}", size(5))	///
	note("#30DayChartChallenge 2026 Day 12:Flowing Data. Data: OECD DAC. @AsjadNaqvi", size(2.4))
	
	
graph export 30daychartchallenge_day12.png, replace wid(4000)
	
			
	
	
	
	