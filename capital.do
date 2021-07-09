
cd "E:\xmuONE\OneDrive - xmu.edu.cn\Desktop"
import excel using "E:\xmuONE\OneDrive - xmu.edu.cn\Desktop\fix.xlsx",clear

drop in 2/77

sxpose,clear

renvars _var2-_var19 \ gdp2000-gdp2017
drop in 1

reshape long gdp,i(_var1) j(year)

replace _var = subinstr(_var1,":固定资产投资","",.)

rename _var province

destring,replace

compress
save invest


import excel using "E:\xmuONE\OneDrive - xmu.edu.cn\Desktop\invprice.xlsx",clear

gen flag=_n if strpos(A,"01dec2000")
replace flag=flag[_n-1] if missing(flag)


keep if _n>=flag | _n==1
drop flag
sxpose,clear

renvars _var2-_var21\ price2000-price2019
drop in 1

rename _var1 province

replace province=subinstr(province,"固定资产投资价格指数:","",.)
reshape long price, i(province) j(year)
destring, replace

merge 1:1 province year using "E:\xmuONE\OneDrive - xmu.edu.cn\Desktop\invest.dta"

keep if _merge==3
drop _merge


/*
set trace off
chaintobase price, t(year) id(province) base(2000) gen(price2)

rename gdp inv
replace inv=inv/price2

set trace off
calk inv, gen(K) first(5) delta(0.1) t(year) id(province) 
*/



replace price=1 if year==2000

bys province (year): replace price=price*price[_n-1]/100 if _n>1

rename gdp inv
replace inv = inv/price

local delta=0.1

bys province (year): gen g=(inv[5]/inv[1])^(1/4)-1

cap drop K
local delta=0.1
*bys province (year): gen K=inv[1]/(1-`delta'-g)

bys province (year): gen K=inv[1]/(`delta'+g)

bys province (year): replace K=K[_n-1]*(1-`delta')+inv if _n>1


