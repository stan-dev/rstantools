#' Generic function for accessing posterior draws
#'
#' \code{posterior_sample} is for quickly accessing the posterior draws of
#' parameters in matrix form with all chains combined. See
#' \code{\link[rstanarm]{posterior_sample.stanreg}} in the \pkg{\link{rstanarm}}
#' package for an example.
#'
#' @export
#' @param object Fitted model object.
#' @param ... Arguments passed to methods.
#' @return \code{posterior_sample} methods should return a a \eqn{S} by \eqn{P}
#'   matrix (with all chains combined), where \eqn{S} is the size of the
#'   posterior sample (or sample size specified by the user) and \eqn{P} is the
#'   number of parameters (or subset of parameters specified by the user).
#'
posterior_sample <- function(object, ...) {
  UseMethod("posterior_sample")
}
