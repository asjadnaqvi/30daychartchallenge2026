clear


cap cd "D:\Dropbox\STATA - MEDIUM\30daychartchallenge 2026"


*** day 4: lines ****

*** income by quintile
*eurostatuse2 prc_hicp_minr, clear stub(y) noflags

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
gen stock_draw  = value if nrg_bal == "STK_CHG"   & value > 0
gen stock_build = -value if nrg_bal == "STK_CHG"  & value < 0

gen stat_in  = value if nrg_bal == "STATDIFF"  & value > 0
gen stat_out = -value if nrg_bal == "STATDIFF" & value < 0

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
replace direct_carry = 0 if direct_carry < 0

gen final_total = fc_e + fc_ne

gen avail_after = final_total + expv + intmarb + intavi + dlv + nrge + stk_build + stout

gen trans_out  = avail_after - direct_carry
replace trans_out = 0 if trans_out < 0

gen trans_loss = ti_e - trans_out
replace trans_loss = 0 if trans_loss < 0

*------------------------------------------------------*
* Keep one row only; all helper vars now constant
*------------------------------------------------------*
keep in 1

*------------------------------------------------------*
* Create one row per edge
*------------------------------------------------------*
gen edge_id = _n
expand 33
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
* Layer 2: split pre-transformation supply
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
*------------------------------------------------------*
replace from = "Transformation input"               in 8
replace to   = "Transformation outputs"             in 8
replace value_edge = trans_out                      in 8
replace layer = 3                                   in 8

replace from = "Transformation input"               in 9
replace to   = "Transformation losses"              in 9
replace value_edge = trans_loss                     in 9
replace layer = 3                                   in 9

*------------------------------------------------------*
* Layer 4: recombine after transformation
*------------------------------------------------------*
replace from = "Direct carry-over"                  in 10
replace to   = "Available after transformation"     in 10
replace value_edge = direct_carry                   in 10
replace layer = 4                                   in 10

replace from = "Transformation outputs"             in 11
replace to   = "Available after transformation"     in 11
replace value_edge = trans_out                      in 11
replace layer = 4                                   in 11

*------------------------------------------------------*
* Layer 5: final allocation
*------------------------------------------------------*
replace from = "Available after transformation"     in 12
replace to   = "Final consumption"                  in 12
replace value_edge = final_total                    in 12
replace layer = 5                                   in 12

replace from = "Available after transformation"     in 13
replace to   = "Exports"                            in 13
replace value_edge = expv                           in 13
replace layer = 5                                   in 13

replace from = "Available after transformation"     in 14
replace to   = "Marine bunkers"                     in 14
replace value_edge = intmarb                        in 14
replace layer = 5                                   in 14

replace from = "Available after transformation"     in 15
replace to   = "International aviation"             in 15
replace value_edge = intavi                         in 15
replace layer = 5                                   in 15

replace from = "Available after transformation"     in 16
replace to   = "Transmission and distribution losses" in 16
replace value_edge = dlv                            in 16
replace layer = 5                                   in 16

replace from = "Available after transformation"     in 17
replace to   = "Consumption of the energy branch"   in 17
replace value_edge = nrge                           in 17
replace layer = 5                                   in 17

replace from = "Available after transformation"     in 18
replace to   = "Stock build"                        in 18
replace value_edge = stk_build                      in 18
replace layer = 5                                   in 18

replace from = "Available after transformation"     in 19
replace to   = "Statistical difference - outflow"   in 19
replace value_edge = stout                          in 19
replace layer = 5                                   in 19

*------------------------------------------------------*
* Layer 6: split final consumption
*------------------------------------------------------*
replace from = "Final consumption"                  in 20
replace to   = "Final energy consumption"           in 20
replace value_edge = fc_e                           in 20
replace layer = 6                                   in 20

replace from = "Final consumption"                  in 21
replace to   = "Non-energy use"                     in 21
replace value_edge = fc_ne                          in 21
replace layer = 6                                   in 21

*------------------------------------------------------*
* Layer 7: split final energy consumption
*------------------------------------------------------*
replace from = "Final energy consumption"           in 22
replace to   = "Industry"                           in 22
replace value_edge = fc_ind                         in 22
replace layer = 7                                   in 22

replace from = "Final energy consumption"           in 23
replace to   = "Transport"                          in 23
replace value_edge = fc_tra                         in 23
replace layer = 7                                   in 23

replace from = "Final energy consumption"           in 24
replace to   = "Other sectors"                      in 24
replace value_edge = fc_oth                         in 24
replace layer = 7                                   in 24

*------------------------------------------------------*
* Layer 8: selected detailed end uses
*------------------------------------------------------*
replace from = "Other sectors"                      in 25
replace to   = "Households"                         in 25
replace value_edge = fc_hh                          in 25
replace layer = 8                                   in 25

replace from = "Other sectors"                      in 26
replace to   = "Commercial / Public services"       in 26
replace value_edge = fc_cp                          in 26
replace layer = 8                                   in 26

replace from = "Other sectors"                      in 27
replace to   = "Agriculture / Forestry"             in 27
replace value_edge = fc_af                          in 27
replace layer = 8                                   in 27

replace from = "Transport"                          in 28
replace to   = "Road transport"                     in 28
replace value_edge = tra_road                       in 28
replace layer = 8                                   in 28

replace from = "Transport"                          in 29
replace to   = "Rail transport"                     in 29
replace value_edge = tra_rail                       in 29
replace layer = 8                                   in 29

replace from = "Industry"                           in 30
replace to   = "Chemicals / Petrochemicals"         in 30
replace value_edge = ind_cpc                        in 30
replace layer = 8                                   in 30

replace from = "Industry"                           in 31
replace to   = "Iron and steel"                     in 31
replace value_edge = ind_is                         in 31
replace layer = 8                                   in 31

replace from = "Industry"                           in 32
replace to   = "Non-metallic minerals"              in 32
replace value_edge = ind_nmm                        in 32
replace layer = 8                                   in 32

replace from = "Industry"                           in 33
replace to   = "Wood and wood products"             in 33
replace value_edge = ind_wp                         in 33
replace layer = 8                                   in 33

*------------------------------------------------------*
* Finalize edge list
*------------------------------------------------------*
keep from to value_edge layer
rename value_edge value
drop if missing(value) | value <= 0

order from to value layer
sort layer from to
list, clean noobs

*list, clean noobs


sankey value, f(from) t(to) by(layer) format(%15.0fc) smooth(8) ///
	laba(0) wrap(30) xsize(5) ysize(2) noval showtotal labsize(1.6)	///
	plotregion(margin(l+16 r+16 b+5)) boxw(4)

graph export energy_bal_sankey.png, replace wid(3000)
