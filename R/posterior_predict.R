#' Generic function for drawing from the posterior predictive distribution
#'
#' See \code{posterior_predict.stanreg} in the \pkg{rstanarm} package for an
#' example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @return \code{posterior_predict} methods should return a \eqn{D} by \eqn{N}
#'   matrix, where \eqn{D} is the number of draws from the posterior predictive
#'   distribution and \eqn{N} is the number of data points being predicted per
#'   draw.
#'
#' @template seealso-rstanarm-pkg
#'
posterior_predict <- function(object, ...) {
  UseMethod("posterior_predict")
}
