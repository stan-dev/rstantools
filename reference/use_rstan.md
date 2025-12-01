# Add Stan infrastructure to an existing package

Add Stan infrastructure to an existing R package. To create a *new*
package containing Stan programs use
[`rstan_create_package()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
instead.

## Usage

``` r
use_rstan(pkgdir = ".", license = TRUE, auto_config = TRUE)
```

## Arguments

- pkgdir:

  Path to package root folder.

- license:

  Logical or character; whether or not to paste the contents of a
  `license.stan` file at the top of all Stan code, or path to such a
  file. If `TRUE` (the default) adds the `GPL (>= 3)` license (see
  **Details**).

- auto_config:

  Whether to automatically configure Stan functionality whenever the
  package gets installed (see **Details**). Defaults to `TRUE`.

## Value

Invisibly, `TRUE` or `FALSE` indicating whether or not any files or
folders where created or modified.

## Details

Prepares a package to compile and use Stan code by performing the
following steps:

1.  Create `inst/stan` folder where all `.stan` files defining Stan
    models should be stored.

2.  Create `inst/stan/include` where optional `license.stan` file is
    stored.

3.  Create `inst/include/stan_meta_header.hpp` to include optional
    header files used by Stan code.

4.  Create `src` folder (if it doesn't exist) to contain the Stan C++
    code.

5.  Create `R` folder (if it doesn't exist) to contain wrapper code to
    expose Stan C++ classes to R.

6.  Update `DESCRIPTION` file to contain all needed dependencies to
    compile Stan C++ code.

7.  If `NAMESPACE` file is generic (i.e., created by
    [`rstan_create_package()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)),
    append `import(Rcpp, methods)`, `importFrom(rstan, sampling)`,
    `importFrom(rstantools, rstan_config)`,
    `importFrom(RcppParallel, RcppParallelLibs)`, and `useDynLib`
    directives. If `NAMESPACE` is not generic, display message telling
    user what to add to `NAMESPACE` for themselves.

When `auto_config = TRUE`, a `configure[.win]` file is added to the
package, calling
[`rstan_config()`](https://mc-stan.org/rstantools/reference/rstan_config.md)
whenever the package is installed. Consequently, the package must list
rstantools in the `DESCRIPTION` Imports field for this mechanism to
work. Setting `auto_config = FALSE` removes the package's dependency on
rstantools, but the package then must be manually configured by running
[`rstan_config()`](https://mc-stan.org/rstantools/reference/rstan_config.md)
whenever `stanmodel` files in `inst/stan` are added, removed, or
modified.

## Using the pre-compiled Stan programs in your package

The `stanmodel` objects corresponding to the Stan programs included with
your package are stored in a list called `stanmodels`. To run one of the
Stan programs from within an R function in your package just pass the
appropriate element of the `stanmodels` list to one of the rstan
functions for model fitting (e.g., `sampling()`). For example, for a
Stan program `"foo.stan"` you would use
`rstan::sampling(stanmodels$foo, ...)`.
