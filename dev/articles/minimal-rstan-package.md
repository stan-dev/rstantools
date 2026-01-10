# Step by step guide for creating a package that depends on RStan

## Introduction

In this vignette we will walk through the steps necessary for creating
an R package that depends on Stan by creating a package with one
function that fits a simple linear regression. Before continuing, we
recommend that you first read the other vignette [*Guidelines for
Developers of R Packages Interfacing with
Stan*](https://mc-stan.org/rstantools/articles/developer-guidelines.html).

## Creating the package skeleton

The **rstantools** package offers two methods for adding Stan
functionality to R packages:

- [`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md):
  set up a new R package with Stan programs
- [`use_rstan()`](https://mc-stan.org/rstantools/dev/reference/use_rstan.md):
  add Stan functionality to an *existing* R package

Here we will use
[`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
to initialize a bare-bones package directory. The name of our demo
package will be **rstanlm**; it will fit a simple linear regression
model using Stan.

``` r
library("rstantools")
rstan_create_package(path = 'rstanlm')
```

    This is rstantools version 2.6.0.9000

    Creating package skeleton for package: rstanlm

     [34mPackage [39m: rstanlm
     [34mTitle [39m: What the Package Does (One Line, Title Case)
     [34mVersion [39m: 0.0.0.9000
     [34mAuthors@R [39m (parsed):
        * First Last <first.last@example.com> [aut, cre]
     [34mDescription [39m: What the package does (one paragraph).
     [34mLicense [39m: `use_mit_license()`, `use_gpl3_license()` or friends to
        pick a license
     [34mEncoding [39m: UTF-8
     [34mRoxygen [39m: list(markdown = TRUE)
     [34mRoxygenNote [39m: 7.3.3

    Creating inst/stan/include directory ...

    Creating inst/include directory ...

    Creating src directory ...

    Updating DESCRIPTION ...

    Adding 'configure' files ...

    Next, add the following lines (e.g., via <package-name>-package.R if using roxygen) to your NAMESPACE:

    import(Rcpp)
    import(methods)
    importFrom(rstan, sampling)
    importFrom(rstantools, rstan_config)
    importFrom(RcppParallel, RcppParallelLibs)
    useDynLib(rstanlm, .registration = TRUE)

    Done.

    Adding rstanlm-package.R file ...

    Adding .gitignore file ...

    Adding .Rbuildignore file ...

    Configuring Stan compile and module export instructions ...

    Further Stan-specific steps are described in 'rstanlm/Read-and-delete-me'.

If we had existing `.stan` files to include with the package we could
use the optional `stan_files` argument to
[`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
to include them. Another option, which we’ll use below, is to add the
Stan files once the basic structure of the package is in place.

We can now set the new working directory to the new package directory
and view the contents. (Note: if using RStudio then by default the newly
created project for the package will be opened in a new session and you
will not need the call to
[`setwd()`](https://rdrr.io/r/base/getwd.html).)

``` r
setwd("rstanlm")
list.files(all.files = TRUE)
```

     [1] "."                  ".."                 ".gitignore"        
     [4] ".Rbuildignore"      "configure"          "configure.win"     
     [7] "DESCRIPTION"        "inst"               "NAMESPACE"         
    [10] "R"                  "Read-and-delete-me" "src"               

``` r
file.show("DESCRIPTION")
```

    Package: rstanlm
    Title: What the Package Does (One Line, Title Case)
    Version: 0.0.0.9000
    Authors@R: 
        person("First", "Last", , "first.last@example.com", role = c("aut", "cre"))
    Description: What the package does (one paragraph).
    License: `use_mit_license()`, `use_gpl3_license()` or friends to pick a
        license
    Encoding: UTF-8
    Roxygen: list(markdown = TRUE)
    RoxygenNote: 7.3.3
    Biarch: true
    Depends: 
        R (>= 3.4.0)
    Imports: 
        methods,
        Rcpp (>= 0.12.0),
        RcppParallel (>= 5.0.1),
        rstan (>= 2.18.1),
        rstantools (>= 2.6.0.9000)
    LinkingTo: 
        BH (>= 1.66.0),
        Rcpp (>= 0.12.0),
        RcppEigen (>= 0.3.3.3.0),
        RcppParallel (>= 5.0.1),
        rstan (>= 2.18.1),
        StanHeaders (>= 2.18.0)
    SystemRequirements: GNU make

Some of the sections in the `DESCRIPTION` file need to be edited by hand
(e.g., `Title`, `Author`, `Maintainer`, and `Description`, but these
also can be set with the `fields` argument to
[`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)).
However,
[`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
has added the necessary packages and versions to `Depends`, `Imports`,
and `LinkingTo` to enable Stan functionality.

## Read-and-delete-me file

Before deleting the `Read-and-delete-me` file in the new package
directory make sure to read it because it contains some important
instructions about customizing your package:

``` r
file.show("Read-and-delete-me")
```

    Stan-specific notes:

    * All '.stan' files containing stanmodel definitions must be placed in 'inst/stan'.
    * Additional files to be included by stanmodel definition files
      (via e.g., #include "mylib.stan") must be placed in any subfolder of 'inst/stan'.
    * Additional C++ files needed by any '.stan' file must be placed in 'inst/include',
      and can only interact with the Stan C++ library via '#include' directives
      placed in the file 'inst/include/stan_meta_header.hpp'.
    * The precompiled stanmodel objects will appear in a named list called 'stanmodels',
      and you can call them with e.g., 'rstan::sampling(stanmodels$foo, ...)'

You can move this file out of the directory, delete it, or list it in
the `.Rbuildignore` file if you want to keep it in the directory.

``` r
file.remove('Read-and-delete-me')
```

    [1] TRUE

## Stan files

Our package will call **rstan**’s `sampling()` method to use MCMC to fit
a simple linear regression model for an outcome variable `y` with a
single predictor `x`. After writing the necessary Stan program, the file
should be saved with a `.stan` extension in the `inst/stan`
subdirectory. We’ll save the following program to `inst/stan/lm.stan`:

``` stan
// Save this file as inst/stan/lm.stan
data {
  int<lower=1> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real intercept;
  real beta;
  real<lower=0> sigma;
}
model {
  // ... priors, etc.

  y ~ normal(intercept + beta * x, sigma);
}
```

The `inst/stan` subdirectory can contain additional Stan programs if
required by your package. During installation, all Stan programs will be
compiled and saved in the list `stanmodels` that can then be used by R
function in the package. The rule is that the Stan program compiled from
the model code in `inst/stan/foo.stan` is stored as list element
`stanmodels$foo`. Thus, the filename of the Stan program in the
`inst/stan` directory should not contain spaces or dashes and nor should
it start with a number or utilize non-ASCII characters.

## R files

We next create the file `R/lm_stan.R` where we define the function
[`lm_stan()`](https://rdrr.io/pkg/rstanlm/man/lm_stan.html) in which our
compiled Stan model is being used. Setting the
[`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
argument `roxygen = TRUE` (the default value) enables
[**roxygen2**](https://CRAN.R-project.org/package=roxygen2)
documentation for the package functions. The following comment block
placed in `lm_stan.R` ensures that the function has a help file and that
it is added to the package `NAMESPACE`:

``` r
# Save this file as `R/lm_stan.R`

#' Bayesian linear regression with Stan
#'
#' @export
#' @param x Numeric vector of input values.
#' @param y Numeric vector of output values.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
lm_stan <- function(x, y, ...) {
  standata <- list(x = x, y = y, N = length(y))
  out <- rstan::sampling(stanmodels$lm, data = standata, ...)
  return(out)
}
```

When **roxygen2** documentation is enabled, a top-level package file
`R/rstanlm-package.R` is created by
[`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
to import necessary functions for other packages and to set up the
package for compiling Stan C++ code:

``` r
file.show(file.path("R", "rstanlm-package.R"))
```

    #' The 'rstanlm' package.
    #'
    #' @description A DESCRIPTION OF THE PACKAGE
    #'
    #' @docType package
    #' @name rstanlm-package
    #' @aliases rstanlm
    #' @useDynLib rstanlm, .registration = TRUE
    #' @import methods
    #' @import Rcpp
    #' @importFrom rstan sampling
    #' @importFrom rstantools rstan_config
    #' @importFrom RcppParallel RcppParallelLibs
    #'
    #' @references
    #' Stan Development Team (NA). RStan: the R interface to Stan. R package version 2.32.7. https://mc-stan.org
    #'
    NULL

The `#' @description` section can be manually edited to provided
specific information about the package.

## Documentation

With **roxygen** documentation enabled, we need to generate the
documentation for `lm_stan` and update the `NAMESPACE` so the function
is exported, i.e., available to users when the package is installed.
This can be done with the function
[`roxygen2::roxygenize()`](https://roxygen2.r-lib.org/reference/roxygenize.html),
which needs to be called twice initially.

``` r
try(roxygen2::roxygenize(load_code = rstantools_load_code), silent = TRUE)
roxygen2::roxygenize()
```

     [1m [22mWriting  [34mNAMESPACE [39m
     [1m [22m [36mℹ [39m Loading  [34mrstanlm [39m
     [36mℹ [39m Re-compiling  [34m [34mrstanlm [34m [39m (debug build)

     [1m [22m [31m✖ [39m rstanlm-package.R:18: `@docType "package"` is deprecated.
     [36mℹ [39m Please document "_PACKAGE" instead.
     [1m [22mWriting  [34mNAMESPACE [39m
     [1m [22mWriting  [34mlm_stan.Rd [39m
     [1m [22mWriting  [34mrstanlm-package.Rd [39m

## Install and use

Finally, the package is ready to be installed:

``` r
# using ../rstanlm because already inside the rstanlm directory
install.packages("../rstanlm", repos = NULL, type = "source")
```

    Installing package into '/home/runner/work/_temp/Library'
    (as 'lib' is unspecified)

It is also possible to use `devtools::install(quick=FALSE)` to install
the package. The argument `quick=FALSE` is necessary if you want to
recompile the Stan models. Going forward, if you only make a change to
the R code or the documentation, you can set `quick=TRUE` to speed up
the process, or use `devtools::load_all()`.

After installation, the package can be loaded and used like any other R
package:

``` r
library("rstanlm")
```

``` r
fit <- lm_stan(y = rnorm(10), x = rnorm(10), 
               # arguments passed to sampling
               iter = 2000, refresh = 500)
```

    SAMPLING FOR MODEL 'lm' NOW (CHAIN 1).
    Chain 1: 
    Chain 1: Gradient evaluation took 0.000101 seconds
    Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 1.01 seconds.
    Chain 1: Adjust your expectations accordingly!
    Chain 1: 
    Chain 1: 
    Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
    Chain 1: Iteration:  500 / 2000 [ 25%]  (Warmup)
    Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    Chain 1: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
    Chain 1: 
    Chain 1:  Elapsed Time: 0.568 seconds (Warm-up)
    Chain 1:                0.602 seconds (Sampling)
    Chain 1:                1.17 seconds (Total)
    Chain 1: 

    SAMPLING FOR MODEL 'lm' NOW (CHAIN 2).
    Chain 2: 
    Chain 2: Gradient evaluation took 6.8e-05 seconds
    Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.68 seconds.
    Chain 2: Adjust your expectations accordingly!
    Chain 2: 
    Chain 2: 
    Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
    Chain 2: Iteration:  500 / 2000 [ 25%]  (Warmup)
    Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    Chain 2: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
    Chain 2: 
    Chain 2:  Elapsed Time: 0.592 seconds (Warm-up)
    Chain 2:                0.482 seconds (Sampling)
    Chain 2:                1.074 seconds (Total)
    Chain 2: 

    SAMPLING FOR MODEL 'lm' NOW (CHAIN 3).
    Chain 3: 
    Chain 3: Gradient evaluation took 6.8e-05 seconds
    Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.68 seconds.
    Chain 3: Adjust your expectations accordingly!
    Chain 3: 
    Chain 3: 
    Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
    Chain 3: Iteration:  500 / 2000 [ 25%]  (Warmup)
    Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    Chain 3: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
    Chain 3: 
    Chain 3:  Elapsed Time: 0.581 seconds (Warm-up)
    Chain 3:                0.546 seconds (Sampling)
    Chain 3:                1.127 seconds (Total)
    Chain 3: 

    SAMPLING FOR MODEL 'lm' NOW (CHAIN 4).
    Chain 4: 
    Chain 4: Gradient evaluation took 6.7e-05 seconds
    Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.67 seconds.
    Chain 4: Adjust your expectations accordingly!
    Chain 4: 
    Chain 4: 
    Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
    Chain 4: Iteration:  500 / 2000 [ 25%]  (Warmup)
    Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
    Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
    Chain 4: Iteration: 1500 / 2000 [ 75%]  (Sampling)
    Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
    Chain 4: 
    Chain 4:  Elapsed Time: 0.563 seconds (Warm-up)
    Chain 4:                0.61 seconds (Sampling)
    Chain 4:                1.173 seconds (Total)
    Chain 4: 

``` r
print(fit)
```

    Inference for Stan model: lm.
    4 chains, each with iter=2000; warmup=1000; thin=1; 
    post-warmup draws per chain=1000, total post-warmup draws=4000.

               mean se_mean   sd   2.5%   25%   50%   75% 97.5% n_eff Rhat
    intercept  0.09    0.01 0.48  -0.89 -0.20  0.08  0.38  1.02  2396 1.00
    beta      -0.07    0.01 0.46  -0.95 -0.35 -0.08  0.21  0.89  2029 1.00
    sigma      1.44    0.01 0.46   0.85  1.13  1.35  1.65  2.56  1216 1.00
    lp__      -7.38    0.05 1.45 -11.12 -8.03 -7.00 -6.33 -5.76   867 1.01

    Samples were drawn using NUTS(diag_e) at Sat Jan 10 19:29:35 2026.
    For each parameter, n_eff is a crude measure of effective sample size,
    and Rhat is the potential scale reduction factor on split chains (at 
    convergence, Rhat=1).

## Advanced options

Details can be found in the documentation for
[`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
so we only mention some of these briefly here:

- Running
  [`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
  with `auto_config = TRUE` (the default value) automatically
  synchronizes the Stan C++ files with the `.stan` model files located
  in `inst/stan`, although this creates a dependency of your package on
  **rstantools** itself (i.e., **rstantools** must be installed for your
  package to work). Setting `auto_config = FALSE` removes this
  dependency, at the cost of having to manually synchronize Stan C++
  files by running
  [`rstan_config()`](https://mc-stan.org/rstantools/dev/reference/rstan_config.md)
  every time a package `.stan` file is added, removed, or even just
  modified.

- The function
  [`use_rstan()`](https://mc-stan.org/rstantools/dev/reference/use_rstan.md)
  can be used to add Stan functionality to an existing package, instead
  of building the package from scratch.

  - Note: If you are already using roxygen in your package, you’ll have
    to use roxygen to update your Namespace file via the
    `R/<package-name>-package.R` file. Check the roxygen documentation
    for more details.

## Adding additional Stan models to an existing R package with Stan models

One may add additional Stan models to an existing package. The following
steps are required if one is using `devtools`:

1.  Add new Stan file, e.g., `inst/stan/new.stan`
2.  Run
    [`pkgbuild::compile_dll()`](https://pkgbuild.r-lib.org/reference/compile_dll.html)
    to preform a fake R CMD install.
3.  Run
    [`roxygen2::roxygenize()`](https://roxygen2.r-lib.org/reference/roxygenize.html)
    to update the documentation.
4.  Run `devtools::install()` to install the package locally.

## Links

- [*Guidelines for Developers of R Packages Interfacing with
  Stan*](https://mc-stan.org/rstantools/articles/developer-guidelines.html)

- Ask a question at the [Stan Forums](https://discourse.mc-stan.org/)

- [R packages](https://r-pkgs.org/) by Hadley Wickham and Jenny Bryan
  provides a solid foundation in R package development as well as the
  release process.
