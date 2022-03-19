cap program drop permutecin
program define permutecin
    version 14
	mata: _randommatching(_posin00,_nn00,_tt00,_balancedata00,"${randomvars}")	
	qui `0'
end


cap mata mata drop _randommatching()
cap mata mata drop randomcluster()

mata:


void function _randommatching(real colvector posin,
	                          real scalar n,
	                          real scalar t,
	                          real matrix balancedata,
	                          string scalar  vnames)
{
	pick=randomcluster(n,t)
	pickdata = select(balancedata[pick,3..(cols(balancedata)-1)],balancedata[.,cols(balancedata)]:==1)
	st_view(randvars=.,.,vnames)
	randvars[.,.]=pickdata[posin,.]	//将随机化数据传回stata
}


real matrix function randomcluster(real scalar n,real scalar t)
{
 

 pos = (1::(n*t)),runiform(n,1)#J(t,1,1)

 _sort(pos,2)

 return(pos[.,1])

}


end


/*
void function _randommatching(real colvector posin,
	                          real colvector id,
	                          real colvector time,
	                          real matrix    vars,
	                          string scalar  vnames)
{
	
	balancedata = fillpanel((id,time,vars,J(length(id),1,1),))
	pick=randomcluster(max(id),max(t))
	pickdata = select(balancedata[.,cols(balancedata)],balancedata[pick,3..(cols(balancedata)-1)])
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
*/
