# Generic function and default method for posterior uncertainty intervals

These intervals are often referred to as credible intervals, but we use
the term uncertainty intervals to highlight the fact that wider
intervals correspond to greater uncertainty. See
[posterior_interval.stanreg()](https://mc-stan.org/rstanarm/reference/posterior_interval.stanreg.html)
in the rstanarm package for an example.

## Usage

``` r
posterior_interval(object, ...)

# Default S3 method
posterior_interval(object, prob = 0.9, ...)
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

`posterior_interval()` methods should return a matrix with two columns
and as many rows as model parameters (or a subset of parameters
specified by the user). For a given value of `prob`, \\p\\, the columns
correspond to the lower and upper \\100p\\\\ have the names
\\100\alpha/2\\\\ \\\alpha = 1-p\\. For example, if `prob=0.9` is
specified (a \\90\\\\ `"95%"`, respectively.

The default method just takes `object` to be a matrix (one column per
parameter) and computes quantiles, with `prob` defaulting to `0.9`.

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
# Default method takes a numeric matrix (of posterior draws)
draws <- matrix(rnorm(100 * 5), 100, 5) # fake draws
colnames(draws) <- paste0("theta_", 1:5)
posterior_interval(draws)
#>                5%      95%
#> theta_1 -1.865365 1.683664
#> theta_2 -1.517411 1.882336
#> theta_3 -1.568718 1.618074
#> theta_4 -1.397015 1.842534
#> theta_5 -1.774352 1.490540

# Also see help("posterior_interval", package = "rstanarm")
```
