clear

cap cd "D:\Dropbox\WORLD BANK C3A DATA"
cap cd "C:\Users\asjad\Dropbox\WORLD BANK C3A DATA"

graph set window fontface "Abel"  // set graph font here


*** source: https://datacatalog.worldbank.org/search/dataset/0038015/International-Debt-Statistics


**** set up the indicators files

/*
import excel using "./01_raw/debt/IDS_indicators_order_v2.xlsx", clear first
cap drop description 
compress
save "./03_split/debt/debt_indicators_order.dta", replace
*/

**** STEP 2: set the data structure *****


use "./06_master/IDS_master.dta", clear

*keep if markme==1
*keep if partner=="World"

merge m:1 code using "./03_split/wb_indicators_all_unique.dta"
drop if _m==2
drop _m
compress
order iso3 country iso3_partner partner code description


keep if inlist(code, "DT.DOD.DECT.GN.ZS", "DT.DOD.DECT.CD", "DT.CUR.USDL.ZS", "DT.CUR.EURO.ZS", "DT.CUR.JYEN.ZS", "DT.CUR.UKPS.ZS", "DT.CUR.SDRW.ZS", "DT.CUR.OTHC.ZS")

keep if partner=="World"




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

