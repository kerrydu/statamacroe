cap program drop calrgdp
program define calrgdp, sortpreserve
	version 14
	syntax, gdp(varname numeric) gdpindex(varname numeric) gen(string) t(varname) [id(varname) base(numlist max=1) Accumulate]
	tempvar gdpindex2 baseindex
    qui gen double  `gdpindex2'=`gdpindex'	

	if "`id'"==""{
		sort `t'
		if "`base'"=="" local base = `t'[1]
        rownum `t', index(`base')
        local n = r(rownum)
        if `"`n'"'==""{
        	di as error "base(`base') is not in t(`t')."
        	exit 198
        }
		if `"`accumulate'"'==""{
			qui replace `gdpindex2'=100 if _n==1
			qui replace `gdpindex2'=`gdpindex2'[_n-1]*`gdpindex'/100 if _n>1
		}
		su `gdpindex2' if `t'==`base',meanonly
		qui gen `baseindex' = r(mean)
		qui replace `gdpindex2'=`gdpindex2'/`baseindex'
		qui gen double `gen'=`gdp'[`n']*`gdpindex2'			
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
		rownum `t', index(`base')
		local ns = r(rownum)
		gettoken n ns:ns
        if `"`n'"'==""{
        	di as error "base(`base') is not in t(`t')."
        	exit 198
        }		
		if `"`accumulate'"'==""{
			qui bys `id' (`t'): replace `gdpindex2'=100 if _n==1
			qui bys `id' (`t'): replace `gdpindex2'=`gdpindex2'[_n-1]*`gdpindex'/100 if _n>1
		}
		tempvar baseindex2
		qui bys `id' (`t'): egen `baseindex2' = mean(`gdpindex2') if `t'==`base'
		qui bys `id' (`t'): egen `baseindex' = total(`baseindex2') 
		qui bys `id' (`t'): replace `gdpindex2'=`gdpindex2'/`baseindex'
		qui bys `id' (`t'): gen double `gen'=`gdp'[`n']*`gdpindex2'			
		
	}
	

end

cap program drop rownum
program define rownum,rclass

	version 14
    syntax varname, index(string) [indexregex Matrix]
	/*	
	cap confirm numeric var `varlist'
	tempvar ss
	if _rc {
	    qui gen `ss'=`varlist'
	}
	else{
	    qui gen `ss'=string(`varlist')
	}
	*/
	tempvar ss
	cap gen `ss'=string(`varlist')
	cap gen `ss'=`varlist'
	tempname rowmat
	mata: _rownum("`ss'","`rowmat'")
	
	if `"`rownum'"'!=""{
	  di "Row {`rownum'} are found."	    
	}
	else{
	  di `"No rows statisfied with index(`index') in `varlist'."'
	}
	return local rownum `rownum'
	if "`matrix'"!=""{
	    cap return mat rowmat =`rowmat'
	}
	

end


cap mata mata drop _rownum()
mata:
void function _rownum(string scalar v,string scalar rowm)
{
  var=st_sdata(.,v)
  //var
  //ustrregexm(var, st_local("index"))
  if (st_local("indexregex") == "indexregex")  rowns= select(1::length(var), ustrregexm(var, st_local("index")))
  else rowns = select(1::length(var), ustrpos(var, st_local("index")))
  //rowns
  st_matrix(rowm,rowns)
  rowns2=invtokens(strofreal(rowns)')
  st_local("rownum",rowns2)

}

end

