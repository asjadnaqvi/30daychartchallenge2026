clear

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026\day21"


graph set window fontface "Abel"  // set graph font here



use wb_indicators_small, clear

count

*keep if debtor_layer==99

*drop y1970-y1979
cap drop y2031


sort code
*ren debtor_series series
order series

*drop y1980-y1999

drop *partner*
drop description
drop markme

greshape long y, i(series-code) j(year)

*drop if inlist(code, "DT.CUR.FFRC.ZS", "DT.DOD.PVLX.CD", "DT.DOD.PVLX.GN.ZS")

sort code year



compress

**** LOOP

replace code = lower(code)
replace code = subinstr(code, ".", "_", .)

drop series


ren year time

greshape wide y, i(iso3 country time) j(code) string



drop if time > 2023


tab country
egen tag = tag(iso3)

list iso3 country if tag==1

drop if inlist(iso3, "EAP", "ECA", "LAC", "LDC", "LMC", "LMY" )
drop if inlist(iso3, "MNA", "SSA", "UMC", "SAS", "MIC", "IDA", "IDX" )



twoway ///
	(scatter ydt_cur_usdl_zs time [fweight = ydt_dod_dect_cd], mcolor(%10) msize(1.2))	///
	(lowess ydt_cur_usdl_zs time, bwidth(0.3) lw(0.6) )	///
	, ///
	ytitle("Share of debt in U.S. Dollars (%)") ///
	xtitle("") ///
		legend(off)	///
		xlabel(1970(10)2020 2023) ///
		title("{fontface Merriweather Bold:Dollarization of Sovereign External Debt}") ///
		subtitle("(each circle represents a country weighted by its real debt stock)", size(2.8))	///
		note("#30DayChartChallenge 2026 Day21: Historical. Data: World Bank Open Data. @AsjadNaqvi", size(2))	///
		scheme(neon)


graph export "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026/30daychartchallenge_day21.png", replace wid(2000)

