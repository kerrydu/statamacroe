{smcl}
{* 14July2016}{...}
{hline}
help for {hi:placebosim}
{hline}

{title:placebo simulation}

{cmd:placebosim } perform the placebo simulation for treatment effects by randomly matching the idividuals with the treatment. 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:placebosim}
        [{it:{help exp_list}}]
        {cmd:,} {opt id(varname)} {opt policy(varlist)} {opt r:eps(#)} [{it:options}]
        {cmd::} {it:command}

{synoptset 21}{...}
{synopt:{it:options}}Description{p_end}
{synoptline}
{synopt:{opt id(varname)}}specify the id variables{p_end}
{synopt:{opt policy(varlist)}}speicify the treatment variables{p_end}
{synopt:{opt nodots}}suppress replication dots{p_end}
{synopt :{opt dots(#)}}display dots every {it:#} replications{p_end}
{synopt:{opt noi:sily}}display any output from {it:command}{p_end}
{synopt:{opt tr:ace}}trace {it:command}{p_end}
{synopt:{help prefix_saving_option:{bf:{ul:sa}ving(}{it:filename}{bf:, ...)}}}save
        results to {it:filename}{p_end}
{synopt:{opt nol:egend}}suppress table legend{p_end}
{synopt:{opt v:erbose}}display the full table legend{p_end}
{synopt:{opt seed(#)}}set random-number seed to {it:#}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
 

{marker examples}{...}
{title:Examples}


{marker examples}{...}
{title:Examples}

{pstd}
Perform DID regression:

{phang}
{cmd:. use plexample.dta}
{p_end}

{phang}
{cmd:. xi:xtreg number did i.appyear,fe cluster(id)}
{p_end}

{pstd}
Perform the placebo experiment 1000 times:

{phang}
{cmd:. placebosim b=_b[did], reps(1000) id(id) policy(did): xi:xtreg number did i.appyear,fe}
{p_end}

{hline}


{title:Authors}
{phang}
{cmd:Kerry Du}, School of Management, Xiamen University, China.{break}
 E-mail: {browse "mailto:kerrydu@xmu.edu.cn":kerrydu@xmu.edu.cn}. {break}





