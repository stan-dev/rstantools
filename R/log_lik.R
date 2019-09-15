#' Generic function for pointwise log-likelihood
#'
#' We define a new function `log_lik()` rather than a
#' [stats::logLik()] method because (in addition to the conceptual
#' difference) the documentation for `logLik()` states that the return value
#' will be a single number, whereas `log_lik()` returns a matrix. See
#' the [log_lik.stanreg()](https://mc-stan.org/rstanarm/reference/log_lik.stanreg.html)
#' method in the \pkg{rstanarm} package for an example of defining a method.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @return `log_lik()` methods should return a \eqn{S} by \eqn{N} matrix,
#'   where \eqn{S} is the size of the posterior sample (the number of draws from
#'   the posterior distribution) and \eqn{N} is the number of data points.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#'
#' @examples
#' # See help("log_lik", package = "rstanarm")
#'
log_lik <- function(object, ...) {
  UseMethod("log_lik")
}
