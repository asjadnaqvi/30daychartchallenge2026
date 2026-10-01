clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day09"


*** Central Bank Gold reserves
***source: https://www.gold.org/goldhub/data/gold-reserves-by-country



import excel using "worldgoldcouncil_reserves_2024.xlsx", clear  first sheet("Data") case(lower)


foreach x of varlist fxreserves- holdings {
	replace `x' = "" if `x' == "AWAITED"
	destring `x', replace

}


drop if goldreservestonnes == .
drop if goldreservestonnes == 0


replace country = "Taiwan" if country=="Taiwan, China"

*colorpalette tab Orange-Gold, luminate(15)

circlepack goldreservestonnes, by(region country) labprop scheme(neon) fi(100 70) ///
	palette(tab Orange-Gold)  labcond(100) labscale(0.3) labsize(1.5)	///
	title("{fontface Merriweather Bold:Central Bank Gold Reserves in Tonnes in 2024}", size(4))	///
	note("#30DayChartChallenge 2026 Day9: Wealth. Source: World Gold Council. @AsjadNaqvi.", size(1.5))



graph export 30daychartchallenge_day9.png, replace wid(4000)
	