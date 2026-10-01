clear

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day26"

graph set window fontface "Abel"  // set graph font here


******** get the actual data


*eurostatdata demo_r_mweek3, clear stub(y) noflags
*save "demo_r_mweek3.dta", replace


/*
use "demo_r_mweek3.dta", clear

tab geo
keep if length(geo)==2

tab unit
drop unit*

tab sex
keep if sex=="T"
drop sex*

tab age
keep if age=="TOTAL"
drop age*

drop freq*

compress
save "demo_r_mweek3_small.dta", replace
*/

use demo_r_mweek3_small, clear

egen _check = rownonmiss(y*)
tab _check

drop if _check < 1000


drop y2025mw01- _check


reshape long y, i(geo-geo_label) j(time)  string


split time, p(mw) destring
drop time
ren time1 year
ren time2 week

*drop if year <2013

gen date = yw(year,week)
format date %tw

compress



order geo date
sort geo date



sort geo date


gen country = substr(geo,1,2)


encode geo, gen(geo2)
order geo geo2

xtset geo2 date






****** main body code

*qui levelsof geo, local(cntry) 

*foreach k of local cntry {

*display "`k'"

*preserve

tab geo

keep if geo=="AT"
sort year week


drop if week==53

	*levelsof year, local(lvls)
	
	
	*foreach x of local lvls {
	
	*gen obs_`x' = week if year==`x'
	
	*local year1 = `x' - 1
	*cap replace obs_`x' = 0 if year==`year1' & week==52 

	
	gen double _angle = week * -2 * _pi / 52
	
	gen double _x = y * cos(_angle)
	gen double _y = y * sin(_angle)
	

	
	*}


*drop obs* angle*
	

****** polar graph below


summ y, meanonly

local displace = (r(max) - r(min)) * 0.1


local cmin = r(min) - `displace' 
local cmax = r(max) + `displace'

*display `cmin'
*display `cmax'


local diff = (`cmax' -  `cmin') / 5


local circle


local i = 1

forval x = `cmin'(`diff')`cmax' {
	local circle `circle' (function sqrt(`x'^2 - x^2), lc(gs4) lw(0.06) lp(solid) range(-`x' `x')) || (function -sqrt(`x'^2 - x^2), lc(gs4) lw(0.06) lp(solid) range(-`x' `x')) 
	
	local i = `i' + 1
}


*colorpalette gs6 gs14, n(10) nograph reverse

local spike

forval x = 1/26 {
	local theta = (`x') * _pi / 26   	
	local px = abs((`cmax' * 1.08) * cos(`theta'))    
		local spike `spike' (function (tan(`theta'))*x, n(2) range(-`px' `px') lw(0.06) lc(gs3) lp(solid)) ||
}


****** spike markers here

gen obs = _n in 1/26

gen double theta = -obs * _pi / 26 


gen double px1 =  abs((`cmax' * 1.1) * cos(theta))  
gen double px2 = -abs((`cmax' * 1.1) * cos(theta)) 

gen double py1 = tan(theta)*px1
gen double py2 = tan(theta)*px2

gen marker1 = obs
gen marker2 = obs

replace marker1 = marker1 + 26 if py1 > -1e-02
replace marker2 = marker2 + 26 if py2 >  1e-02


	
****** axis markers here

gen xvar = .
gen yvar = .

local i = 1

forval x = `cmin'(`diff')`cmax' {
   
   replace xvar = `x' in `i' 
   replace yvar = 0 in `i'
   local i = `i' + 1
}
	
format xvar %10.0fc



cap drop _m*

gen _m2020 = 1 if year==2020 | (year==2019 & week==52) 
gen _m2021 = 1 if year==2021 | (year==2020 & week==52) 
gen _m2022 = 1 if year==2022 | (year==2021 & week==52) 
gen _m2023 = 1 if year==2023 | (year==2022 & week==52) 
gen _m2024 = 1 if year==2024 | (year==2023 & week==52) 


***** final graph here


	*local t1 : lab geo2  `k'
	*local t2 : lab prov2 `k'

*colorpalette Red, luminate(0(5)100, level)
colorpalette tableau, nograph

colorpalette d3 20c, nograph





   twoway	///
			`circle' ///
			`spike'	 ///
			(function  sqrt(`cmin'^2 - x^2), recast(area) fc(black) fi(100) lc(black) lw(0.1) lp(solid) range(-`cmin' `cmin')) ///
			(function -sqrt(`cmin'^2 - x^2), recast(area) fc(black) fi(100) lc(black) lw(0.1) lp(solid) range(-`cmin' `cmin')) ///
				(scatter py1 px1, mc(none) ms(point) mlab(marker1) mlabpos(0) mlabc(white) mlabsize(1.5)) ///
				(scatter py2 px2, mc(none) ms(point) mlab(marker2) mlabpos(0) mlabc(white) mlabsize(1.5)) ///
				(scatter yvar xvar, mc(none) ms(point) mlab(xvar) mlabpos(0) mlabc(white) mlabangle(vertical) mlabsize(1.5))  ///
					(line _y _x if year  < 2020, lc(gs6)  lp(solid) lw(0.08)) ///
					(line _y _x if _m2020 == 1, lc("`r(p1)'")  lp(solid) lw(0.4)) ///
					(line _y _x if _m2021 == 1, lc("`r(p2)'")  lp(solid) lw(0.08)) ///
					(line _y _x if _m2022 == 1, lc("`r(p3)'")  lp(solid) lw(0.08)) ///
					(line _y _x if _m2023 == 1, lc("`r(p4)'")  lp(solid) lw(0.08)) ///
					(line _y _x if _m2024 == 1, lc("`r(p5)'")  lp(solid) lw(0.4)) ///
					,    ///
					legend(order(44 "2000-2019" 45 "2020" 46 "2021-23" 49 "2024") pos(6) rows(1))   ///
						xscale(off) yscale(off)	///
						xsize(1) ysize(1) aspect(1)  ///
						xlabel(-`cmax' `cmax', nogrid) ylabel(-`cmax' `cmax', nogrid) ///
						title("{fontface Merriweather Bold:Weekly deaths in Austria}") ///
						note("#30DayChartChallenge 2026 Day26: Trend. Data: Eurostat. @AsjadNaqvi.", size(tiny)) scheme(neon)
	
graph export "30daychartchallenge_day26.png", replace wid(4000)
	 

	 
				
heatplot y i.year i.week,  ///
	 color(matplotlib hot) cuts(1150(100)2550) size ///
		xlabel(, labsize(2.1) angle(90) nogrid) ///
		ylabel(, labsize(2.1) nogrid)  ///
			xtitle("Week") ///
			ytitle("Year")	///
			legend(subtitle("")) ramp	///
			title("{fontface Merriweather Bold:Weekly deaths in Austria}") ///
			note("#30DayChartChallenge 2026 Day26: Trend. Data: Eurostat. @AsjadNaqvi.", size(tiny)) scheme(neon)	///
			xsize(2) ysize(1)
		

graph export "30daychartchallenge_day26_v2.png", replace wid(4000)
	
