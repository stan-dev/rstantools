# Generic function and default method for Bayesian R-squared

Generic function and default method for Bayesian version of R-squared
for regression models. A generic for LOO-adjusted R-squared is also
provided. See the
[bayes_R2.stanreg()](https://mc-stan.org/rstanarm/reference/bayes_R2.stanreg.html)
method in the rstanarm package for an example of defining a method.

## Usage

``` r
bayes_R2(object, ...)

# Default S3 method
bayes_R2(object, y, ...)

loo_R2(object, ...)
```

## Arguments

- object:

  The object to use.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

- y:

  For the default method, a vector of `y` values the same length as the
  number of columns in the matrix used as `object`.

## Value

`bayes_R2()` and `loo_R2()` methods should return a vector of length
equal to the posterior sample size.

The default `bayes_R2()` method just takes `object` to be a matrix of
y-hat values (one column per observation, one row per posterior draw)
and `y` to be a vector with length equal to `ncol(object)`.

## References

Andrew Gelman, Ben Goodrich, Jonah Gabry, and Aki Vehtari (2019).
R-squared for Bayesian regression models. *The American Statistician*,
73(3):307-309. DOI: 10.1080/00031305.2018.1549100.
([Preprint](https://sites.stat.columbia.edu/gelman/research/published/bayes_R2_v3.pdf),
[Notebook](https://avehtari.github.io/bayes_R2/bayes_R2.html))

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
