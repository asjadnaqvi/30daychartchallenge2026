clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day08"


***source: https://footprint.info.yorku.ca/data/
*** https://data.footprintnetwork.org/#/


import excel using "NEFBA2025_bulk_v1_0.xlsx", clear sheet("national_data") first 


tab year
keep if year==2024

drop if quality_flag=="-"


/*
polarspike biocap_total_percapita, by(country_name) format(%5.2f)  ///
	labgap(8) labsize(1) offset(10) rotate(45)
*/	
	
	
gen double earths = efp_total_percapita / 1.3568 // average for the world in 2024	

replace country_name = "Venezuela" if country_name == "Venezuela, Bolivarian Republic of"
replace country_name = "Iran" if country_name == "Iran, Islamic Republic of"

replace country_name = "North Macedonia" if country_name == "Republic of North Macedonia"
replace country_name = "Tanzania" if country_name == "Tanzania, United Republic of"
replace country_name = "Korea, Dem. Republic" if country_name == "Korea, Democratic People's Republic of"

replace country_name = "Leo Dem. Republic" if country_name == "Lao People's Democratic Republic"
replace country_name = "" if country_name == ""
replace country_name = "" if country_name == ""

polarspike earths, by(country_name) colorby(UN_region) format(%5.2f)  ///
	labgap(10) labsize(1) offset(8) rotate(45) gap(0) scheme(neon) labc(gs12) palette(538)	///
	text(0 0 "{fontface Merriweather Bold:Earth Overshoot 2024}", color(white))		///
	text(-1 0 "How many planets does each country" "need to sustain its lifestyle", color(white) size(1.6))	///
	note("#30DayChartChallenge 2026 Day8: Circular. Data: Global Footprint Network. @AsjadNaqvi", size(1.3))
	

graph export 30daychartchallenge_day8.png, replace wid(4000)
	
	
	/*
net install spider, from("D:\Dropbox\STATA - SPIDER\installation") replace	

*spider efp_total_percapita , by(country_name) rotatelab(45) slabsize(1.2) sort ra(0 1 4(4)16)



drop if missing(efp_total_percapita) & missing(biocap_total_percapita)

cap drop __val
gen __val = _n

drop if biocap_total_percapita > 20

spider efp_total_percapita biocap_total_percapita   , by(country_name) sort rotatelab(90) slabsize(1.2) 
	
	
	
	