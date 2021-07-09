cap program drop segmindex
program define segmindex
version 14
syntax varlist(numeric min=2), gen(string) Wmat(string) IDMat(string) id(varname) t(varname)
confirm name `wmat'
confirm name `idmat'
confirm new var `gen'
preserve
qui keep `id' `t' `varlist'
foreach v in `varlist'{
	rename `v' `v'_j
}
rename `id' `id'_j
tempfile _pij0
qui save `_pij0'
restore

preserve
tempname pairij
mata: `pairij' = findpair(`idmat',`wmat')
*mata: `pairij'
clear
tempfile _pijdta
getmata (`id' `id'_j) = `pairij'
qui save `_pijdta'
restore


qui joinby `id' using `_pijdta'
qui merge m:1 `id'_j `t' using `_pij0', nogenerate

foreach v in `varlist'{
	tempvar ln`v' dln`v'
	qui gen double `ln`v''=abs(ln(`v')-ln(`v'_j))
    qui bys `t': egen double `dln`v''=mean(`ln`v'')
	qui replace `dln`v''=`ln`v''-`dln`v''
	local ddq `ddq' `dln`v''
}


tempvar varq

qui  egen double `varq' = rowsd(`ddq')

qui bys `id' `t': egen double `gen' = mean(`varq'^2)

qui drop `id'_j
qui duplicates drop `id'  `t',force


end

cap mata mata drop findpair()
mata:
real matrix function findpair(real colvector id,real matrix W)
{
	pairij=J(0,2,.)
	for(j=1;j<=rows(W);j++){
		i=select(id,W[.,j]:!=0)
		pairij= pairij \ (J(length(i),1,id[j]),i)
		
	}	
	return(pairij)
}

end