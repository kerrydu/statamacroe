cap program drop rowvar 
program rowvar 
	version 14
	gettoken g 0 : 0, p(" =")
	qui gen double `g'=.
	gettoken eqs 0 : 0, p("=")
    syntax varlist(numeric) [if] [in] 
    marksample touse
    tempname XX YY
    mata: `XX' = st_data(.,"`varlist'","`touse'")
    mata: `XX' = mm_colvar(`XX'')
    mata: st_view(`YY'=.,.,"`g'","`touse'")
    mata: `YY'[.,.]=`XX''
    cap mata mata drop `XX'
    cap mata mata drop `YY'
end