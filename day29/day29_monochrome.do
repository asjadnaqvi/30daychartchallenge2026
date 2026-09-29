clear
graph set window fontface "Abel"  // set graph font here

cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"


import excel using "ECB Data Portal long_20260429204754.xlsx", clear first sheet("DATA(MIR)") case(lower)

gen country = substr(serieskey, 7, 2)

gen date2 = date(date, "YMD")

format date2 %tdMon-CCYY

gen year  = year(date2)
gen month = month(date2)

drop obsstatus obscomment

ren obsvalue value

tab year
drop if year==2026

*net install joyplot, from("D:\Dropbox\STATA - JOYPLOT\installation") replace

HCL grays
