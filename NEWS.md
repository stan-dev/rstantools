# rstantools 1.3.0
(Github issue/PR numbers in parentheses)

* Add `bayes_R2` generic and default method. (#8)

# rstantools 1.2.1
(Github issue/PR numbers in parentheses)

* Add `init_cpp` function for generating `src/init.cpp` in order to pass R CMD
check in R 3.4.x. `rstan_package_skeleton` calls `init_cpp` internally. (#6)

# rstantools 1.2.0

(Github issue/PR numbers in parentheses)

* Minor fixes to `rstan_package_skeleton` for better Windows compatibility. (#1, #2)
* Fix some typos in the developer guidelines vignette. (#3, #4)
* Add `loo_predict`, `loo_linpred`, and `loo_predictive_interval` generics in 
preparation for adding methods to the __rstanarm__ package. (#5)

# rstantools 1.1.0

Changes to `rstan_package_skeleton`:

* Add comment in `Read-and-delete-me` about importing all of __Rcpp__ and __methods__ packages.
* Include __methods__ in `Depends` field of `DESCRIPTION` file.
* Also download __rstanarm__'s `Makevars.win` file.

# rstantools 1.0.0

* Initial CRAN release
