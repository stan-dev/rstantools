# Configure system files for compiling Stan source code

Creates or update package-specific system files to compile `.stan` model
files found in `inst/stan`.

## Usage

``` r
rstan_config(pkgdir = ".")
```

## Arguments

- pkgdir:

  Path to package root folder.

## Value

Invisibly, whether or not any files were added/removed/modified by the
function.

## Details

The Stan source files for the package should be stored in:

- `inst/stan` for `.stan` files containing instructions to build a
  `stanmodel` object.

- `inst/stan/any_subfolder` for files to be included via the
  `#include "/my_subfolder/mylib.stan"` directive.

- `inst/stan/any_subfolder` for a `license.stan` file.

- `inst/include` for the `stan_meta_header.hpp` file, to be used for
  directly interacting with the Stan C++ libraries.
