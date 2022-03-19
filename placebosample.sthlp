{smcl}
{* 14July2016}{...}
{hline}
help for {hi:placebosample}
{hline}

{title:Placebo sample}

{cmd:placebosample} genearte the placebo sample by randomly matching the panels with the treatment. 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:placebosample}
        [{it:varlist}]
        {cmd:,} [{opt cluster(varlist)} {opt tvar(varname)}  {opt prefix(string)} ]

{synoptset 21}{...}
{synopt:{it:options}}Description{p_end}
{synoptline}
{synopt:{opt cluster(varlist)}}specify the cluster variables for random sampling{p_end}
{synopt:{opt tvar(varname)}}speicify the time variable.{p_end}
{synopt:{opt prefix(string)}}speicify generating new variables with the prefix; 
          by default, it is not sepecified and the origin variables are replaced{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
 


{marker examples}{...}
{title:Examples}

{pstd}
Perform DID regression:

{phang}
{cmd:. use plexample.dta}
{p_end}

{phang}
{cmd:. placebosample did,  cluster(id) tvar(appyear)}
{p_end}

{hline}


{title:Authors}
{phang}
{cmd:Kerry Du}, School of Management, Xiamen University, China.{break}
 E-mail: {browse "mailto:kerrydu@xmu.edu.cn":kerrydu@xmu.edu.cn}. {break}





