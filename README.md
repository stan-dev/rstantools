## rstantools: `rstan_package_skeleton_plus`

*Martin Lysy* 

*April 20, 2018*

---

### Description

This patch to **rstantools** provides the function `rstan_package_skeleton_plus`, which is very similar to `rstan_package_skeleton`, but provides some added functionality to simplify the workflow for **R** package developers wishing to distribute Stan code.  The main new features are:

1.  `rstan_package_skeleton` creates the subdirectory `src/stan_files` for the automatically-generated Stan C++ files to be compiled with the package.  However, in order to use `src` subdirectories, the **R**/C++ compiling mechanism must be completely overtaken by a custom `Makevars` file.  This makes it difficult for developers to ensure that their own, Stan-unrelated C++ code gets compiled correctly.  For example, the current workflow makes it essentially impossible to use custom [**Rcpp**](http://www.rcpp.org/) source code in conjunction with Stan, as documented [here](RcppCore/Rcpp#844).  Therefore, all auto-generated Stan C++ files now live directly in `src`.

2.  `rstan_package_skeleton` can only be used to generate a Stan-enabled package from scratch.  However, package developers may wish to add Stan functionality to an existing **R** package.  To address these issues, `rstan_package_skeleton_plus` relies on two exported subroutines: 
    * `use_rstan` to prepare an existing **R** package for compiling Stan binaries.
    * `rstan_config` to (re)-configure a Stan-enabled **R** package to compile properly after `.stan` files have been added or removed (but this process can still be [improved](known issues)).

3.  The **rstantools** "system files" which get copied into the user's package no longer live in **rstanarm**, but in **rstantools** itself (in the subdirectory `inst/include/sys`).  This makes the build process easier to visualize as a whole, and very staightforward to modify as improvements become apparent.

4.  `rstan_package_skeleton_plus` does its very best for you package to install immediately without errors, or NOTES/WARNINGS from `R CMD check` (many of these improvements are no longer needed with the latest GitHub version of **rstantools**.)  

### Installation and Walkthrough

Installation requires the [**devtools**](https://github.com/hadley/devtools) package:

```r
if (!require("devtools")) {
  install.packages("devtools")
}
  
devtools::install_github("mlysy/rstantools", ref = "src_nosub")
```

A step-by-step walkthrough to creating a Stan-enabled package is provided in the following [vignette](http://htmlpreview.github.com/?https://github.com/mlysy/rstantools/src_nosub/inst/doc/minimal-rstan-package-plus.html), which can also be called after installing **rstantools** via:

```{r}
vignette("minimal-rstan-package-plus")
```

### Unit Tests

The new build instructions have been tested on the following packages.  In all cases, "testing" means:

i.  Creating the package from scratch, or removing all traces of Stan from the package except the source `.stan` files themselves.
ii. Running `rstantools::use_rstan()` and `rstantools::rstan_config()` on the existing package.
iii. Reinstalling and then running `testthat::test_package()`.

* [**rstanarm**](http://mc-stan.org/rstanarm/): Bayesian Applied Regression Modeling via Stan.  The version of the package used to run the new build on is [here](https://github.com/mlysy/rstanarm/).
* [**MADPop**](https://github.com/mlysy/MADPop): MHC Allele-Based Differencing between Populations.  The original version of this package is available on CRAN [here](https://CRAN.R-project.org/package=MADPop), and the corresponding GitHub branch is [here](https://github.com/mlysy/MADPop/tree/master).
* [**PK1**](https://github.com/mlysy/PK1): Inference for a One-Compartment Pharmacokinetic Model.  This package features other C++ code linked with **Rcpp** which is fully compatible with the Stan-enabled package.

### License

In order to enable Stan functionality, **rstantools** copies some files to your package.  Since these files are licensed as GPL >= 3, the same license applies to your package should you choose to distribute it.  Even if you don't use **rstantools** to create your package, it is likely that you will be linking to **Rcpp** to export the Stan C++ `stanmodel` objects to **R**.  Since **Rcpp** is released under GPL >= 2, the same license would apply to your package upon distribution.  For more information on licensing with **Rcpp** functionality, see [here](https://softwareengineering.stackexchange.com/questions/254737/does-an-rcpp-dependent-package-require-a-gpl-license) and **Rcpp**'s official FAQ position [here](https://cloud.r-project.org/web/packages/Rcpp/vignettes/Rcpp-FAQ.pdf#subsection.1.5).


### Known Issues

* `use_rstan` updates the package `DESCRIPTION` file to contain the exact version of all packages needed to compile Stan code, which themselves are stored in `rstantools/inst/include/sys/DESCRIPTION`.  At present, `use_rstan` does not check that any of these packages can only appear in either `Depends` or `Imports`.  So if the user already has the package in `Depends` it should not be added to `Imports` to avoid an `R CMD check --as-cran` NOTE.

* `use_rstan` should also check that all versions of a package listed under `Depends`/`Imports`/`LinkingTo`/`Suggests`/`Enhances` are the same.

* `rstan_config` must be run every time a `.stan` file is not only added/removed from the project, but also every time a `.stan` file is even modified.  The reason for this is twofold:
    1.  The package needs to run `Rcpp::loadModule` for every Stan model provided by the package.  This used to be done in a for-loop inside `.onLoad()` but this makes things more difficult to automate if the package has a custom `.onLoad` already.  In fact, **Rcpp** has already addressed this issue by allowing `loadModule` to be called outside of `.onLoad` (which didn't use to be the case).  However, for some reason `loadModule` outside of `.onLoad` needs the module names to be hard-coded, i.e., can't use a for-loop.  Hence, each call to `loadModule` is currently hard-coded in `R/stanmodels.R`.
	2.  The package needs to update `.cc/.hpp` pairs corresponding to each `stanmodel` every time a `.stan` file is added/removed/modified.  The current **rstantools** build procedure does not require this.  However, it does use the `GNU make` command `wildcard`, which is [not permitted](http://r.789695.n4.nabble.com/Alternative-for-wildcard-gnu-extension-in-Makevars-td4707151.html) by `R CMD check`.
    It shouldn't be too hard to fix this though: removing the need for `rstan_config()` is at the top of my list.

* `rstan_package_skeleton` forces you to use **roxygen2** for documentation, whereas `rstan_package_skeleton_plus` does not.  As a result, when building from scratch with `rstan_package_skeleton_plus`, enabling **roxygen2** documentation can be somewhat tricky.  That is, the default `NAMESPACE` doesn't get overwritten by default, and if you erase it, `devtools::document()` will throw an error when `loadModule` gets invoked, as this is done before the `NAMESPACE` is recreated.  My current workaround is to add the line "created by roxygen2" to the top of the default `NAMESPACE` so **roxygen2** overwrites it.  Still not sure though whether this is best/safest approach or how to best provide implementation for package developers.

* This is more of a long-term project, but...The Stan C++ linking process of **rstantools** is very different from that provided by **rstan**.  To my understanding, this is because **rstan** offers the possibility of saving `stanmodel` objects to disk, which can't be achieved with **Rcpp** code compiled on-the-fly.  Thus **rstan** has a very roundabout method for interacting with **Rcpp**, i.e., indirectly through the **inline** package.  In my opinion, it would be preferable for R/Stan development if there were a single build mechanism.  Therefore, I've been working on an extension to **Rcpp** which allows you to save code compiled on-the-fly.  Essentially, it would create a small package invisibly to the user, and save/load its contents from a binary connection on-the-fly.  Thus, we are only ever creating packages, i.e., can employ a unified build mechanism appropriate for both **rstan** and packages authored with **rstantools**.
