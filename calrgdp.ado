cap program drop calrgdp
program define calrgdp, sortpreserve
	version 14
	syntax, gdp(varname numeric) gdpindex(varname numeric) gen(string) t(varname) [id(varname) base(numlist max=1) Accumulate]
	tempvar gdpindex2 baseindex
    qui gen double  `gdpindex2'=`gdpindex'	

	if "`id'"==""{
		sort `t'
		if "`base'"=="" local base = `t'[1]
		if `"`accumulate'"'==""{
			qui replace `gdpindex2'=100 if _n==1
			qui replace `gdpindex2'=`gdpindex2'[_n-1]*`gdpindex'/100 if _n>1
		}
		su `gdpindex2' if `t'==`base',meanonly
		qui gen `baseindex' = r(mean)
		qui replace `gdpindex2'=`gdpindex2'/`baseindex'
		qui gen double `gen'=`gdp'[1]*`gdpindex2'			
	}
	else{
	
		qui tab `id', nofreq
		local nid=r(r)
		local N=_N 
		if mod(`N',`nid')!=0{
			noi display as error "{bf:calrgdp} needs strongly balanced panel, use {bf:tsfill, full} to rectangularize your data."
			exit            
		}		
		sort `t'
		if "`base'"=="" local base = `t'[1]
		if `"`accumulate'"'==""{
			qui bys `id' (`t'): replace `gdpindex2'=100 if _n==1
			qui bys `id' (`t'): replace `gdpindex2'=`gdpindex2'[_n-1]*`gdpindex'/100 if _n>1
		}
		tempvar baseindex2
		qui bys `id' (`t'): egen `baseindex2' = mean(`gdpindex2') if `t'==`base'
		qui bys `id' (`t'): egen `baseindex' = total(`baseindex2') 
		qui bys `id' (`t'): replace `gdpindex2'=`gdpindex2'/`baseindex'
		qui bys `id' (`t'): gen double `gen'=`gdp'[1]*`gdpindex2'			
		
	}
	

end


