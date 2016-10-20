#' Generic function for accessing the pointwise log-likelihood
#'
#' See \code{\link[rstanarm]{log_lik.stanreg}} in the
#' \pkg{\link{rstanarm}} package for an example.
#'
#' @export
#' @param object Fitted model object.
#' @param ... Arguments passed to methods.
#' @return \code{log_lik} methods should return a \eqn{S} by \eqn{N} matrix,
#'   where \eqn{S} is the size of the posterior sample and \eqn{N} is the number
#'   of data points.
#'
log_lik <- function(object, ...) {
  UseMethod("log_lik")
}
