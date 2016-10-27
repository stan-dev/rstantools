#' Generic function for computing the pointwise log-likelihood
#'
#' See \code{log_lik.stanreg} in the \pkg{rstanarm} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @return \code{log_lik} methods should return a \eqn{S} by \eqn{N} matrix,
#'   where \eqn{S} is the size of the posterior sample and \eqn{N} is the number
#'   of data points.
#'
#' @template seealso-rstanarm-pkg
#'
log_lik <- function(object, ...) {
  UseMethod("log_lik")
}
