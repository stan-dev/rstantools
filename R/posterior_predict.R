#' Generic function for drawing from the posterior predictive distribution
#'
#' See \code{\link[rstanarm]{posterior_predict.stanreg}} in the
#' \pkg{\link{rstanarm}} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @return \code{posterior_predict} methods should return a \eqn{D} by \eqn{N}
#'   matrix, where \eqn{D} is the number of draws from the posterior predictive
#'   distribution and \eqn{N} is the sample size (number of observations) per
#'   draw.
#'
posterior_predict <- function(object, ...) {
  UseMethod("posterior_predict")
}
