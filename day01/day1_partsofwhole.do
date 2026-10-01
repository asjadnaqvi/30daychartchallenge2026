clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026\day01"


*** day 1: parts of whole ****

/*
*eurostatdata nrg_bal_c, clear stub(y) noflags

use nrg_bal_c, clear
tab geo
keep if geo=="EU27_2020"

tab unit
keep if unit=="GWH"
drop unit*

save nrg_bal_c_small, replace
*/

*drop y1990-y2022
*keep if geo=="EU27_2020"


use nrg_bal_c_small, clear

tab freq
drop freq*

tab siec

gen ones = 1

bysort nrg_bal: egen _count = sum(ones)

drop if _count < 60

egen tag = tag(nrg_bal)
list nrg_bal nrg_bal_label _count if tag==1




keep if inlist(nrg_bal, "FC_E")

drop y1990-y2023

drop geo*
drop ones _count tag
compress

*------------------------------------------------------------*
* 1. Keep original variables
*------------------------------------------------------------*
*keep siec siec_label
gen str40 lvl1 = ""
gen str60 lvl2 = ""
gen str80 lvl3 = siec_label

*------------------------------------------------------------*
* 2. Drop cross-cuts / top aggregates / broad containers
*------------------------------------------------------------*
drop if inlist(siec, ///
    "C0350-0370", ///
    "O4000XBIO", ///
    "P1000", ///
    "W6100_6220", ///
    "TOTAL", ///
    "FE", ///
    "BIOE", ///
    "RA000")

	
*------------------------------------------------------------*
* 3. Drop categories you do not want in the final hierarchy
*------------------------------------------------------------*
drop if inlist(siec, ///
    "E7000", "H8000", ///
    "C0350", "C0360", "C0371", "C0379")	
	
*------------------------------------------------------------*
* 3. Assign level 1 and level 2 hierarchy
*------------------------------------------------------------*

* --- Coal / solid fossil fuels
replace lvl1 = "Fossil energy"        if inlist(siec, "C0110","C0121","C0129","C0210","C0220")
replace lvl1 = "Fossil energy"        if inlist(siec, "C0311","C0312","C0320","C0330","C0340")	


replace lvl2 = "Solid fossil fuels"   if inlist(siec, "C0110","C0121","C0129","C0210","C0220")
replace lvl2 = "Solid fossil fuels"   if inlist(siec, "C0311","C0312","C0320","C0330","C0340")

replace lvl2 = "Manufactured gases"   if inlist(siec, "C0350","C0360","C0371","C0379")


replace lvl2 = "Oil and petroleum products" if inlist(siec, "O4653", "O4661XR5230B", "O4669", "O4671XR5220B")


* --- Natural gas
replace lvl1 = "Fossil energy" if siec == "G3000"
replace lvl2 = "Natural gas"   if siec == "G3000"

* --- Oil and petroleum products
replace lvl1 = "Fossil energy"        if inlist(siec, "O4100_TOT","O4200","O4610","O4620","O4630","O4640","O4651","O4652XR5210B", "O4653")
replace lvl1 = "Fossil energy"        if inlist(siec, "O4661XR5230B" ,"O4669","O4671XR5220B","O4680")
replace lvl1 = "Fossil energy"        if inlist(siec, "O4691","O4692","O4693", "O4694","O4695","O4699")
	
	
replace lvl2 = "Oil and petroleum products" if inlist(siec, "O4100_TOT","O4200","O4610","O4620","O4630","O4640","O4651","O4652XR5210B")
replace lvl2 = "Oil and petroleum products" if inlist(siec, "O4680","O4691","O4692","O4693", "O4694","O4695","O4699")
replace lvl2 = "Oil and petroleum products" if inlist(siec, "O4691","O4692","O4693", "O4694","O4695","O4699")


* --- Peat
replace lvl1 = "Fossil energy" 			if inlist(siec, "P1100","P1200")
replace lvl2 = "Peat and peat products" if inlist(siec, "P1100","P1200")

