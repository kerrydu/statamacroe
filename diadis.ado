* version 0.1
* by Kerry Du, kerrydu@xmu.edu.cn
* calculate Language distance
* syntax: diadis cityid county_population  dia_super_group dia_group dia_sub_group filename_to_save_results
cap program drop diadis
program define diadis
version 14
* arguments specified as follows:
* a: cityid
* b: county population
* c: dia_super_group
* d: dia_group
* e: dia_sub_group
* filename to save the results

args a b c d e filename

confirm numeric var `b'

preserve

qui drop if missing(`c') | missing(`d') | missing(`e')
tempvar a1 b1 c1 d1 e1 tot
qui egen `a1' = group(`a')
qui egen `c1' = group(`c') 
qui egen `d1' = group(`d') 
qui egen `e1' = group(`e') 

qui bys `a': egen `tot' = total(`b')
qui gen `b1' = `b'/`tot'

tempname res

mata: `res' = diadismain("`a1' `b1' `c1' `d1' `e1'")


qui keep `a' `a1'
qui duplicates drop `a', force

tempname idfile

qui save `c(pwd)'/`idfile'.dta

qui drop `a' `a1'

qui getmata (`a1' j dis) = `res'

qui mata mata drop `res'

qui merge m:1 `a1' using `idfile',  nogenerate keep(match)
rename `a' `a'_i
qui drop `a1'
rename j `a1'
qui merge m:1 `a1' using `idfile',  nogenerate keep(match)
rename `a' `a'_j
qui drop `a1'
order `a'_i `a'_j
save  `filename'

restore
cap erase `c(pwd)'/`idfile'.dta
use `filename',clear

end


cap mata mata drop diadismain()
cap mata mata drop diadis()
mata:

real matrix function diadismain(string scalar vars)
{
	data=st_data(.,vars)
	id=uniqrows(data[.,1])
	//c = J(length(id)*(length(id)+1)/2-length(id),3,.)
	c = length(id)^2
	k=1
	for(i=1;i<=length(id)-1;i++){
	     a=select(data[.,2..5],data[.,1]:==id[i])
		 c[k++,.] =id[i], id[i], diadis(a,a)
		 //k=k+1
	    for(j=i+1;j<=length(id);j++){
			b=select(data[.,2..5],data[.,1]:==id[j])
			d = diadis(a,b)
			c[k++,.] =id[i], id[j], d
			//k=k+1
			c[k++,.] =id[j], id[i], d
			//k=k+1
		}
	}
	
	return(c)
}

end


mata:

real scalar function diadis(real matrix a, real matrix b)
{
    c=0
	for(i=1;i<=rows(a);i++){
	    for(j=1;j<=rows(b);j++){
		    if (a[i,2]!=b[j,2]) d=3
			else if (a[i,3]!=b[j,3]) d=2
			else if (a[i,4]!=b[j,4]) d=1
			else d=0
			c=c+a[i,1]*b[j,1]*d
		}
	}
	return(c)
}

end