{smcl}
{* 04July2021}{...}
{hline}
help for {hi:segmindex}
{hline}

{title:Calculate market segmentation index}

{marker syntax}{...}
{title:Syntax}

{p 4 10 2}
{cmd:segmindex } {it:varlist} [,{it:options}]


{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}


{synopt :{opt gen(newvar)}}specify a new varname to store the market segmentation index.{p_end}
{synopt :{opt w:mat(matname)}}specify the name of the adjacent matrix in mata.{p_end}
{synopt :{opt idm:at(vecname)}}specify the name of the ID vector corresponding to the adjacent matrix in mata.{p_end}
{synopt :{opt id(varname)}}specify the individual variable{p_end}
{synopt :{opt t(varname)}}specify the time variable.{p_end}

{synoptline}
 

{marker examples}{...}
{title:Examples}

{phang}
generate the adjacent matrix and ID vector:

{p 12 16 2}
{cmd:.use province.dta, clear}{break}

{p 12 16 2}
{cmd:.spmatrix create contiguity M, normalize(none) rook}{break}

{p 12 16 2}
{cmd:.spmatrix matafromsp W id = M}{break}


{phang}
calculate the market segmentation index :

{p 12 16 2}
{cmd:.use example.dta, clear}{break}

{p 12 16 2}
{cmd:.segmindex index*, id(_ID) t(year) idm(id) w(W) gen(segindex) }{break}


{title:Description}

{pstd}
{opt segmindex} use the price indices of several commodities and the geographical proximity information 
to calculate the market segmentation index.



{marker references}{...}
{title:References}

{phang}
陈敏, 桂琦寒, 陆铭, 陈钊. 中国经济增长如何持续发挥规模效应?——经济开放与国内商品市场分割的实证研究[J]. 经济学(季刊), 2007, 7(1): 125-150.




{hline}


{title:Authors}
{phang}
{cmd:Kerry Du}, School of Management, Xiamen University, China.{break}
 E-mail: {browse "mailto:kerrydu@xmu.edu.cn":kerrydu@xmu.edu.cn}. {break}


