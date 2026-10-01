clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day11"


*eurostatdata ext_lt_intertrd, clear stub(y) noflags

use ext_lt_intertrd, clear

tab freq
drop freq*

tab indic_et
tab indic_et_label

keep if inlist(indic_et, "RT_IVU", "RT_IVOL")

tab partner
keep if partner=="EXT_EU27_2020"


tab geo
drop geo*

tab partner
drop partner*


encode sitc06_label, gen(sitc)

drop indic_et_label

reshape long y@, i(sitc* indic*) j(year)


ren y y_



reshape wide y_, i(sitc* year) j(indic_et) string


levelsof sitc, local(lvls)

foreach x of local lvls {

catspline y_RT_IVU y_RT_IVOL if sitc==`x', replace rho(0.2) genx(_x`x') geny(_y`x') genid(_id`x') genorder(_order`x')
	
sort _id`x' _order`x'
	
}






tab year

cap drop _labmark
gen _labmark = 1 if inlist(year, 2002, 2005, 2010, 2015, 2020, 2025)

/*

twoway ///
	(line _y1 _x1, cmissing(n))	///
	(scatter y_RT_IVU y_RT_IVOL if sitc==1 & _labmark==1, mlab(year) msize(0.5))
*/	
	
	
/*
local cuts = 5
	
levelsof _id1, local(lvls)


forval y = 1/7 {
	
	di "`y'"
	
	local i = 1	
	
	foreach x of local lvls {
		
		*di `i'	
		
		local wid = 0.2 + `i' / `cuts'
		
		colorpalette tableau, n(7) nograph 
		
		local lines `lines' (line _y`y' _x`y' if _id`y'==`x', cmissing(n) lw(`wid') lc("`r(p`y')'%70"))
		
		if mod(`x', `cuts') == 0 local ++i	
		
	}	
	
	colorpalette tableau, n(7) nograph 
	
	local _scatter 	`_scatter'	(scatter y_RT_IVU y_RT_IVOL if sitc==`y', msize(0.5) msym(O) mcolor("`r(p`y')'%70")) 
	*local _label 	`_label' 	(scatter y_RT_IVU y_RT_IVOL if sitc==`y' & _labmark==1, mlab(year) mcolor(none)) 
	
}
	
	
twoway ///
	`lines'	///
	`_scatter'	///
	`_label'	///
	,  legend(off)
	
		
	
*/	
	
	
lab var y_RT_IVU 	"Terms of trade (export/import)"	
lab var y_RT_IVOL 	"Volume ratio (export/import)"		


local cuts = 20
	
levelsof _id1, local(lvls)
local last = r(r)


local y = 7
	
	di "`y'"
	
	local i = 1	
	
	foreach x of local lvls {
		
		if `x' == `last' local i = 1
		
		local wid = 0.02 + (`i' / 24) * 3.5
		
		di "segment:`x', width: `i'"
		
		colorpalette HCL intense, n(7) nograph 
		local lines `lines' (line _y`y' _x`y' if _id`y'==`x', cmissing(n) lw(`wid') lc("`r(p2)'%80"))
	
		if mod(`x', 2) == 0 local ++i	
		
	}	
	
	colorpalette HCL intense,nograph 
	
	local _scatter 	`_scatter'	(scatter y_RT_IVU y_RT_IVOL if sitc==`y', msize(0.6) msym(O) mcolor(yellow) mlcolor("`r(p2)'")) 
	local _label 	`_label' 	(scatter y_RT_IVU y_RT_IVOL if sitc==`y' & _labmark==1, mlab(year) mlabpos(12) mcolor(none) mlabcolor(white) mlabsize(1.6)) 
	

	
	
twoway ///
	(scatteri 90 90 115 115, recast(line) lc(gs8) lp(-) lw(0.12)) ///
	`lines'	///
	`_scatter'	///
	`_label'	///
	,  ///
		legend(off) scheme(neon) ///
		aspect(1) xsize(3) ysize(3)	///
		xtitle("Volume ratio (export/import)", size(2.2)) ///
		ytitle("Terms of trade (export/import)", size(2.2))	///
		xlabel(, labsize(2)) ///
		ylabel(, labsize(2))	///
		xline(100, lw(0.3) lc(gs10))	///
		yline(100, lw(0.3) lc(gs10))	///
		text(92 95 "Losing on both", color("104 215 252") size(2))	///
		text(94 110 "Selling more, earning less", color("104 215 252") size(2))	///
		text(113 110 "Winning on both", color("104 215 252") size(2))	///
		text(113 95 "Selling less, earning more", color("104 215 252") size(2))	///
		title("{fontface Merriweather Bold:EU27 trade of physical goods with RoW (2002-2025)}", size(3.6) span) ///
		note("#30DayChartChallenge 2026 Day 11: Physical. Data: Eurostat. @AsjadNaqvi.", size(1.6) span)
	
		*subtitle("(EU27 balances with the Rest of the World)", size(2)) ///
	
		
	
graph export 30daychartchallenge_day11.png, replace wid(4000)
	
		
	
	
