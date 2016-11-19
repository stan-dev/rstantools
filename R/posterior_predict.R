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
#' @template seealso-dev-guidelines
#'
#' @examples
#' # Example using rstanarm package:
#' # posterior_predict method for 'stanreg' objects
#' \donttest{
#' if (require("rstanarm")) {
#'   fit <- stan_glm(mpg ~ wt + am, data = mtcars)
#'   yrep <- posterior_predict(fit)
#'   all.equal(ncol(yrep), nobs(fit))
#'
#'   nd <- data.frame(wt = mean(mtcars$wt), am = c(0, 1))
#'   ytilde <- posterior_predict(fit, newdata = nd)
#'   all.equal(ncol(ytilde), nrow(nd))
#' }
#' }
#'
#' # Also see help("posterior_predict", package = "rstanarm")
#'
posterior_predict <- function(object, ...) {
  UseMethod("posterior_predict")
}
