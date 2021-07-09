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

