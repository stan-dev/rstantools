#' @details When `auto_config = TRUE`, a `configure[.win]` file is added to the
#'   package, calling [rstan_config()] whenever the package is installed.
#'   Consequently, the package must list \pkg{rstantools} in the `DESCRIPTION`
#'   Imports field for this mechanism to work.  Setting `auto_config = FALSE`
#'   removes the package's dependency on \pkg{rstantools}, but the package then
#'   must be manually configured by running [rstan_config()] whenever
#'   `stanmodel` files in `inst/stan` are added, removed, or modified.
