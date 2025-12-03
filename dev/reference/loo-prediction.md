# Generic functions for LOO predictions

See the methods in the rstanarm package for examples.

## Usage

``` r
loo_linpred(object, ...)

loo_epred(object, ...)

loo_predict(object, ...)

loo_predictive_interval(object, ...)

loo_pit(object, ...)

# Default S3 method
loo_pit(object, y, lw, ...)
```

## Arguments

- object:

  The object to use.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

- y:

  For the default method of `loo_pit()`, a vector of `y` values the same
  length as the number of columns in the matrix used as `object`.

- lw:

  For the default method of `loo_pit()`, a matrix of log-weights of the
  same length as the number of columns in the matrix used as `object`.

## Value

`loo_predict()`, `loo_epred()`, `loo_linpred()`, and `loo_pit()`
(probability integral transform) methods should return a vector with
length equal to the number of observations in the data. For discrete
observations, probability integral transform is randomised to ensure
theoretical uniformity. Fix random seed for reproducible results with
discrete data. For more details, see Czado et al. (2009).
`loo_predictive_interval()` methods should return a two-column matrix
formatted in the same way as for
[`predictive_interval()`](https://mc-stan.org/rstantools/dev/reference/predictive_interval.md).

## References

Czado, C., Gneiting, T., and Held, L. (2009). Predictive Model
Assessment for Count Data. *Biometrics*. 65(4), 1254-1261.
[doi:10.1111/j.1541-0420.2009.01191.x](https://doi.org/10.1111/j.1541-0420.2009.01191.x)
.

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
