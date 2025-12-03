# Generic function for predictive intervals

See
[predictive_interval.stanreg()](https://mc-stan.org/rstanarm/reference/predictive_interval.stanreg.html)
in the rstanarm package for an example.

## Usage

``` r
predictive_interval(object, ...)

# Default S3 method
predictive_interval(object, prob = 0.9, ...)
```

## Arguments

- object:

  The object to use.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

- prob:

  A number \\p \in (0,1)\\ indicating the desired probability mass to
  include in the intervals.

## Value

`predictive_interval()` methods should return a matrix with two columns
and as many rows as data points being predicted. For a given value of
`prob`, \\p\\, the columns correspond to the lower and upper \\100p\\\\
\\100(1 - \alpha/2)\\\\ `prob=0.9` is specified (a \\90\\\\ would be
`"5%"` and `"95%"`, respectively.

The default method just takes `object` to be a matrix and computes
quantiles, with `prob` defaulting to `0.9`.

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
# Default method takes a numeric matrix (of draws from posterior
# predictive distribution)
ytilde <- matrix(rnorm(100 * 5, sd = 2), 100, 5) # fake draws
predictive_interval(ytilde, prob = 0.8)
#>            10%      90%
#> [1,] -3.317022 2.292091
#> [2,] -2.707817 2.573733
#> [3,] -2.627796 1.853548
#> [4,] -2.018837 2.446523
#> [5,] -2.267105 2.457976

# Also see help("predictive_interval", package = "rstanarm")
```
