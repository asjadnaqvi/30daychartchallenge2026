clear

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day19"


graph set window fontface "Abel"




**** merge with file


import delim using "energy-consumption-by-source-and-country.csv", clear

tab entity
keep if entity == "World"
tab year
keep if inlist(year, 1994, 2024)


replace otherrenewables = otherrenewables + biofuels
drop biofuels

net install spider, from("D:\Dropbox\STATA - SPIDER\installation") replace

spider otherrenewables- oil, over(year) grid sort ///
	range(0(10000)60000) format(%15.0f)  ///
	scheme(neon) gcolor(gs4) scolor(gs6) slabcolor(gs14) glabcolor(gs7) palette(CET C3, select(2 14)) alpha(15) smooth(0.3) ///
	title("{fontface Merriweather Bold:Evolution of Global Primary Energy Consumption (TWH)}", size(3.4)) rotatelab(90)	///
	note("#30DayChartChallenge 2026 Day20: Evolution. Source: Our World in Data. @AsjadNaqvi.", size(1.5))


graph export "30daychartchallenge_day19.png", replace wid(3000)		
