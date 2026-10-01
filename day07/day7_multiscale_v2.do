clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge2026/day07"


*** day 4: lines ****

*** income by quintile
*eurostatdata prc_hicp_minr, clear stub(y) noflags

use nrg_bal_c, clear


keep freq-geo_label y2024

tab freq
drop freq*


tab unit
keep if unit=="GWH"
drop unit*

tab siec
keep if siec=="TOTAL"
drop siec*



tab geo
keep if geo=="EU27_2020"

***** form sankey




compress
*export delim using energy_balance_raw.csv, replace




*------------------------------------------------------*
* 7. Optional: drop negative / missing values
*    For Sankey, negative flows are usually problematic
*------------------------------------------------------*

ren y2024 value

drop if missing(value)
*drop if value <= 0



list nrg_bal value if inlist(nrg_bal, ///
"PPRD","IMP","RCV_RCY","STK_CHG","STATDIFF","EXP","NRGSUP")


*------------------------------------------------------*
* 8. Collapse across energy products if desired
*    If you want total energy balance across all SIEC
*------------------------------------------------------*
collapse (sum) value, by(geo geo_label nrg_bal nrg_bal_label)

replace value = abs(value)

gen from = ""
gen to   = ""
gen layer = .



*------------------------------------------------------*
* Build helper variables directly from the unique rows
*------------------------------------------------------*
*gen stock_draw  = 0

