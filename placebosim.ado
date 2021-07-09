cap program drop placebosim

program define placebosim
	
	version 14
	 _on_colon_parse `0'

	local command `"`s(after)'"'
	local 0 `"`s(before)'"'

	_parse_policy `0'
	local id `"`r(id)'"'
	local policy `"`r(policy)'"'
	local cmd `"`r(cmd)'"'
	*di `"simulate `cmd' : regcmd `command' id(`id') policy(`policy')"'
	qui tab `id', nofreq
	local nid=r(r)
	local N=_N 
	if mod(`N',`nid')!=0{
		noi display as error "{bf:placeboreg} needs strongly balanced panel, use {bf:tsfill, full} to rectangularize your data."
		exit            
	}	
	
	simulate `cmd' : regcmd `command' id(`id') policy(`policy')

end

	
cap program drop  _parse_policy	
program define _parse_policy,rclass
	syntax [anything(name=exp_list equalok)]	///
		[fw iw pw aw] [if] [in], policy(varlist) id(varname) [*]
	tokenize `"`0'"', p(",")
	local cmd `1', `options'
	return local policy `policy'
	return local id `id'
	return local cmd `cmd'
end

cap program drop regcmd	
program define regcmd,eclass
	version 14
	syntax [anything], policy(varlist) id(varname) [*]
	_parse_policy `0'
	local policy `"`r(policy)'"'
	local id `"`r(id)'"'
	local cmd  `"`r(cmd)'"'
	preserve
	randpolicy, policy(`policy') id(`id')
	qui `cmd'
	restore
end


* version 2.0, 7 Jun 2021
* by Kerry Du
cap program drop randpolicy
program define randpolicy
	version 14
	syntax, id(varname) Policy(varlist numeric) 
	tempvar tt rn 
	qui bys `id': gen `tt'=_n
	tempname PP
	sort `id' `tt'
	qui putmata `PP' = (`policy'),replace
	qui gen double `rn'=uniform() if `tt'==1
	qui bys `id' (`tt'): replace `rn'=`rn'[_n-1] if _n>1
	sort `rn' `tt'
	qui getmata   (`policy')= `PP',replace
	cap mata mata drop `PP' 
end
