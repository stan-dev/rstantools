# Generic function and default method for predictive errors

Generic function and default method for computing predictive errors
\\y - y^{rep}\\ (in-sample, for observed \\y\\) or \\y - \tilde{y}\\
(out-of-sample, for new or held-out \\y\\). See
[predictive_error.stanreg()](https://mc-stan.org/rstanarm/reference/predictive_error.stanreg.html)
in the rstanarm package for an example.

## Usage

``` r
predictive_error(object, ...)

# Default S3 method
predictive_error(object, y, ...)
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

`predictive_error()` methods should return a \\D\\ by \\N\\ matrix,
where \\D\\ is the number of draws from the posterior predictive
distribution and \\N\\ is the number of data points being predicted per
draw.

The default method just takes `object` to be a matrix and `y` to be a
vector.

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
# default method
y <- rnorm(10)
ypred <- matrix(rnorm(500), 50, 10)
pred_errors <- predictive_error(ypred, y)
dim(pred_errors)
#> [1] 50 10
head(pred_errors)
#>            [,1]        [,2]     [,3]       [,4]       [,5]        [,6]
#> [1,]  0.5273861  0.07515823 1.513581  1.4204596 -3.4765209 -0.40151181
#> [2,] -3.3664225  0.81258188 2.744778 -0.8234573 -1.3396243 -1.43882134
#> [3,] -0.5546069  2.37300064 1.780391 -0.2672072  0.7954730 -0.41251601
#> [4,] -0.2880340 -0.76885376 0.723278 -0.5925147 -0.7830652  1.52582725
#> [5,] -0.5131371  3.30739106 1.233684  0.3282228 -0.8251587  0.01187749
#> [6,]  0.1832783  1.69463620 0.412581  1.1282433 -2.4243409 -0.55389915
#>            [,7]      [,8]      [,9]      [,10]
#> [1,]  0.3291168 0.7518855 1.0182404  2.1367075
#> [2,] -0.9216418 1.3862216 0.6818612  1.1718269
#> [3,] -0.7428718 2.1940964 0.7415774 -1.0785962
#> [4,]  1.6353221 1.0977800 2.3479025  0.9887451
#> [5,] -0.3287231 2.4549490 0.3920619  2.0133653
#> [6,]  0.6492479 0.7439346 0.9827939  2.3187384

# Also see help("predictive_error", package = "rstanarm")
```
