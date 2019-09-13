#' Generic function for drawing from the posterior predictive distribution
#'
#' Draw from the posterior predictive distribution of the outcome. See
#' [posterior_predict.stanreg()](https://mc-stan.org/rstanarm/reference/posterior_predict.stanreg.html)
#' in the \pkg{rstanarm} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @return `posterior_predict()` methods should return a \eqn{D} by \eqn{N}
#'   matrix, where \eqn{D} is the number of draws from the posterior predictive
#'   distribution and \eqn{N} is the number of data points being predicted per
#'   draw.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#'
#' @examples
#' # See help("posterior_predict", package = "rstanarm")
#'
posterior_predict <- function(object, ...) {
  UseMethod("posterior_predict")
}
