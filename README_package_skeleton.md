## rstantools: New features for `rstan_package_skeleton`

*Martin Lysy* 

*May 17, 2018*

---

### Summary of features

* **rstantools** now provides both `rstan_package_skeleton` and `rstan_create_package`, based on `utils::package.skeleton` and `usethis::create_package`, respectively.

* Stan functionality can be added to an existing package by calling `use_rstan`, instead of building a package from scratch.

* Stan folder infrastructure now puts all `.stan` files in `inst/stan` and all auto-generated C++ files directly in `src`.  This last step ensures that custom **Rcpp** source code can coexist with the Stan C++ code.

* Each time a `.stan` file gets added/removed/modified requires a call to `rstan_config` in order to generate the Stan C++ code and `Rcpp::loadModule` calls.  However, setting `auto_config = TRUE` in `rstan_{package_skeleton/create_package}` ensures `rstan_config` is called whenever the package is installed (including via `devtools::load_all`), so no need to call it manually unless the user wishes to inspect the Stan C++ code for issues.  This does require the user's package to Import `rstantools`, which is why I made `auto_config` optional, in case the user prefers less dependencies at the cost of manually keeping the Stan C++ code up-to-date.

* **roxygen2** documentation is now optional, and works straight out of the box upon calling `devtools::document`.

* Rather than generating Stan "system files" via `cat` commands, **rstantools** now stores these as template files in `inst/include/sys`, so the build process can be easily modified as improvements become apparent.

### Known Issues

* The `auto_config` mechanism creates a `configure[.win]` file to run `rstantools::rstan_config` with `Rscript`.  Unfortunately, packages having non-empty `configure.win` must be installed with `--merge-multiarch` on multiple architecture Windows (as documented [here](https://cran.r-project.org/bin/windows/base/rw-FAQ.html#How-do-I-build-my-package-for-both-32_002d-and-64_002dbit-R_003f)).  My only access to multiple architecture Windows is via [win-builder](https://win-builder.r-project.org/), which does not seem to install with this flag.  Therefore, I don't know whether the `auto_config = TRUE` mechanism works for multiple architecture Windows, but it will fail on win-builder and therefore packages using it likely will get rejected on CRAN.

* `use_rstan` updates the package `DESCRIPTION` file to contain the exact version of all packages needed to compile Stan code, which themselves are stored in `rstantools/inst/include/sys/DESCRIPTION`.  At present, `use_rstan` does not check that any of these packages can only appear in either `Depends` or `Imports`.  So if the user already has the package in `Depends` it should not be added to `Imports` to avoid an `R CMD check --as-cran` NOTE.

* `use_rstan` should also check that all versions of a package listed under `Depends`/`Imports`/`LinkingTo`/`Suggests`/`Enhances` are the same.

* The `use_rstan` argument `auto_config = TRUE` adds a package dependency on **rstantools**, but `auto_config = FALSE` does not remove this dependency from the `DESCRIPTION` file, because it can't determine whether the user added it themselves or whether it was simply the result of a previous call with `auto_config = TRUE`.  A message should be issued when an **rstantools** dependency is found with `auto_config = FALSE`.

