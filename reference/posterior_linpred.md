# Generic function for accessing the posterior distribution of the linear predictor

Extract the posterior draws of the linear predictor, possibly
transformed by the inverse-link function. See
[posterior_linpred.stanreg()](https://mc-stan.org/rstanarm/reference/posterior_linpred.stanreg.html)
in the rstanarm package for an example.

## Usage

``` r
posterior_linpred(object, transform = FALSE, ...)
```

## Arguments

- object:

  The object to use.

- transform:

  Should the linear predictor be transformed using the inverse-link
  function? The default is `FALSE`, in which case the untransformed
  linear predictor is returned.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

## Value

`posterior_linpred()` methods should return a \\D\\ by \\N\\ matrix,
where \\D\\ is the number of draws from the posterior distribution
distribution and \\N\\ is the number of data points.

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
# See help("posterior_linpred", package = "rstanarm")
```
