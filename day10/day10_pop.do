clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day10"

*ssc install tidytuesday, replace
*tidytuesday, year(2021)

*tidytuesday get, year(2021) week(38) // billboard top 100


use billboard.dta, clear
drop url

replace week_id = ustrtrim(week_id)


*gen date_var = date(week_id, "DMY")
*format date_var %td

cap drop year
*gen year = year(date_var)
gen year = substr(week_id, -4, .)
destring year, replace

collapse (max) peak_position weeks_on_chart year, by(song performer)
compress
save billboard_clean.dta, replace



use audio_features.dta, clear
drop spotify_track_id spotify_track_preview_url

ren performer performer2
gen str100 performer = performer2

merge m:1 song performer using billboard_clean
drop if _m!=3
drop _m


foreach x of varlist spotify_track_duration_ms - spotify_track_popularity {
	replace `x' = "" if `x' =="NA"
	destring `x', replace
}


replace spotify_genre = subinstr(spotify_genre, "['", "", . )
replace spotify_genre = subinstr(spotify_genre, "']", "", . )
replace spotify_genre = subinstr(spotify_genre, "'", "", . )
replace spotify_genre = subinstr(spotify_genre, "NA", "", . )
replace spotify_genre = subinstr(spotify_genre, "[]", "", . )

split spotify_genre, p(",") gen(_g)

ds _g*
foreach v of varlist `r(varlist)' {
    replace `v' = strtrim(`v')
}



egen _rows = rownonmiss(_g*), strok
tab _rows
drop if _row==0

*cap drop has_pop
*gen has_pop = regexm(spotify_genre, "(^|[^a-z])pop([^a-z]|$)")
*gen has_pop = regexm(spotify_genre, "(^|, )pop(,|$)")
*gen has_pop = regexm(spotify_genre, "(^|, * )pop( * ,|$)")
*tab has_pop


* extract last occurrence of "pop"
gen last_pop = ""

ds _g*
foreach v of varlist `r(varlist)' {
    replace last_pop = `v' if regexm(`v', "\bpop\b")
}


/*
gen has_pop2 = regexm(_g1, "(^|[^a-z])pop([^a-z]|$)")
tab has_pop2
tab _g1 if has_pop2==1

gen last_pop = regexs(0) if regexm(lower(spotify_genre), ".*(\b[^,]*pop[^,]*\b)[^,]*$")
*/

gen ones = 1

label year "Year"

bumpline ones year if !missing(last_pop) & year >= 2000, ///
	by(last_pop) top(20) xsize(3) ysize(1) palette(CET L20, reverse) labc(white) ///
	olcolor(gs4) olabcolor(gs11) olabsize(2)	///
	xtitle("")  offset(10) mlwid(0.2) msize(0.5) scheme(neon)	///
	title("{fontface Merriweather Bold:How are Billboard Top 100 Pop songs classified on Spotify by finest categories (2000-2021)}")	///
	note("#30DayChartChallenge 2026 Day10: Pop. Data: TidyTuesday 2021 Week38. @AsjadNaqvi.", size(2))

graph export 30daychartchallenge_day10.png, replace wid(4000)