summ value if nrg_bal == "STK_CHG"
	if r(max) >= 0 {
		egen stock_draw = max(`r(max)') 
	}
	
summ value if nrg_bal == "STK_CHG"	
	if r(max) < 0 {
		egen stock_build = max(abs(`r(max)')) 
	}
	else {
		gen stock_build = 0
	}


summ value if nrg_bal == "STATDIFF"	

	if r(max) >= 0 {
		egen stat_in = max(`r(max)') 
	}
	
summ value if nrg_bal == "STATDIFF"	
	if r(max) < 0 {
		egen stat_out = max(abs(`r(max)')) 
	}
	else {
		gen stat_out = 0
	}
	
/*	
gen stat_in = 0
replace stat_in = value if nrg_bal == "STATDIFF" & value > 0

gen stat_out = 0
replace stat_out = -value if nrg_bal == "STATDIFF" & value < 0
*/

egen pprd      = max(cond(nrg_bal=="PPRD",      value, .))
egen imp       = max(cond(nrg_bal=="IMP",       value, .))
egen rcv       = max(cond(nrg_bal=="RCV_RCY",   value, .))
egen stk_draw  = max(stock_draw)
egen stk_build = max(stock_build)
egen stin      = max(stat_in)
egen stout     = max(stat_out)

egen ti_e      = max(cond(nrg_bal=="TI_E",      value, .))
egen expv      = max(cond(nrg_bal=="EXP",       value, .))
egen intmarb   = max(cond(nrg_bal=="INTMARB",   value, .))
egen intavi    = max(cond(nrg_bal=="INTAVI",    value, .))
egen dlv       = max(cond(nrg_bal=="DL",        value, .))
egen nrge      = max(cond(nrg_bal=="NRG_E",     value, .))

egen fc_e      = max(cond(nrg_bal=="FC_E",      value, .))
egen fc_ne     = max(cond(nrg_bal=="FC_NE",     value, .))

egen fc_ind    = max(cond(nrg_bal=="FC_IND_E",     value, .))
egen fc_tra    = max(cond(nrg_bal=="FC_TRA_E",     value, .))
egen fc_oth    = max(cond(nrg_bal=="FC_OTH_E",     value, .))

egen fc_hh     = max(cond(nrg_bal=="FC_OTH_HH_E",   value, .))
egen fc_cp     = max(cond(nrg_bal=="FC_OTH_CP_E",   value, .))
egen fc_af     = max(cond(nrg_bal=="FC_OTH_AF_E",   value, .))
egen fc_fish   = max(cond(nrg_bal=="FC_OTH_FISH_E", value, .))
egen fc_onsp   = max(cond(nrg_bal=="FC_OTH_NSP_E",  value, .))

egen tra_road  = max(cond(nrg_bal=="FC_TRA_ROAD_E",  value, .))
egen tra_rail  = max(cond(nrg_bal=="FC_TRA_RAIL_E",  value, .))
egen tra_davi  = max(cond(nrg_bal=="FC_TRA_DAVI_E",  value, .))
egen tra_dnavi = max(cond(nrg_bal=="FC_TRA_DNAVI_E", value, .))
egen tra_pipe  = max(cond(nrg_bal=="FC_TRA_PIPE_E",  value, .))
egen tra_nsp   = max(cond(nrg_bal=="FC_TRA_NSP_E",   value, .))

egen ind_con   = max(cond(nrg_bal=="FC_IND_CON_E", value, .))
egen ind_cpc   = max(cond(nrg_bal=="FC_IND_CPC_E", value, .))
egen ind_is    = max(cond(nrg_bal=="FC_IND_IS_E",  value, .))
egen ind_mac   = max(cond(nrg_bal=="FC_IND_MAC_E", value, .))
egen ind_mq    = max(cond(nrg_bal=="FC_IND_MQ_E",  value, .))
egen ind_nfm   = max(cond(nrg_bal=="FC_IND_NFM_E", value, .))
egen ind_nmm   = max(cond(nrg_bal=="FC_IND_NMM_E", value, .))
egen ind_nsp   = max(cond(nrg_bal=="FC_IND_NSP_E", value, .))
egen ind_ppp   = max(cond(nrg_bal=="FC_IND_PPP_E", value, .))
egen ind_fbt   = max(cond(nrg_bal=="FC_IND_FBT_E", value, .))
egen ind_te    = max(cond(nrg_bal=="FC_IND_TE_E",  value, .))
egen ind_tl    = max(cond(nrg_bal=="FC_IND_TL_E",  value, .))
egen ind_wp    = max(cond(nrg_bal=="FC_IND_WP_E",  value, .))
egen ind_ne    = max(cond(nrg_bal=="FC_IND_NE",    value, .))

*------------------------------------------------------*
* Derived accounting identities
*------------------------------------------------------*
gen avail_sources = pprd + imp + rcv + stk_draw + stin
gen direct_carry  = avail_sources - ti_e
replace direct_carry = abs(direct_carry) if direct_carry < 0

gen final_total = fc_e + fc_ne

gen avail_after = final_total + expv + intmarb + intavi + dlv + nrge + stk_build + stout

gen trans_out  = avail_after - direct_carry
replace trans_out = abs(trans_out) if trans_out < 0

gen trans_loss = ti_e - trans_out
replace trans_loss = abs(trans_loss) if trans_loss < 0

*------------------------------------------------------*
* Keep one row only; all helper vars now constant
*------------------------------------------------------*
keep in 1

*------------------------------------------------------*
* Create one row per edge
*------------------------------------------------------*


gen transport_other = fc_tra ///
    - tra_road - tra_rail - tra_davi - tra_dnavi - tra_pipe - tra_nsp
replace transport_other = 0 if transport_other < 0

gen industry_other = fc_ind ///
    - ind_con - ind_cpc - ind_is - ind_mac - ind_mq - ind_nfm ///
    - ind_nmm - ind_nsp - ind_ppp - ind_fbt - ind_te - ind_tl ///
    - ind_wp
replace industry_other = 0 if industry_other < 0

gen other_other = fc_oth - fc_hh - fc_cp - fc_af - fc_fish - fc_onsp
replace other_other = 0 if other_other < 0

*------------------------------------------------------*
* Create one row per edge
*------------------------------------------------------*
gen edge_id = .
expand 51
replace edge_id = _n

gen value_edge = .

*------------------------------------------------------*
* Layer 1: inputs -> available from all sources
*------------------------------------------------------*
replace from = "Primary production"                 in 1
replace to   = "Available from all sources"         in 1
replace value_edge = pprd                           in 1
replace layer = 1                                   in 1

replace from = "Imports"                            in 2
replace to   = "Available from all sources"         in 2
replace value_edge = imp                            in 2
replace layer = 1                                   in 2

replace from = "Recovered/Recycled"                 in 3
replace to   = "Available from all sources"         in 3
replace value_edge = rcv                            in 3
replace layer = 1                                   in 3

replace from = "Stock draw"                         in 4
replace to   = "Available from all sources"         in 4
replace value_edge = stk_draw                       in 4
replace layer = 1                                   in 4

replace from = "Statistical difference - inflow"    in 5
replace to   = "Available from all sources"         in 5
replace value_edge = stin                           in 5
replace layer = 1                                   in 5

*------------------------------------------------------*
* Layer 2: pre-transformation split
*------------------------------------------------------*
replace from = "Available from all sources"         in 6
replace to   = "Direct carry-over"                  in 6
replace value_edge = direct_carry                   in 6
replace layer = 2                                   in 6

replace from = "Available from all sources"         in 7
replace to   = "Transformation input"               in 7
replace value_edge = ti_e                           in 7
replace layer = 2                                   in 7

*------------------------------------------------------*
* Layer 3: transformation
* Directly connect transformation input to
* available after transformation
*------------------------------------------------------*
replace from = "Transformation input"               in 8
replace to   = "Available after transformation"     in 8
replace value_edge = trans_out                      in 8
replace layer = 3                                   in 8

replace from = "Transformation input"               in 9
replace to   = "Transformation losses"              in 9
replace value_edge = trans_loss                     in 9
replace layer = 3                                   in 9

*------------------------------------------------------*
* Layer 4: direct carry-over to available after transformation
*------------------------------------------------------*
replace from = "Direct carry-over"                  in 10
replace to   = "Available after transformation"     in 10
replace value_edge = direct_carry                   in 10
replace layer = 4                                   in 10

*------------------------------------------------------*
* Layer 5: final allocation
*------------------------------------------------------*
replace from = "Available after transformation"     in 11
replace to   = "Final consumption"                  in 11
replace value_edge = final_total                    in 11
replace layer = 5                                   in 11

replace from = "Available after transformation"     in 12
replace to   = "Exports"                            in 12
replace value_edge = expv                           in 12
replace layer = 5                                   in 12

replace from = "Available after transformation"     in 13
replace to   = "Marine bunkers"                     in 13
replace value_edge = intmarb                        in 13
replace layer = 5                                   in 13

replace from = "Available after transformation"     in 14
replace to   = "International aviation"             in 14
replace value_edge = intavi                         in 14
replace layer = 5                                   in 14

replace from = "Available after transformation"     in 15
replace to   = "Transmission and distribution losses" in 15
replace value_edge = dlv                            in 15
replace layer = 5                                   in 15

replace from = "Available after transformation"     in 16
replace to   = "Consumption of the energy branch"   in 16
replace value_edge = nrge                           in 16
replace layer = 5                                   in 16

replace from = "Available after transformation"     in 17
replace to   = "Stock build"                        in 17
replace value_edge = stk_build                      in 17
replace layer = 5                                   in 17

replace from = "Available after transformation"     in 18
replace to   = "Statistical difference - outflow"   in 18
replace value_edge = stout                          in 18
replace layer = 5                                   in 18

*------------------------------------------------------*
* Layer 6: split final consumption
*------------------------------------------------------*
replace from = "Final consumption"                  in 19
replace to   = "Final energy consumption"           in 19
replace value_edge = fc_e                           in 19
replace layer = 6                                   in 19

replace from = "Final consumption"                  in 20
replace to   = "Non-energy use"                     in 20
replace value_edge = fc_ne                          in 20
replace layer = 6                                   in 20

*------------------------------------------------------*
* Layer 7: split final energy consumption
*------------------------------------------------------*
replace from = "Final energy consumption"           in 21
replace to   = "Industry"                           in 21
replace value_edge = fc_ind                         in 21
replace layer = 7                                   in 21

replace from = "Final energy consumption"           in 22
replace to   = "Transport"                          in 22
replace value_edge = fc_tra                         in 22
replace layer = 7                                   in 22

replace from = "Final energy consumption"           in 23
replace to   = "Other sectors"                      in 23
replace value_edge = fc_oth                         in 23
replace layer = 7                                   in 23

*------------------------------------------------------*
* Layer 8: other sectors detail
*------------------------------------------------------*
replace from = "Other sectors"                      in 24
replace to   = "O:Households"                         in 24
replace value_edge = fc_hh                          in 24
replace layer = 8                                   in 24

replace from = "Other sectors"                      in 25
replace to   = "O:Commercial / Public services"       in 25
replace value_edge = fc_cp                          in 25
replace layer = 8                                   in 25

replace from = "Other sectors"                      in 26
replace to   = "O:Agriculture / Forestry"             in 26
replace value_edge = fc_af                          in 26
replace layer = 8                                   in 26

replace from = "Other sectors"                      in 27
replace to   = "O:Fishing"                            in 27
replace value_edge = fc_fish                        in 27
replace layer = 8                                   in 27

replace from = "Other sectors"                      in 28
replace to   = "O:Other sectors n.e.c."               in 28
replace value_edge = fc_onsp                        in 28
replace layer = 8                                   in 28

replace from = "Other sectors"                      in 29
replace to   = "O:Other other sectors"                in 29
replace value_edge = other_other                    in 29
replace layer = 8                                   in 29

*------------------------------------------------------*
* Layer 8: transport detail
*------------------------------------------------------*
replace from = "Transport"                          in 30
replace to   = "T:Road transport"                     in 30
replace value_edge = tra_road                       in 30
replace layer = 8                                   in 30

replace from = "Transport"                          in 31
replace to   = "T:Rail transport"                     in 31
replace value_edge = tra_rail                       in 31
replace layer = 8                                   in 31

replace from = "Transport"                          in 32
replace to   = "T:Domestic aviation"                  in 32
replace value_edge = tra_davi                       in 32
replace layer = 8                                   in 32

replace from = "Transport"                          in 33
replace to   = "T:Domestic navigation"                in 33
replace value_edge = tra_dnavi                      in 33
replace layer = 8                                   in 33

replace from = "Transport"                          in 34
replace to   = "T:Pipeline transport"                 in 34
replace value_edge = tra_pipe                       in 34
replace layer = 8                                   in 34

replace from = "Transport"                          in 35
replace to   = "T:Transport n.e.c."                   in 35
replace value_edge = tra_nsp                        in 35
replace layer = 8                                   in 35

replace from = "Transport"                          in 36
replace to   = "T:Other transport"                    in 36
replace value_edge = transport_other                in 36
replace layer = 8                                   in 36

*------------------------------------------------------*
* Layer 8: industry detail
*------------------------------------------------------*
replace from = "Industry"                           in 37
replace to   = "I:Construction"                       in 37
replace value_edge = ind_con                        in 37
replace layer = 8                                   in 37

replace from = "Industry"                           in 38
replace to   = "I:Chemicals / Petrochemicals"         in 38
replace value_edge = ind_cpc                        in 38
replace layer = 8                                   in 38

replace from = "Industry"                           in 39
replace to   = "I:Iron and steel"                     in 39
replace value_edge = ind_is                         in 39
replace layer = 8                                   in 39

replace from = "Industry"                           in 40
replace to   = "I:Machinery"                          in 40
replace value_edge = ind_mac                        in 40
replace layer = 8                                   in 40

replace from = "Industry"                           in 41
replace to   = "I:Mining and quarrying"               in 41
replace value_edge = ind_mq                         in 41
replace layer = 8                                   in 41

replace from = "Industry"                           in 42
replace to   = "I:Non-ferrous metals"                 in 42
replace value_edge = ind_nfm                        in 42
replace layer = 8                                   in 42

replace from = "Industry"                           in 43
replace to   = "I:Non-metallic minerals"              in 43
replace value_edge = ind_nmm                        in 43
replace layer = 8                                   in 43

replace from = "Industry"                           in 44
replace to   = "I:Industry n.e.c."                    in 44
replace value_edge = ind_nsp                        in 44
replace layer = 8                                   in 44

replace from = "Industry"                           in 45
replace to   = "I:Paper, pulp and printing"           in 45
replace value_edge = ind_ppp                        in 45
replace layer = 8                                   in 45

replace from = "Industry"                           in 46
replace to   = "I:Food, beverages, tobacco"           in 46
replace value_edge = ind_fbt                        in 46
replace layer = 8                                   in 46

replace from = "Industry"                           in 47
replace to   = "I:Transport equipment"                in 47
replace value_edge = ind_te                         in 47
replace layer = 8                                   in 47

replace from = "Industry"                           in 48
replace to   = "I:Textile and leather"                in 48
replace value_edge = ind_tl                         in 48
replace layer = 8                                   in 48

replace from = "Industry"                           in 49
replace to   = "I:Wood and wood products"             in 49
replace value_edge = ind_wp                         in 49
replace layer = 8                                   in 49

/*
replace from = "Industry"                           in 50
replace to   = "Industry non-energy use"            in 50
replace value_edge = ind_ne                         in 50
replace layer = 8                                   in 50
*/

replace from = "Industry"                           in 51
replace to   = "I:Other industry"                     in 51
replace value_edge = industry_other                 in 51
replace layer = 8                                   in 51


replace layer = 3 in 8   // keep
replace layer = 3 in 10  // move from 4 → 3


*------------------------------------------------------*
* Finalize edge list
*------------------------------------------------------*
keep from to value_edge layer
rename value_edge value
*drop if missing(value) | value <= 0

order from to value layer
sort layer from to
list, clean noobs


sankey value, f(from) t(to) by(layer) format(%15.0fc) smooth(8) palette(w3 2017) ///
	laba(0) wrap(30) xsize(5) ysize(2) noval showtotal labsize(2.3) labcolor(white) labprop	///
	plotregion(margin(l+8 r+8)) boxw(8) labscale(0.2)	///
	ctitle("{bf:Inputs}" "{bf:Supply}" "{bf:Transformation}" "" "{bf:Final allocation}" "" "{bf:Consumption by sectors}") ctgap(5) ctpos(top) ctc(white) ///
	title("{fontface Merriweather Bold:Energy production and consumption in the EU27 in 2024 (GWH)}", size(6))	///
	note("#30DayChartChallenge 2026 Day7: Multiscale. Data: Eurostat Energy Balance tables. @AsjadNaqvi", size(2)) scheme(neon)

graph export energy_bal_sankey.png, replace wid(3000)




