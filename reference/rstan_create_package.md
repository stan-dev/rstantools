# Create a new R package with compiled Stan programs

The `rstan_create_package()` function helps get you started developing a
new R package that interfaces with Stan via the rstan package. First the
basic package structure is set up via
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html).
Then several adjustments are made so the package can include Stan
programs that can be built into binary versions (i.e., pre-compiled Stan
C++ code).

The **Details** section below describes the process and the **See Also**
section provides links to recommendations for developers and a
step-by-step walk-through.

As of version `2.0.0` of rstantools the `rstan_package_skeleton()`
function is defunct and only `rstan_create_package()` is supported.

## Usage

``` r
rstan_create_package(
  path,
  fields = NULL,
  rstudio = TRUE,
  open = TRUE,
  stan_files = character(),
  roxygen = TRUE,
  travis = FALSE,
  license = TRUE,
  auto_config = TRUE
)
```

## Arguments

- path:

  The path to the new package to be created (terminating in the package
  name).

- fields, rstudio, open:

  Same as
  [`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html).
  See the documentation for that function, especially the note in the
  **Description** section about the side effect of changing the active
  project.

- stan_files:

  A character vector with paths to `.stan` files to include in the
  package.

- roxygen:

  Should roxygen2 be used for documentation? Defaults to `TRUE`. If so,
  a file `R/{pkgname}-package.R` is added to the package with roxygen
  tags for the required import lines. See the **Note** section below for
  advice specific to the latest versions of roxygen2.

- travis:

  Should a `.travis.yml` file be added to the package directory? This
  argument is now deprecated. We recommend using GitHub Actions to set
  up automated testings for your package. See
  https://github.com/r-lib/actions for useful templates.

- license:

  Logical or character; whether or not to paste the contents of a
  `license.stan` file at the top of all Stan code, or path to such a
  file. If `TRUE` (the default) adds the `GPL (>= 3)` license (see
  **Details**).

- auto_config:

  Whether to automatically configure Stan functionality whenever the
  package gets installed (see **Details**). Defaults to `TRUE`.

## Details

This function first creates a regular R package using
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html),
then adds the infrastructure required to compile and export `stanmodel`
objects. In the package root directory, the user's Stan source code is
located in:

    inst/
      |_stan/
      |   |_include/
      |
      |_include/

All `.stan` files containing instructions to build a `stanmodel` object
must be placed in `inst/stan`. Other `.stan` files go in any `stan/`
subdirectory, to be invoked by Stan's `#include` mechanism, e.g.,

    #include "include/mylib.stan"
    #include "data/preprocess.stan"

See rstanarm for many examples.

The folder `inst/include` is for all user C++ files associated with the
Stan programs. In this folder, the only file to directly interact with
the Stan C++ library is `stan_meta_header.hpp`; all other `#include`
directives must be channeled through here.

The final step of the package creation is to invoke
[`rstan_config()`](https://mc-stan.org/rstantools/reference/rstan_config.md),
which creates the following files for interfacing with Stan objects from
R:

- `src` contains the `stan_ModelName{.cc/.hpp}` pairs associated with
  all `ModelName.stan` files in `inst/stan` which define `stanmodel`
  objects.

- `src/Makevars[.win]` which link to the `StanHeaders` and Boost (`BH`)
  libraries.

- `R/stanmodels.R` loads the C++ modules containing the `stanmodel`
  class definitions, and assigns an R instance of each `stanmodel`
  object to a `stanmodels` list (with names corresponding to the names
  of the Stan files).

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

In order to enable Stan functionality,
[rstantools](https://mc-stan.org/rstantools/reference/rstantools-package.md)
copies some files to your package. Since these files are licensed as GPL
\>= 3, the same license applies to your package should you choose to
distribute it. Even if you don't use
[rstantools](https://mc-stan.org/rstantools/reference/rstantools-package.md)
to create your package, it is likely that you will be linking to Rcpp to
export the Stan C++ `stanmodel` objects to R. Since Rcpp is released
under GPL \>= 2, the same license would apply to your package upon
distribution.

Authors willing to license their Stan programs of general interest under
the GPL are invited to contribute their `.stan` files and supporting R
code to the rstanarm package.

## Note

For devtools users, because of changes in the latest versions of
roxygen2 it may be necessary to run
[`pkgbuild::compile_dll()`](https://pkgbuild.r-lib.org/reference/compile_dll.html)
once before `devtools::document()` will work.

## Using the pre-compiled Stan programs in your package

The `stanmodel` objects corresponding to the Stan programs included with
your package are stored in a list called `stanmodels`. To run one of the
Stan programs from within an R function in your package just pass the
appropriate element of the `stanmodels` list to one of the rstan
functions for model fitting (e.g., `sampling()`). For example, for a
Stan program `"foo.stan"` you would use
`rstan::sampling(stanmodels$foo, ...)`.

## See also

- [`use_rstan()`](https://mc-stan.org/rstantools/reference/use_rstan.md)
  for adding Stan functionality to an existing R package and
  [`rstan_config()`](https://mc-stan.org/rstantools/reference/rstan_config.md)
  for updating an existing package when its Stan files are changed.

- The rstanarm package
  [repository](https://github.com/stan-dev/rstanarm) on GitHub.

&nbsp;

- Guidelines and recommendations for developers of R packages
  interfacing with Stan and a demonstration getting a simple package
  working can be found in the vignettes included with rstantools and at
  [mc-stan.org/rstantools/articles](https://mc-stan.org/rstantools/articles/).

&nbsp;

- After reading the guidelines for developers, if you have trouble
  setting up your package let us know on the the [Stan
  Forums](https://discourse.mc-stan.org) or at the rstantools GitHub
  [issue tracker](https://github.com/stan-dev/rstantools/issues).
