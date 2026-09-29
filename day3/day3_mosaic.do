clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"


*** day 3: mosaic ****

*** income by quintile
*eurostatuse2 ilc_di01, clear stub(y) noflags

use ilc_di01, clear
drop freq*

tab quantile
keep if inlist(quantile, "QU1", "QU2", "QU3", "QU4", "QU5" )
*drop quantile*


tab currency
keep if currency=="EUR"
drop currency*


sort geo indic_il

tab indic_il
keep if indic_il=="SHARE"
drop indic*


keep quantile-geo_label y2019-y2024

ren y* incshare*



compress
save ilc_di01_clean, replace


*** expenditure by quintile

*eurostatuse2 hbs_str_t223, clear stub(y) noflags

use hbs_str_t223, clear
tab freq
drop freq*


tab quant_inc

drop if quant_inc=="UNK"

tab coicop
tab coicop_label

keep if length(coicop)==4


tab unit // this per mille or per 1000
drop unit*

tab geo


sort geo coicop quant_inc
drop y1988-y2015

drop if y2020==.

tab geo
ren y* exp*

ren quant_inc quantile

merge m:1 quantile geo using ilc_di01_clean
keep if _m==3

*cap drop tag
*egen tag = tag(quantile geo) 

replace incshare2021 = incshare2021 / 12 

gen quant2 = subinstr(quantile, "QU", "", .)
destring quant2, replace
labmask quant2, val(quant_inc_label)


gen coicop2 = subinstr(coicop, "CP", "", .)
destring coicop2, replace

*labwrap coicop_label, wrap(20)

replace coicop_label = "Furnishings, household equipment, maintenance" if coicop_label == "Furnishings, household equipment and routine household maintenance"

labmask coicop2, val(coicop_label)




marimekko exp2020 incshare2021 if geo=="DE", by(quant_inc_label) over(coicop2) reverse ///
	palette(tab Green-Orange-Teal) legrows(4) legsize(2.2) lc(black) lw(0.04)	///
	xtitle("Equivalized income share", size(2.6)) ///
	ytitle("Expenditure per 1000 Euros", size(2.6))	///
	xlabel(, labsize(2) nogrid) ylabel(, labsize(2) nogrid)		///
	title("{fontface Merriweather Bold:Germany - Expenditure by income quintile shares in 2020}", size(4.5) margin(medium))	///
	note("#30DayChartChallenge 2026 Day3: Mosaic. Data source: Eurostat household budget surveys. @AsjadNaqvi", size(2) )	///
	scheme(neon)


graph export 30daychartchallenge_day3.png, replace wid(5000)
	










