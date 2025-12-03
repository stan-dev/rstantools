# Generic function for accessing the posterior distribution of the conditional expectation

Extract the posterior draws of the conditional expectation. See the
rstanarm package for an example.

## Usage

``` r
posterior_epred(object, ...)
```

## Arguments

- object:

  The object to use.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

## Value

`posterior_epred()` methods should return a \\D\\ by \\N\\ matrix, where
\\D\\ is the number of draws from the posterior distribution
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
