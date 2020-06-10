#' Generic function for accessing the posterior distribution of the
#' conditional expectation
#'
#' Extract the posterior draws of the conditional expectation.
#' See the \pkg{rstanarm} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @return `posterior_epred()` methods should return a \eqn{D} by \eqn{N}
#'   matrix, where \eqn{D} is the number of draws from the posterior
#'   distribution distribution and \eqn{N} is the number of data points.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#'
posterior_epred <- function(object, ...) {
  UseMethod("posterior_epred")
}

