# Generic function for extracting information about prior distributions

See
[prior_summary.stanreg()](https://mc-stan.org/rstanarm/reference/prior_summary.stanreg.html)
in the rstanarm package for an example.

## Usage

``` r
prior_summary(object, ...)

# Default S3 method
prior_summary(object, ...)
```

## Arguments

- object:

  The object to use.

- ...:

  Arguments passed to methods. See the methods in the rstanarm package
  for examples.

## Value

`prior_summary()` methods should return an object containing information
about the prior distribution(s) used for the given model. The structure
of this object will depend on the method.

The default method just returns `object$prior.info`, which is `NULL` if
there is no `'prior.info'` element.

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
# See help("prior_summary", package = "rstanarm")
```
