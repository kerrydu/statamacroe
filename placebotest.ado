*!version 1.0 5Mar 2022
* by Kerry Du
cap program drop placebotest
program define placebotest
	
	version 14

	 _on_colon_parse `0'

	local command `"`s(after)'"'

	local 0 `"`s(before)'"'

	_parse_policy `0'
	local cluster `"`r(cluster)'"'
	local policy `"`r(policy)'"'
	local cmd `"`r(cmd)'"'
	local tvar `"`r(tvar)'"'
	local seed = r(seed)
	local reps = r(reps)
	if("`seed'"!="") mata: rseed(`seed')
	*di `"simulate `cmd' : regcmd `command' id(`id') policy(`policy')"'
	expandbname `cmd'
	local k=1
	local b`k' `r(b`k')'
	while(`"`b`k''"'!=""){
		confirm name `b`k''
		local exp`k' `r(exp`k')'
		local bname `bname' `b`k''
		local k=`k'+1
		local b`k' `r(b`k')'		
	}
	tempvar id
	qui egen `id' =group(`cluster')	
	sort `id' `tvar'
	tempname XX PP ball ball2
	qui putmata `XX' = (`policy'),replace
	mata: st_view(`PP'=.,.,"`policy'")
	forv j=1/`reps'{
		displaydot, dot(`j')
		mata:_randpolicy(`"`id' `tvar' `policy'"')
		//su `policy'
		qui `command'
		local k=1
		while(`"`exp`k''"'!=""){
			mat `ball' = nullmat(`ball'), `exp`k''
			local k=`k'+1
		} 
		mat `ball2' = nullmat(`ball2') \ `ball' 
		cap matrix drop `ball'
		mata: `PP'[.,.] = `XX'
	}
	
	clear
	qui svmat `ball2', names( `bname')
	local k=1
	foreach v of varlist * {
		gettoken v0 bname:bname
		label var `v' `"`exp`k''"'
		rename `v' `v0'
		local k=`k'+1
	}
	
	cap mata mata drop `PP'
	cap mata mata drop `XX'
	cap matrix drop `ball2'

end

	
cap program drop  _parse_policy	
program define _parse_policy,rclass
	syntax [anything(name=exp_list equalok)]	///
		[fw iw pw aw] [if] [in], policy(varlist) ///
		cluster(varlist) tvar(varname) ///
		[seed(numlist max=1) reps(integer 200)]
	tokenize `"`0'"', p(",")
	local cmd `1'
	return local policy `policy'
	return local cluster `cluster'
	return local tvar `tvar'
	return local cmd `cmd'
	return local seed `seed'
	*if "`reps'"=="" local reps 200
	return local reps `reps'
end

cap program drop expandbname
program define expandbname, rclass
	version 14
	gettoken x 0:0, parse("]") 
	//di "`x'"
	local k=1
	while(`"`x'"'!=""){
		if `"`x'"'!="]"{
		   local exp`k' `x'
		}
		else{
			local exp`k' `exp`k'']
			//di "`exp`k''"
			gettoken bname exp`k':exp`k',parse("=")
			return local b`k' `bname'
			gettoken bname exp`k':exp`k',parse("=")
			return local exp`k' `"`exp`k''"'
			local k=`k'+1
		}
		gettoken x 0:0, parse("]") 
		
	}

end

 cap program drop displaydot
 program define displaydot
 version 14
 syntax, dot(integer)
 if mod(`dot',50) == 0 {
	di _c `dot'
	di 
 }
 else{
	disp _c "."
 }
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
	if(n>rows(x2)){ //reduce # of loop
		return(mergem12(x1,x2))
		exit()
	}
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


real matrix function mergem12(real matrix x1, real matrix x2)
{
	
	c = cols(x2)-cols(x1)
	r = rows(x1)
	rx2=rows(x2)
    mdata= J(rows(x1),c,.)
    udata= x2[.,(cols(x1)+1)..cols(x2)]
    for(i=1;i<=rows(x2);i++){
    	flag= mm_which(rowsum(x1:==J(r,1,x2[i,1..cols(x1)])):==cols(x1))
    	if(length(flag)){
    	  mdata[flag,.]=J(length(flag),1,udata[i,.])
    	}  	
    }
    xxx=(x1,mdata)
	return(xxx)	
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

