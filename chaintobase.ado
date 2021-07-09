cap program drop chaintobase
program define chaintobase, sortpreserve
	version 14
	syntax varname(numeric),  gen(string) t(varname) [id(varname) base(numlist max=1) ]
	if `"`id'"'!=""{
 		qui tab `id', nofreq
		local nid=r(r)
		local N=_N 
		if mod(`N',`nid')!=0{
			noi display as error "{bf:chaintobase} needs strongly balanced panel, use {bf:tsfill, full} to rectangularize your data."
			exit            
		}       
    }
    else{
        tempvar id
        qui gen `id'=1
    }
	sort `t'
	if "`base'"=="" local base = `t'[1] 
    qui gen `gen'=`varlist'
	qui bys `id' (`t'): replace `gen'=100 if _n==1
	qui bys `id' (`t'): replace `gen'=`gen'[_n-1]*`varlist'/100 if _n>1     
	tempvar baseindex2 baseindex
	qui bys `id' (`t'): egen `baseindex2' = mean(`gen') if `t'==`base'
	qui bys `id' (`t'): egen `baseindex' = total(`baseindex2') 
	qui bys `id' (`t'): replace `gen'=`gen'/`baseindex'
	
end

