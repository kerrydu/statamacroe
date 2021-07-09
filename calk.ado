cap program drop calk
program define calk, sortpreserve
	version 14
	syntax varname(numeric), gen(string) t(varname) [first(numlist integer max=1 >=5) Delta(numlist max=1 >=0 <1)  deltavar(varname) Ko(varname) id(varname) ]
	if `"`id'"'!=""{
 		qui tab `id', nofreq
		local nid=r(r)
		local N=_N 
		if mod(`N',`nid')!=0{
			noi display as error "{bf:calk} needs strongly balanced panel, use {bf:tsfill, full} to rectangularize your data."
			exit            
		}       
    }
    else{
        tempvar id
        qui gen `id'=1
    }

    if "`delta'"=="" local delta `deltavar'
	if `"`ko'"'==""{
        if "`first'"==""{
            di as red "# of years in the begining should be specified."
        }
        tempvar  g0
        qui bys `id' (`t'): gen `g0'= (`varlist'[`first']/`varlist'[1])^(1/(`first'-1))-1
        qui bys `id' (`t'): gen `gen'= `varlist'[1]/(`g0'+`delta')
    }
    else{
        qui gen `gen'=`ko'
    }

    qui bys `id' (`t'): replace `gen'=(1-`delta')* `gen'[_n-1]+ `varlist' if _n>1

end