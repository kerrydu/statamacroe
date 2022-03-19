cap program drop permutec
program define permutec
	version 14 
	_on_colon_parse `0'
	local command `"`s(after)'"'
	local 0 `"`s(before)'"'
	_parse_policy `0'
	local cluster `"`r(cluster)'"'
	local tvar `"`r(tvar)'"'
	local treatment `"`r(treatment)'"'
	local cmd `"`r(cmd)'"'
	cap which gtools
	if _rc==0 local g g
	tempvar id time posin flag
	if `"`tvar'"'==""{
		*tempvar time
		qui gen byte `time'=1
	}
	else{
		*tempvar time
		qui `g'egen `time'=group(`tvar')
	}
	*tempvar id 
	if `"`cluster'"'==""{
		qui gen `id'=_n
	}
	else{
		qui `g'egen `id' = group( `cluster')
	}
	qui `g'egen `posin' =group(`id' `time')
	qui `g'sort `posin'
	qui putmata _posin00 =`posin',replace
	qui bys `posin' : gen byte `flag' = (_n==1)
	qui putmata _data00=(`id' `time' `treatment' 1) if `flag',replace
	mata: _nn00=max(_data00[.,1])
	mata: _tt00=max(_data00[.,2])
	mata: _balancedata00 = fillpanel(_data00)
	global randomvars `treatment'
	simulate `cmd': permutecin `command'
	//cap mata drop _nn00 _tt00 data00 balancedata00
end


cap program drop  _parse_policy	
program define _parse_policy,rclass
	syntax [anything(name=exp_list equalok)]	///
		[fw iw pw aw] [if] [in], TReatment(varlist) [Cluster(varlist) TVar(varname) *]
	tokenize `"`0'"', p(",")
	local cmd `1', `options'
	return local treatment `treatment'
	return local cluster `cluster'
	return local tvar  `tvar'
	return local cmd `cmd'
end


mata:

real matrix function fillpanel(real matrix data0)
{
	id= uniqrows(data0[.,1])
	t = uniqrows(data0[.,2])
	if(rows(data0[.,1])==length(id)*length(t)){
		return(data0)
		exit()
	}	
	c = cols(data0)
	balancedata= (id#J(length(t),1,1),J(length(id),1,1)#t,J(length(id)*length(t),c-2,.)),J(length(id)*length(t),1,1)	
    balancedata = (data0,J(rows(data0),1,0)) \balancedata //加入最后一列 0 /1 排序用
	c=c+1
	_sort(balancedata,(1,2,c))
	x1=balancedata[,1..2] 
	// use the first obs in id-t group
	x2=x1[rows(x1),.] \ x1[1::(rows(x1)-1),.]
	//balancedata,x2
	fdata=select(balancedata,rowsum(x1:==x2):!=cols(x1)) //不相等就是面板的第一行
	data1=fdata[.,1..(c-1)]
	return(data1)	
	
}
end



	