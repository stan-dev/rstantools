# rstantools 2.4.0

* Update to match CRAN's patched version by @jgabry in #114
* Include additional template imports to suppress NOTEs by @andrjohns in #115
* Fix packages with stanfunctions under rstan 2.33+ by @andrjohns in #117


# rstantools 2.3.1

* Deprecated `init_cpp`. (#105)
* Bugfix for standalone functions under 2.31 (#110)
* Only add Makevars for current platform. (#109)
* Suppress false-positive warning for standalone functions. (#111)

# rstantools 2.3.0

* Updated C++ standard to C++17 (#100)
* Updated the handling of exporting standalone stan functions in packages for compatibility with the 2.26 (and beyond) versions of StanHeaders and rstan (#101)
* Added Andrew Johnson (@andrjohns) as an author 

# rstantools 2.2.0

(Github issue/PR numbers in parentheses)

* Updated "Step by step guide" vignette with instructions for adding new Stan
models to an existing R package that already has Stan models. (#79, @rerickson-usgs) 

* Fixed R CMD check NOTE "configure does not appear to have a #! interpreter line". (#83)

* Use writeLines instead of cat to fix line endings issue reported by CRAN. (#87)

* Switch to GitHub Actions for CI. (#90, @andrjohns)

* Deprecate automatic creation of `.travis.yml` file. We now recommend the use
of GitHub Actions. (#89)

* Ensure compatibility with future versions of RStan. (#85, #94, @andrjohns, @hsbadr)


# rstantools 2.1.1

(Github issue/PR numbers in parentheses)

* Compatibility with StanHeaders 2.21.0-5

# rstantools 2.1.0

* Compatibility with StanHeaders 2.21.0-3 
* Improve messaging around updating NAMESPACE file (#75, @mikekaminsky)
* More informative error message for `rstan_create_package()` when directory
already exists. (#68, @mcol)
* Add generated C++ files to .gitignore and .Rbuildignore (#66, @mcol)
* New generic `posterior_epred()` (#74)

# rstantools 2.0.0

* Added Martin Lysy as a coauthor.

* New function `rstan_create_package()` (based on
`usethis::create_package()`) replaces `rstan_package_skeleton()`
for the purpose of starting a new package with Stan functionality.

* Stan functionality can be added to an _existing_ package by calling
`use_rstan()` instead of starting a new package from scratch.

* Stan folder infrastructure now puts all `.stan` files in `inst/stan` and all
auto-generated C++ files directly in `src`.  This last step ensures that custom
**Rcpp** source code can coexist with the Stan C++ code.

* Each time a `.stan` file gets added/removed/modified requires a call to
`rstan_config()` in order to generate the Stan C++ code and `Rcpp::loadModule()`
calls.  However, setting `auto_config = TRUE` (the default) in
`rstan_create_package()` ensures `rstan_config()` is called whenever the package
is installed (including via `devtools::load_all()`), so no need to call it
manually unless the user wishes to inspect the Stan C++ code for issues.

* **roxygen2** documentation is now optional, but remains the default.

* Rather than generating Stan "system files" via `cat` commands, **rstantools**
now stores these as template files in `inst/include/sys`, so the build process
can be easily modified as improvements become apparent.


# rstantools 1.5.1

(Github issue/PR numbers in parentheses)

* Fix issue related to changes in the **usethis** package by removing the
`fields` argument to `rstan_package_skeleton()` and setting it internally
instead.
* New generic `nsamples()` (#35)


# rstantools 1.5.0

(Github issue/PR numbers in parentheses)

* New [vignette](https://mc-stan.org/rstantools/articles/) walking through the package creation process. (#9) (thanks to Stefan Siegert)

* `rstan_package_skeleton()` now calls `usethis::create_package()` instead of `utils::package.skeleton()`. (#28)

* Update `rstan_package_skeleton()` for latest build process (#19)

* `rstan_package_skeleton()` now does a bit more work for the user to make sure the the NAMESPACE file is correct.

* Simplify instructions in Read-and-delete-me (related to #19).

# rstantools 1.4.0

(Github issue/PR numbers in parentheses)

* Update `rstan_package_skeleton()` to correspond to rstanarm 2.17.2.

# rstantools 1.3.0

(Github issue/PR numbers in parentheses)

* Add `bayes_R2()` generic and default method. (#8)

# rstantools 1.2.1

(Github issue/PR numbers in parentheses)

* Add `init_cpp()` function for generating `src/init.cpp` in order to pass R CMD
check in R 3.4.x. `rstan_package_skeleton()` calls `init_cpp()` internally. (#6)

# rstantools 1.2.0

(Github issue/PR numbers in parentheses)

* Minor fixes to `rstan_package_skeleton()` for better Windows compatibility. (#1, #2)

* Fix some typos in the developer guidelines vignette. (#3, #4)

* Add `loo_predict()`, `loo_linpred()`, and `loo_predictive_interval()` generics in 
preparation for adding methods to the __rstanarm__ package. (#5)

# rstantools 1.1.0

Changes to `rstan_package_skeleton`:

* Add comment in `Read-and-delete-me` about importing all of __Rcpp__ and __methods__ packages.

* Include __methods__ in `Depends` field of `DESCRIPTION` file.

* Also download __rstanarm__'s `Makevars.win` file.

# rstantools 1.0.0

* Initial CRAN release
