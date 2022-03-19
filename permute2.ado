cap program drop permute2
program define permute2
	version 16 
	_on_colon_parse `0'
	local command `"`s(after)'"'
	local 0 `"`s(before)'"'
	_parse_policy `0'
	local cluster `"`r(cluster)'"'
	local tvar `"`r(tvar)'"'
	local treatment `"`r(treatment)'"'
	local cmd `"`r(cmd)'"'

	if `"`tvar'"'==""{
		tempvar tvar
		qui gen byte `tvar'=1
	}
	tempvar id 
	qui frame pwf
	local current = r(currentframe)

	cap which gtools
	if _rc==0 local g g

	qui `g'egen `id' = group( `cluster')
	qui `g'sort `id' `tvar'
	tempname temp_frame_placebo
	qui bys `id' `tvar' (`treatment'): frame put `id' `tvar' `treatment' if _n==1, ///
	                                                    into(`temp_frame_placebo')
	frame `temp_frame_placebo'{
		//qui `g'duplicates drop `id' `tvar', force
		qui xtset `id' `tvar'
		qui count  if `id'==`id'[1]
		local Ntvar = r(N)
		if mod(_N,`Ntvar') qui tsfill, full
		qui count if `tvar' == `tvar'[1]
		global nid = r(N)
		mata: placebotreat=st_data(.,"`treatment'")
	} 

	qui frame change `current'
	qui frlink m:1 `id' `tvar', frame(`temp_frame_placebo')  
	mata: temp_frame_placebo =st_data(.,"`temp_frame_placebo'") 
	cap frame drop `temp_frame_placebo'
	global trvars `treatment'
	simulate `cmd': permutefor `command'
	cap mata mata drop placebotreat 
	cap mata mata drop temp_frame_placebo

end


cap program drop  _parse_policy	
program define _parse_policy,rclass
	syntax [anything(name=exp_list equalok)]	///
		[fw iw pw aw] [if] [in], TReatment(varlist) Cluster(varlist) [TVar(varname) *]
	tokenize `"`0'"', p(",")
	local cmd `1', `options'
	return local treatment `treatment'
	return local cluster `cluster'
	return local tvar  `tvar'
	return local cmd `cmd'
end






	