* --- Oil shale / oil sands
replace lvl1 = "Fossil energy" 			if siec == "S2000"
replace lvl2 = "Oil shale and oil sands" if siec == "S2000"

* --- Biofuels / renewable fuels
replace lvl1 = "Renewables and biofuels" if inlist(siec, "R5110-5150_W6000RI","R5160","R5210B","R5210P")
replace lvl1 = "Renewables and biofuels" if inlist(siec, "R5220B","R5220P", "R5230B","R5230P","R5290","R5300")

replace lvl2 = "Bioenergy and biofuels" if inlist(siec, "R5110-5150_W6000RI","R5160","R5210B","R5210P")
replace lvl2 = "Bioenergy and biofuels" if inlist(siec, "R5220B","R5220P", "R5230B","R5230P","R5290","R5300")


* --- Other renewables
replace lvl1 = "Renewables and biofuels" if inlist(siec, "RA200","RA410","RA600")
replace lvl2 = "Other renewables" 		if inlist(siec, "RA200","RA410","RA600")

* --- Electricity and heat
replace lvl1 = "Energy carriers"      if inlist(siec, "E7000","H8000")
replace lvl2 = "Secondary energy"     if inlist(siec, "E7000","H8000")


* --- Waste
replace lvl1 = "Waste" if inlist(siec, "W6100","W6210","W6220")
replace lvl2 = "Industrial waste" if siec == "W6100"
replace lvl2 = "Municipal waste"  if inlist(siec, "W6210","W6220")
replace lvl3 = "Industrial waste (non-renewable)" if siec == "W6100"

*------------------------------------------------------------*
* 4. Check for anything left unclassified
*------------------------------------------------------------*
*list siec siec_label if missing(lvl1) | missing(lvl2), noobs sepby(lvl1)

*------------------------------------------------------------*
* 5. Optional: order and inspect hierarchy
*------------------------------------------------------------*
order lvl1 lvl2 lvl3 siec siec_label
sort lvl1 lvl2 lvl3
*list, sepby(lvl1 lvl2) noobs

*------------------------------------------------------------*
* 6. Optional: create numeric IDs for plotting/export
*------------------------------------------------------------*
*egen id_lvl1 = group(lvl1)
*egen id_lvl2 = group(lvl1 lvl2)
*egen id_lvl3 = group(lvl1 lvl2 lvl3)


drop if inlist(siec, "E7000", "H8000")
drop if inlist(siec, "C0350", "C0360", "C0371", "C0379")


drop siec*
drop nrg*

drop if missing(lvl2)


graph set window fontface "Abel"

treemap y2024, by(lvl2 lvl3) addtitle labprop labsize(1.5 1.2) titleprop ratio(2) labcond(100e2) wrap(0 20) titlestyle(bold) ///
	palette( #C89A4F #C04A6A #4CAF50 #56D6D0 #B0B0B0) labscale(0.2) format(%15.0fc) ///
	title("{fontface Merriweather Bold:Final consumption of energy (Gigawatt Hours) in the EU27 (2020) in 2024}", size(3.8)) ///
	note("Source: Eurostat. #30DayChartChallenge 2026. @AsjadNaqvi.", size(1.8)) scheme(neon)
graph export 30daychartchallenge_day1.png, replace wid(3000)
	
sunburst y2024, by(lvl2 lvl3) full labsize(1.5 1.5) radius(0.1 30 50) wrap(20) labprop colorprop rotate(90) labcond(10000) lc(black) lw(0.04 0.001) ///
	palette( #E0B85A #D96AC2 #66C56C #56D6D0 #B0B0B0) ///
	title("{fontface Merriweather Bold:Final consumption of energy in the EU27 (2020) in 2024}", size(2.8)) ///
	subtitle("(Gigawatt Hours)", size(2)) ///
	note("Source: Eurostat. #30DayChartChallenge 2026. @AsjadNaqvi.", size(1.5)) scheme(neon)
	
graph export 30daychartchallenge_day1_2.png, replace wid(3000)

