# Package index

## Package structure

Creating the basic structure of a Stan-based R package or add Stan
programs to an existing package.

- [`rstantools-package`](https://mc-stan.org/rstantools/dev/reference/rstantools-package.md)
  [`rstantools`](https://mc-stan.org/rstantools/dev/reference/rstantools-package.md)
  :

  Tools for Developing R Packages Interfacing with Stan

- [`rstan_create_package()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
  :

  Create a new R package with compiled Stan programs

- [`use_rstan()`](https://mc-stan.org/rstantools/dev/reference/use_rstan.md)
  : Add Stan infrastructure to an existing package

- [`rstan_config()`](https://mc-stan.org/rstantools/dev/reference/rstan_config.md)
  : Configure system files for compiling Stan source code

- [`rstantools_load_code()`](https://mc-stan.org/rstantools/dev/reference/rstantools_load_code.md)
  : Helper function for loading code in roxygenise

## Generics

S3 generics (and some default methods) for adding functionality to your
package using the same naming conventions as **rstanarm** and other
Stan-based R packages.

- [`bayes_R2()`](https://mc-stan.org/rstantools/dev/reference/bayes_R2.md)
  [`loo_R2()`](https://mc-stan.org/rstantools/dev/reference/bayes_R2.md)
  : Generic function and default method for Bayesian R-squared
- [`log_lik()`](https://mc-stan.org/rstantools/dev/reference/log_lik.md)
  : Generic function for pointwise log-likelihood
- [`loo_linpred()`](https://mc-stan.org/rstantools/dev/reference/loo-prediction.md)
  [`loo_epred()`](https://mc-stan.org/rstantools/dev/reference/loo-prediction.md)
  [`loo_predict()`](https://mc-stan.org/rstantools/dev/reference/loo-prediction.md)
  [`loo_predictive_interval()`](https://mc-stan.org/rstantools/dev/reference/loo-prediction.md)
  [`loo_pit()`](https://mc-stan.org/rstantools/dev/reference/loo-prediction.md)
  : Generic functions for LOO predictions
- [`posterior_interval()`](https://mc-stan.org/rstantools/dev/reference/posterior_interval.md)
  : Generic function and default method for posterior uncertainty
  intervals
- [`posterior_epred()`](https://mc-stan.org/rstantools/dev/reference/posterior_epred.md)
  : Generic function for accessing the posterior distribution of the
  conditional expectation
- [`posterior_linpred()`](https://mc-stan.org/rstantools/dev/reference/posterior_linpred.md)
  : Generic function for accessing the posterior distribution of the
  linear predictor
- [`posterior_predict()`](https://mc-stan.org/rstantools/dev/reference/posterior_predict.md)
  : Generic function for drawing from the posterior predictive
  distribution
- [`predictive_error()`](https://mc-stan.org/rstantools/dev/reference/predictive_error.md)
  : Generic function and default method for predictive errors
- [`predictive_interval()`](https://mc-stan.org/rstantools/dev/reference/predictive_interval.md)
  : Generic function for predictive intervals
- [`prior_summary()`](https://mc-stan.org/rstantools/dev/reference/prior_summary.md)
  : Generic function for extracting information about prior
  distributions
