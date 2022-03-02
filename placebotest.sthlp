{smcl}
{* 14July2016}{...}
{hline}
help for {hi:placebotest}
{hline}

{title:placebo simulation}

{cmd:placebo} perform the placebo simulation for treatment effects by randomly matching the idividuals with the treatment. 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:placebotest}
        [{it:{help exp_list}}]
        {cmd:,} {opt id(varname)} {opt tvar(varname)} policy(varlist) [{opt seed(#)} {opt r:eps(#)}]
        {cmd::} {it:command}

{synoptset 21}{...}
{synopt:{it:options}}Description{p_end}
{synoptline}
{synopt:{opt id(varname)}}specify the id variable{p_end}
{synopt:{opt tvar(varname)}}specify the time variable{p_end}
{synopt:{opt policy(varlist)}}speicify the treatment variables{p_end}
{synopt:{opt reps(#)}}set replication number to {it:#} {p_end}
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
{cmd:. placebotest b=_b[did], reps(1000) id(id) policy(did) tvar(appyear): xi:xtreg number did i.appyear,fe}
{p_end}

{hline}


{title:Authors}
{phang}
{cmd:Kerry Du}, School of Management, Xiamen University, China.{break}
 E-mail: {browse "mailto:kerrydu@xmu.edu.cn":kerrydu@xmu.edu.cn}. {break}





