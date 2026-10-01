clear



cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day12"

use DAC_table1_small, clear


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
	
			
	
	
	
	