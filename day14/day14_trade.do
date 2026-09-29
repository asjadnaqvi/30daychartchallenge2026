clear all

cap cd "D:\Dropbox\STATA - BACI"
cap cd "C:\Users\asjad\Dropbox\STATA - BACI"





use "./03_split/BACI_HS22_Y2024.dta", clear

keep if code1 == 2505


count




compress


// add FROM region classifications

ren ex_iso3 iso3
merge m:1 iso3 using "./03_split/country_classification"
drop if _m==2
drop _m
drop countryname admin*
drop lending* 
ren region 			wb_ex_region
ren regionname 		wb_ex_regionname
ren incomelevel 	wb_ex_inclevel
ren incomelevelname wb_ex_inclevelname

merge m:1 iso3 using "../WORLD BANK C3A DATA/03_split/un_regions"
drop if _m==2
drop _m
ren subregion_alpha from_subregion_un
ren region_alpha from_region_un
ren iso3 ex_iso3


// add TO region classifications

ren im_iso3 iso3
merge m:1 iso3 using "./03_split/country_classification"
drop if _m==2
drop _m
drop countryname admin*
drop lending* 
ren region 			wb_im_region
ren regionname 		wb_im_regionname
ren incomelevel 	wb_im_inclevel
ren incomelevelname wb_im_inclevelname

merge m:1 iso3 using "../WORLD BANK C3A DATA/03_split/un_regions"
drop if _m==2
drop _m

ren subregion_alpha to_subregion_un
ren region_alpha to_region_un
ren iso3 im_iso3


*** clean up

replace to_subregion_un 	= "Asia - Not classified" if im_iso3=="S19"
replace from_subregion_un 	= "Asia - Not classified" if ex_iso3=="S19"

replace from_subregion_un  	= "Americas - Caribbean" if from_subregion_un =="Islands - Caribbean"
replace to_subregion_un  	= "Americas - Caribbean" if to_subregion_un =="Islands - Caribbean"

replace from_subregion_un  	= "Middle East" if from_subregion_un =="Asia - West"
replace to_subregion_un  	= "Middle East" if to_subregion_un =="Asia - West"

replace from_subregion_un  	= "Asia - Central" if from_region_un =="Europe and Central Asia" 	& from_subregion_un =="Asia - West"
replace to_subregion_un  	= "Asia - Central" if   to_region_un =="Europe and Central Asia" 	&   to_subregion_un =="Asia - West"

replace from_subregion_un  	= "Oceania - Islands" if from_subregion_un =="Islands - Other"
replace to_subregion_un  	= "Oceania - Islands" if to_subregion_un =="Islands - Other"


replace from_region_un  = "Europe" if from_region_un =="Europe and Central Asia" & from_region_un ==""
replace   to_region_un  = "Europe" if   to_region_un =="Europe and Central Asia" &   to_region_un ==""

replace from_region_un  = "Middle East" if from_subregion_un =="Middle East"
replace   to_region_un  = "Middle East" if   to_subregion_un =="Middle East"


replace from_subregion_un  	= "Europe - Islands" 	if ex_region =="Europe" 		& from_subregion_un =="Islands - Other"
replace to_subregion_un  	= "Europe - Islands" 	if im_region =="Europe" 		& to_subregion_un =="Islands - Other"




drop if inlist(ex_subregion, "Melanesia", "Micronesia", "Polynesia")
drop if inlist(im_subregion, "Melanesia", "Micronesia", "Polynesia")



replace wb_ex_regionname = "East Asia and Pacific" if ex_iso3=="S19"
replace wb_im_regionname = "East Asia and Pacific" if im_iso3=="S19"


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
	
	
	