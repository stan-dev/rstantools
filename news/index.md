# Changelog

## rstantools (development version)

## rstantools 2.5.0

CRAN release: 2025-09-01

- Extended
  [`loo_pit()`](https://mc-stan.org/rstantools/reference/loo-prediction.md)
  for discrete data by
  [@TeemuSailynoja](https://github.com/TeemuSailynoja) in
  [\#121](https://github.com/stan-dev/rstantools/issues/121)
- Add
  [`loo_epred()`](https://mc-stan.org/rstantools/reference/loo-prediction.md)
  by [@avehtari](https://github.com/avehtari) in
  [\#122](https://github.com/stan-dev/rstantools/issues/122)
- Fix stanfunctions failures with new Stan RNG by
  [@andrjohns](https://github.com/andrjohns) in
  [\#125](https://github.com/stan-dev/rstantools/issues/125)
- Add handling for new RNG type in Stan by
  [@andrjohns](https://github.com/andrjohns) in
  [\#126](https://github.com/stan-dev/rstantools/issues/126)
- Fix regression (introduced in 2.4.0) in the compilation of packages
  with custom Stan functions by [@mcol](https://github.com/mcol) in
  [\#137](https://github.com/stan-dev/rstantools/issues/137)
- Fix roxygen2 warning by [@mcol](https://github.com/mcol) in
  [\#136](https://github.com/stan-dev/rstantools/issues/136)

## rstantools 2.4.0

CRAN release: 2024-01-31

- Update to match CRAN’s patched version by
  [@jgabry](https://github.com/jgabry) in
  [\#114](https://github.com/stan-dev/rstantools/issues/114)
- Include additional template imports to suppress NOTEs by
  [@andrjohns](https://github.com/andrjohns) in
  [\#115](https://github.com/stan-dev/rstantools/issues/115)
- Fix packages with stanfunctions under rstan 2.33+ by
  [@andrjohns](https://github.com/andrjohns) in
  [\#117](https://github.com/stan-dev/rstantools/issues/117)

## rstantools 2.3.1

CRAN release: 2023-03-30

- Deprecated `init_cpp`.
  ([\#105](https://github.com/stan-dev/rstantools/issues/105))
- Bugfix for standalone functions under 2.31
  ([\#110](https://github.com/stan-dev/rstantools/issues/110))
- Only add Makevars for current platform.
  ([\#109](https://github.com/stan-dev/rstantools/issues/109))
- Suppress false-positive warning for standalone functions.
  ([\#111](https://github.com/stan-dev/rstantools/issues/111))

## rstantools 2.3.0

CRAN release: 2023-03-09

- Updated C++ standard to C++17
  ([\#100](https://github.com/stan-dev/rstantools/issues/100))
- Updated the handling of exporting standalone stan functions in
  packages for compatibility with the 2.26 (and beyond) versions of
  StanHeaders and rstan
  ([\#101](https://github.com/stan-dev/rstantools/issues/101))
- Added Andrew Johnson ([@andrjohns](https://github.com/andrjohns)) as
  an author

## rstantools 2.2.0

CRAN release: 2022-04-08

(Github issue/PR numbers in parentheses)

- Updated “Step by step guide” vignette with instructions for adding new
  Stan models to an existing R package that already has Stan models.
  ([\#79](https://github.com/stan-dev/rstantools/issues/79),
  [@rerickson-usgs](https://github.com/rerickson-usgs))

- Fixed R CMD check NOTE “configure does not appear to have a \#!
  interpreter line”.
  ([\#83](https://github.com/stan-dev/rstantools/issues/83))

- Use writeLines instead of cat to fix line endings issue reported by
  CRAN. ([\#87](https://github.com/stan-dev/rstantools/issues/87))

- Switch to GitHub Actions for CI.
  ([\#90](https://github.com/stan-dev/rstantools/issues/90),
  [@andrjohns](https://github.com/andrjohns))

- Deprecate automatic creation of `.travis.yml` file. We now recommend
  the use of GitHub Actions.
  ([\#89](https://github.com/stan-dev/rstantools/issues/89))

- Ensure compatibility with future versions of RStan.
  ([\#85](https://github.com/stan-dev/rstantools/issues/85),
  [\#94](https://github.com/stan-dev/rstantools/issues/94),
  [@andrjohns](https://github.com/andrjohns),
  [@hsbadr](https://github.com/hsbadr))

## rstantools 2.1.1

CRAN release: 2020-07-06

(Github issue/PR numbers in parentheses)

- Compatibility with StanHeaders 2.21.0-5

## rstantools 2.1.0

CRAN release: 2020-06-01

- Compatibility with StanHeaders 2.21.0-3
- Improve messaging around updating NAMESPACE file
  ([\#75](https://github.com/stan-dev/rstantools/issues/75),
  [@mikekaminsky](https://github.com/mikekaminsky))
- More informative error message for
  [`rstan_create_package()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  when directory already exists.
  ([\#68](https://github.com/stan-dev/rstantools/issues/68),
  [@mcol](https://github.com/mcol))
- Add generated C++ files to .gitignore and .Rbuildignore
  ([\#66](https://github.com/stan-dev/rstantools/issues/66),
  [@mcol](https://github.com/mcol))
- New generic
  [`posterior_epred()`](https://mc-stan.org/rstantools/reference/posterior_epred.md)
  ([\#74](https://github.com/stan-dev/rstantools/issues/74))

## rstantools 2.0.0

CRAN release: 2019-09-14

- Added Martin Lysy as a coauthor.

- New function
  [`rstan_create_package()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  (based on
  [`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html))
  replaces
  [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  for the purpose of starting a new package with Stan functionality.

- Stan functionality can be added to an *existing* package by calling
  [`use_rstan()`](https://mc-stan.org/rstantools/reference/use_rstan.md)
  instead of starting a new package from scratch.

- Stan folder infrastructure now puts all `.stan` files in `inst/stan`
  and all auto-generated C++ files directly in `src`. This last step
  ensures that custom **Rcpp** source code can coexist with the Stan C++
  code.

- Each time a `.stan` file gets added/removed/modified requires a call
  to
  [`rstan_config()`](https://mc-stan.org/rstantools/reference/rstan_config.md)
  in order to generate the Stan C++ code and
  [`Rcpp::loadModule()`](https://rdrr.io/pkg/Rcpp/man/loadModule.html)
  calls. However, setting `auto_config = TRUE` (the default) in
  [`rstan_create_package()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  ensures
  [`rstan_config()`](https://mc-stan.org/rstantools/reference/rstan_config.md)
  is called whenever the package is installed (including via
  `devtools::load_all()`), so no need to call it manually unless the
  user wishes to inspect the Stan C++ code for issues.

- **roxygen2** documentation is now optional, but remains the default.

- Rather than generating Stan “system files” via `cat` commands,
  **rstantools** now stores these as template files in
  `inst/include/sys`, so the build process can be easily modified as
  improvements become apparent.

## rstantools 1.5.1

CRAN release: 2018-08-22

(Github issue/PR numbers in parentheses)

- Fix issue related to changes in the **usethis** package by removing
  the `fields` argument to
  [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  and setting it internally instead.
- New generic
  [`nsamples()`](https://mc-stan.org/rstantools/reference/nsamples.md)
  ([\#35](https://github.com/stan-dev/rstantools/issues/35))

## rstantools 1.5.0

CRAN release: 2018-04-17

(Github issue/PR numbers in parentheses)

- New [vignette](https://mc-stan.org/rstantools/articles/) walking
  through the package creation process.
  ([\#9](https://github.com/stan-dev/rstantools/issues/9)) (thanks to
  Stefan Siegert)

- [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  now calls
  [`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html)
  instead of
  [`utils::package.skeleton()`](https://rdrr.io/r/utils/package.skeleton.html).
  ([\#28](https://github.com/stan-dev/rstantools/issues/28))

- Update
  [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  for latest build process
  ([\#19](https://github.com/stan-dev/rstantools/issues/19))

- [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  now does a bit more work for the user to make sure the the NAMESPACE
  file is correct.

- Simplify instructions in Read-and-delete-me (related to
  [\#19](https://github.com/stan-dev/rstantools/issues/19)).

## rstantools 1.4.0

CRAN release: 2017-12-21

(Github issue/PR numbers in parentheses)

- Update
  [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  to correspond to rstanarm 2.17.2.

## rstantools 1.3.0

CRAN release: 2017-08-02

(Github issue/PR numbers in parentheses)

- Add
  [`bayes_R2()`](https://mc-stan.org/rstantools/reference/bayes_R2.md)
  generic and default method.
  ([\#8](https://github.com/stan-dev/rstantools/issues/8))

## rstantools 1.2.1

(Github issue/PR numbers in parentheses)

- Add
  [`init_cpp()`](https://mc-stan.org/rstantools/reference/init_cpp.md)
  function for generating `src/init.cpp` in order to pass R CMD check in
  R 3.4.x.
  [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  calls
  [`init_cpp()`](https://mc-stan.org/rstantools/reference/init_cpp.md)
  internally. ([\#6](https://github.com/stan-dev/rstantools/issues/6))

## rstantools 1.2.0

CRAN release: 2017-03-17

(Github issue/PR numbers in parentheses)

- Minor fixes to
  [`rstan_package_skeleton()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  for better Windows compatibility.
  ([\#1](https://github.com/stan-dev/rstantools/issues/1),
  [\#2](https://github.com/stan-dev/rstantools/issues/2))

- Fix some typos in the developer guidelines vignette.
  ([\#3](https://github.com/stan-dev/rstantools/issues/3),
  [\#4](https://github.com/stan-dev/rstantools/issues/4))

- Add
  [`loo_predict()`](https://mc-stan.org/rstantools/reference/loo-prediction.md),
  [`loo_linpred()`](https://mc-stan.org/rstantools/reference/loo-prediction.md),
  and
  [`loo_predictive_interval()`](https://mc-stan.org/rstantools/reference/loo-prediction.md)
  generics in preparation for adding methods to the **rstanarm**
  package. ([\#5](https://github.com/stan-dev/rstantools/issues/5))

## rstantools 1.1.0

CRAN release: 2016-12-20

Changes to `rstan_package_skeleton`:

- Add comment in `Read-and-delete-me` about importing all of **Rcpp**
  and **methods** packages.

- Include **methods** in `Depends` field of `DESCRIPTION` file.

- Also download **rstanarm**’s `Makevars.win` file.

## rstantools 1.0.0

CRAN release: 2016-11-20

- Initial CRAN release
