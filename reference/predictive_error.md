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
#>            [,1]     [,2]        [,3]       [,4]        [,5]       [,6]
#> [1,]  0.8549854 1.719440  0.82671781  1.9217270 -0.07652582 -1.7529923
#> [2,] -0.9440862 1.394449 -0.63117979  1.3562927  2.68527926 -1.7888098
#> [3,] -0.1194663 1.387542  1.56562319  0.8375692  1.45455909 -2.1067272
#> [4,]  1.2190102 0.149097  0.03872919  0.5782869  1.16435716 -1.9232703
#> [5,] -1.0655021 1.003315  2.12680175 -1.4893817  3.53444931 -1.0762303
#> [6,]  0.6909616 1.526605 -0.46478916  3.1713984  0.25438361  0.5454545
#>             [,7]       [,8]        [,9]      [,10]
#> [1,]  2.61716373 -0.1182496 -0.43213791  0.9761024
#> [2,]  4.39913773  0.6402361 -0.51420673  1.5612902
#> [3,]  3.62497214  0.7590033  0.23356729 -0.2567486
#> [4,]  2.88392569 -0.2301847  0.05829213 -1.3629069
#> [5,]  3.62974401 -1.3950885 -0.44124800 -0.5360150
#> [6,] -0.03747409 -0.8752885  0.43604564  0.8561317

# Also see help("predictive_error", package = "rstanarm")
```
