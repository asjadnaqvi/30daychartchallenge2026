clear all


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"


*** source living planet database: https://www.livingplanetindex.org/data_portal

/*
import delim using ./LivingPlanetIndexDatabase_2026/LPD_2024_public.csv, clear  encoding(utf8) varn(1)  // bindquote(nobind)

foreach x of varlist v* {
	
	local t : var label `x'
	di "`t'"
	
	cap replace `x' = "" if `x'=="NULL"
	cap destring `x', replace
	
	cap ren `x' y`t'
	
	
}


cap drop y
cap drop v*

destring id, replace force

drop if id==.

tab class
tab region
tab system
tab t_biome



compress
save lpi_test.dta, replace
*/


use lpi_test.dta, clear

gen class_simple = ""

replace class_simple = "Fish"        if inlist(class, ///
    "Actinopteri", "Coelacanthi", "Dipneusti", ///
    "Elasmobranchii", "Holocephali", "Myxini", "Petromyzonti")

replace class_simple = "Amphibians"  if class == "Amphibia"
replace class_simple = "Birds"       if class == "Aves"
replace class_simple = "Mammals"     if class == "Mammalia"
replace class_simple = "Reptiles"    if class == "Reptilia"

tab class_simple class, m
tab class_simple

gen ones = 1


tabstat y2020, by(class_simple) c(stat) stat(mean sd min max sum)





/*

collapse (sum) y*, by(t_realm)


gen double base = y1990


foreach x of varlist y* {
	replace `x' =  (`x' / base) * 100
}


*drop if class_simple == "Mammals" 




*use lpi_test, clear
*net install spider, from("D:\Dropbox\STATA - SPIDER\installation") replace
*ssc install spider, replace

spider y1980 y1990 y2000 y2010 if t_realm!="NULL", by(t_realm ) stat(mean) 

*graph export spider_new.png, replace 



