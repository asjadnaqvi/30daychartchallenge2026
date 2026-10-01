clear all


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026\day14"

use BACI_HS22_Y2024_small, clear

*net install arcplot, from("D:\Dropbox\STATA - ARCPLOT\installation") replace
*ssc install arcplot, replace


cap drop _ex_total _im_total

bysort ex_iso3: egen _ex_total = sum(value)
bysort im_iso3: egen _im_total = sum(value)


cap drop ex_rank
cap drop im_rank

egen ex_rank = group(_ex_total)

egen im_rank = group(_im_total)


summ ex_rank
replace ex_rank = r(max) + 1 - ex_rank


summ im_rank
replace im_rank = r(max) + 1 - im_rank



cap drop _from
cap drop _to

gen  _from 	= ex_name
gen  _to 	= im_name


replace _from 	= "Rest of the World" if ex_rank > 5
replace _to 	= "Rest of the World" if im_rank > 5




arcplot value, from(_from) to(_to) gap(1) valsize(0.9) palette(CET C7)  ///
	labsize(1.7) labangle(45) labpos(7) labgap(-1) valgap(1) offset(1) format(%15.0fc) scheme(neon)	///
	labcolor(white) valcolor(white) noval	///
	title("{fontface Merriweather Bold:Trade of Sand in 2024}", size(5))	///
	subtitle("Top 5 Importing and Top 5 Exporting Countries", size(2.8)) ///
	note("30DayChartChallenge 2026 Day14: Trade. Source: Comtrade BACI HS22. @AsjadNaqvi", size(1.2) position(3) orientation(vertical))
	
graph export "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026/30daychartchallenge_day14.png", replace wid(3000)	
*graph export arcplot_ssc.png, replace wid(3000)
	
	
	