
*! version 1.0, 2022-3-18

cap program drop placebosample

program define placebosample

	version 14

	syntax varlist, [cluster(varlist) tvar(varname) prefix(string)]

	if (`"`cluster'"'=="" & `"`tvar'"'~="") | (`"`cluster'"'!="" & `"`tvar'"'=="") {
		di as error "tvar() & cluster() should be specified simutaneously"
		exit 198
	}
	else if `"`cluster'"'==""{
		tempvar id time
		qui gen byte `id'=_n
		qui gen byte `time'=1
	}
	else{
		tempvar id time
		qui egen `id' = group(`cluetsr')
		qui egen `time'=group(`tvar')
	}

	tempvar flag posin
	qui egen `posin' =group(`id' `time')
	sort `posin'
	qui bys `posin': gen byte `flag'=(_n==1) 
	qui putmata posin =`posin',replace //在mata数据中的位置
	qui putmata  id =`id'  time=`time'  vars = (`varlist') if `flag'==1,replace
	if `"`prefix'"'!=""{
		foreach v in `varlist'{
				qui clone `prefix'`v' = `v'
				local newvars `newvars' `prefix'`v'
		}
	}
	else{
		local newvars `varlist'
	}

	mata: _randommatching(posin, id,time,vars,"`newvars'")
end

cap mata mata drop _randommatching()
cap mata mata drop fillpanel()
cap mata mata drop randomcluster()

mata:

void function _randommatching(real colvector posin,
	                          real colvector id,
	                          real colvector time,
	                          real matrix    vars,
	                          string scalar  vnames)
{
	
	balancedata = fillpanel((id,time,vars,J(length(id),1,1),))
	pick=randomcluster(max(id),max(t))
	pickdata = select(balancedata[pick,3..(cols(balancedata)-1)],balancedata[.,cols(balancedata)]:==1)
	st_view(randvars=.,.,vnames)
	randvars[.,.]=pickdata[posin,.]	//将随机化数据传回stata
}

real matrix function fillpanel(real matrix data0)
{
	id= uniqrows(data0[.,1])
	t = uniqrows(data0[.,2])
	if(rows(data0[.,1])==length(id)*length(t)){
		return(data0)
		exit
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



real matrix function randomcluster(real scalar n,real scalar t)
{
 

 pos = (1::(n*t)),runiform(n,1)#J(t,1,1)

 _sort(pos,2)

 return(pos[.,1])

}


end