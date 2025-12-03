# Generic function for pointwise log-likelihood

We define a new function `log_lik()` rather than a
[`stats::logLik()`](https://rdrr.io/r/stats/logLik.html) method because
(in addition to the conceptual difference) the documentation for
[`logLik()`](https://rdrr.io/r/stats/logLik.html) states that the return
value will be a single number, whereas `log_lik()` returns a matrix. See
the
[log_lik.stanreg()](https://mc-stan.org/rstanarm/reference/log_lik.stanreg.html)
method in the rstanarm package for an example of defining a method.

## Usage

``` r
log_lik(object, ...)
```

## Arguments

- object:

  The object to use.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

## Value

`log_lik()` methods should return a \\S\\ by \\N\\ matrix, where \\S\\
is the size of the posterior sample (the number of draws from the
posterior distribution) and \\N\\ is the number of data points.

## See also

- The rstanarm package
  ([mc-stan.org/rstanarm](https://mc-stan.org/rstanarm/)) for example
  methods ([CRAN](https://CRAN.R-project.org/package=rstanarm),
  [GitHub](https://github.com/stan-dev/rstanarm)).

&nbsp;

- Guidelines and recommendations for developers of R packages
  interfacing with Stan and a demonstration getting a simple package
  working can be found in the vignettes included with rstantools and at
  [mc-stan.org/rstantools/articles](https://mc-stan.org/rstantools/articles/).

## Examples

``` r
# See help("log_lik", package = "rstanarm")
```
