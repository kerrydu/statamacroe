{smcl}
{* 14July2016}{...}
{hline}
help for {hi:calrgdp}
{hline}

{title:Calculate real GDP}

{marker syntax}{...}
{title:Syntax}

{p 4 10 2}
{cmd:calrgdp }, {it:gdp(varname)} {it:gdpindex(varname)} {it:t(varname)} {it:gen(newvar)} [{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt gdp(varname)}}specify the nominal GDP variable{p_end}
{synopt :{opt gdpindex(varname)}}specify the GDP index variable{p_end}
{synopt :{opt t(varname)}}specify the time variable{p_end}
{synopt :{opt gen(newvar)}}specify a new varname to store the real GDP{p_end}
{synopt :{opt id(varname)}}specify the individual variable; it is required for panel data{p_end}
{synopt :{opt base(#)}}specify the base year for the price{p_end}
{synopt :{opt accumulate}}specify the GDP index is accumulated{p_end}

{synoptline}
 

{marker examples}{...}
{title:Examples}

{phang}

{p 12 16 2}
{cmd:.use example.dta}{break}

{p 12 16 2}
{cmd:.calrgdp, gdp(gdp) gdpindex(gdpindex) t(year) id(province) base(2005) gen(rgdp)}{break}


{hline}


{title:Authors}
{phang}
{cmd:Kerry Du}, School of Management, Xiamen University, China.{break}
 E-mail: {browse "mailto:kerrydu@xmu.edu.cn":kerrydu@xmu.edu.cn}. {break}


