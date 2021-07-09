{smcl}
{* 14July2016}{...}
{hline}
help for {hi:calk}
{hline}

{title:Calculate capital stock using the PIM method}

{marker syntax}{...}
{title:Syntax}

{p 4 10 2}
{cmd:calk }{it:varname}
[,{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt gen(newvar)}}specify a new varname to store the capital stock. It is required{p_end}
{synopt :{opt t(varname)}}specify the time variable. It is required{p_end}
{synopt :{opt first(#)}}specify the first # periods of the investment to calculate the initial capital stock{p_end}
{synopt :{opt ko(varname)}}specify the variable of the initial capital stock{p_end}
{synopt :{opt delta(#)}}specify the discount rate for all periods and individuals{p_end}
{synopt :{opt deltavar(varname)}}specify the variable of the discount rate{p_end}
{synopt :{opt id(varname)}}specify the individual variable{p_end}

{synoptline}
 

{marker examples}{...}
{title:Examples}

{phang}
converted the investment into the constant price level:

{p 12 16 2}
{cmd:.use example.dta}{break}

{p 12 16 2}
{cmd:.chaintobase price, t(year) id(province) base(2000) gen(price2)}

{p 12 16 2}
{cmd:.replce inv=inv/price2}

{phang}
calculate the capital stock:

{p 12 16 2}
{cmd:.calk inv, gen(K) first(5) delta(0.1) t(year) id(province) }{break}




{hline}


{title:Authors}
{phang}
{cmd:Kerry Du}, School of Management, Xiamen University, China.{break}
 E-mail: {browse "mailto:kerrydu@xmu.edu.cn":kerrydu@xmu.edu.cn}. {break}


