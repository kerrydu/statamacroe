*! version 1.0 2022-3-4
* randomly match idvars with treatvars
cap program drop rndmatch
program define rndmatch

version 14

gettoken idvars 0:0, p("=,")
if `"`idvars'"'==""|`"`idvars'"'==","| `"`idvars'"'=="="{
	di as error "No idvars specified."
	exit 198
}

gettoken eq 0:0
if `"`eq'"'!="="{
	di as error `"Invalid input followed by {`idvars'}"'
	exit 198
}
syntax varlist[numeric], Prefix(string) tvar(varname) [Gtools]

if "`gtools'"!=""{
	cap which gtools
	if _rc==0 local g g
	else{
		di as error "gtools package is not installed."
		exit 198
	}
}

foreach v in `varlist'{
	qui gen `prefix'`v' = `v'
	label var `prefix'`v' `"randomly match `v'"'
	local pvars `pvars' `prefix'`v'
}
tempvar id 
qui `g'egen `id' =group(`divars')

mata: _randpolicy(`"`id' `tvar' `pvars'"')

end

cap mata mata drop _randpolicy()
cap mata mata drop mergem1()
cap mata mata drop fillpanel()
cap mata mata drop randomcluster()

mata:
void function _randpolicy(string scalar data)
{
	st_view(idtx0=.,.,data)
	nid = length(uniqrows(idtx0[.,1]))
	nt  = length(uniqrows(idtx0[.,2]))
	if (rows(idtx0)!=(nt*nid)){
		idtxx = fillpanel(idtx0)	
	}
	else{
		idtxx = idtx0
	}
	
	pos=randomcluster(nid, nt)
	idtxx = idtxx[.,1..2],idtxx[pos,3..cols(idtxx)]
	//rows(idtx0)
	idtx0[.,.] = mergem1(idtx0,(1,2),idtxx)
	

}


real matrix function mergem1(real matrix data,real rowvector s1,real matrix x2)
{
	x1=data[.,s1]
	c = cols(x2)-cols(x1)
	xx=(x1,J(rows(x1),c,.),J(rows(x1),1,0)) \ (x2,J(rows(x2),1,1))
	//rows(select(xx,xx[.,cols(xx)]:==0))
	_sort(xx,(1..3))
	id1=xx[.,1..length(s1)]
	id2 = id1[rows(id1),.] \ id1[1::(rows(id1)-1),.]
	pos1=mm_which(rowsum(id1:==id2):!=cols(id1))
	// 最大的组数
	n=max(pos1[2::length(pos1)]-pos1[1::(length(pos1)-1)])
	pos = mm_which(rowsum(id1:==id2):==cols(id1))
	//id1,id2
	//pos
	for(k=1;k<=(n-1);k++){
		xx[pos,3..(cols(xx)-1)]=xx[pos:-1,3..(cols(xx)-1)]	
		//colmissing(xx[.,3])
	}
	xx=select(xx,xx[.,cols(xx)]:==0)
	//rows(select(xx,xx[.,cols(xx)]:==0))
	xx =xx[.,1..(cols(xx)-1)]
	return(xx)	
}


real matrix function fillpanel(real matrix data0)
{
	id= uniqrows(data0[.,1])
	t = uniqrows(data0[.,2])	
	c = cols(data0)
	balancedata= (id#J(length(t),1,1),J(length(id),1,1)#t,J(length(id)*length(t),c-2,.)),J(length(id)*length(t),1,1)	
    balancedata = (data0,J(rows(data0),1,0)) \balancedata
	c=c+1
	_sort(balancedata,(1,2,c))
	x1=balancedata[,1..2] 
	// use the first obs in id-t group
	x2=x1[rows(x1),.] \ x1[1::(rows(x1)-1),.]
	//balancedata,x2
	fdata=select(balancedata,rowsum(x1:==x2):!=cols(x1))
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
