# README

The main file, `margins.R`, shows how to compute Stata-like margins in
R by hand in the context of logistic regression. It's mostly just to
show the intuition underlying Stata's `-margins-` command, but you
can use the results to make nice margins figures with ggplot. Output
from R can be checked in Stata with `margins_check.do` and
`fake_data.csv` can be recreated with `make_fake_data.R`.

For a more complete suite of ready-to-go commands, there's the
[`margins`](https://cran.r-project.org/web/packages/margins/vignettes/Introduction.html)
R package.
