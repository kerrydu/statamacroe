cap program drop permutefor
program define permutefor
    version 16
	mata: _randtreat(placebotreat,${nid},"${trvars}",temp_frame_placebo)	
	qui `0'
end

cap mata mata drop _randtreat()
mata:

void function _randtreat(real matrix tr0,       
	                     real scalar nid,
	                     string scalar trvars,
	                     real colvector flag)
{

	pos = uniform(nid,1)#J(rows(tr0)/nid,1,1)
	porder = pos, tr0
    _sort(porder,1)
    porder=porder[.,2..cols(porder)]
    st_view(corex=.,.,trvars)
    corex[.,.]=porder[flag,.]

}

end
