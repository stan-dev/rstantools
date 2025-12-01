# Generic function for drawing from the posterior predictive distribution

Draw from the posterior predictive distribution of the outcome. See
[posterior_predict.stanreg()](https://mc-stan.org/rstanarm/reference/posterior_predict.stanreg.html)
in the rstanarm package for an example.

## Usage

``` r
posterior_predict(object, ...)
```

## Arguments

- object:

  The object to use.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

## Value

`posterior_predict()` methods should return a \\D\\ by \\N\\ matrix,
where \\D\\ is the number of draws from the posterior predictive
distribution and \\N\\ is the number of data points being predicted per
draw.

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
# See help("posterior_predict", package = "rstanarm")
```
