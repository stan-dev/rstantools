#' Generic function for pointwise log-likelihood
#'
#' We define a new function \code{log_lik} rather than a
#' \code{\link[stats]{logLik}} method because (in addition to the conceptual
#' difference) the documentation for \code{logLik} states that the return value
#' will be a single number, whereas \code{log_lik} returns a matrix. See
#' \code{log_lik.stanreg} in the \pkg{rstanarm} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @return \code{log_lik} methods should return a \eqn{S} by \eqn{N} matrix,
#'   where \eqn{S} is the size of the posterior sample (the number of draws from
#'   the posterior distribution) and \eqn{N} is the number of data points.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-dev-guidelines
#'
#' @examples
#' # Example using rstanarm package:
#' # log_lik method for 'stanreg' objects
#' \donttest{
#' if (require("rstanarm")) {
#'   roaches$roach100 <- roaches$roach1 / 100
#'   fit <- stan_glm(
#'     y ~ roach100 + treatment + senior,
#'     offset = log(exposure2),
#'     data = roaches,
#'     family = poisson(link = "log"),
#'     prior = normal(0, 2.5),
#'     prior_intercept = normal(0, 10),
#'     iter = 500 # to speed up example
#'   )
#'   ll <- log_lik(fit)
#'   dim(ll)
#'   all.equal(ncol(ll), nobs(fit))
#'
#'   nd <- roaches[1:2, ]
#'   nd$treatment[1:2] <- c(0, 1)
#'   ll2 <- log_lik(fit, newdata = nd, offset = c(0, 0))
#'   head(ll2)
#'   dim(ll2)
#'   all.equal(ncol(ll2), nrow(nd))
#' }
#' }
#'
log_lik <- function(object, ...) {
  UseMethod("log_lik")
}
