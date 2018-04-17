# rstantools

This patch makes several modifications to the `rstan_package_skeleton()` build process to simplify the workflow for **R** package developers wishing to distributed Stan code.  Improvements include:

1. The current version of `rstan_package_skeleton` can only be used to generate a Stan-enabled package from scratch.  The new version runs two sub-tasks: 
    * `use_rstan` to prepare an existing **R** package for compiling Stan binaries.
    * `rstan_config` to (re)-configure a Stan-enabled **R** package to compile properly after `.stan` files have been added or removed.
    Both of these functions are available to the user so they can not only create a Stan-enabled package from scratch, but add Stan functionality to an existing package.
2. The current version of `rstan_package_skeleton` creates a package to which you cannot add your own [**Rcpp**](http://www.rcpp.org/)-supported C++ code.   The new version is fully-compatible with **Rcpp**.
3. The current version of `rstan_package_skeleton` causes the package to issue several NOTES/WARNINGS with `R CMD check --as-cran`.  In this new version most of these have been fixed (for known issues see [here](#known-issues)).

### Installation

Requires [devtools](https://github.com/hadley/devtools) package:

```r
if (!require("devtools"))
  install.packages("devtools")
  
devtools::install_github("mlysy/rstantools", ref = "src_nosub")
```

### Unit Tests

The new build instructions have been tested on the following packages.  In all cases, "testing" means (i) removing all traces of Stan from the package except the source `.stan` files themselves, (ii) running `rstantools::use_rstan()` and `rstantools::rstan_config()` on the existing package and (iii) reinstalling and then running `testthat::test_package()`.

* [**rstanarm**](http://mc-stan.org/rstanarm): Bayesian Applied Regression Modeling via Stan.  The version of the package used to run the new build on is here.
* [**MADPop**](https://github.com/mlysy/MADPop): MHC Allele-Based Differencing between Populations.  The original version of this package is available on CRAN [here](https://CRAN.R-project.org/package=MADPop), and the corresponding GitHub branch is [here](https://github.com/mlysy/MADPop/tree/master).
* [**PK1**](https::/github.com/mlysy/PK1): Inference for a One-Compartment Pharmacokinetic Model.  This package features other C++ code linked with **Rcpp** which is fully compatible with the Stan-enabled package.

### Known Issues

* `use_rstan` updates the package `DESCRIPTION` file to contain the exact version of all packages needed to compile Stan code, which themselves are stored in `rstantools/inst/include/sys/DESCRIPTION`.  At present, `use_rstan` does not check that any of these packages can only appear in either `Depends` or `Imports`.  So if the user already has the package in `Depends` it should not be added to `Imports` to avoid an `R CMD check --as-cran` NOTE.
* `use_rstan` should also check that all versions of a package listed under `Depends`/`Imports`/`LinkingTo`/`Suggests`/`Enhances` are the same.
