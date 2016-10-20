#' Generic function for computing in-sample or out-of-sample predictive errors
#'
#' Generic function for computing predictive errors \eqn{y - y^{rep}}{y - yrep}
#' (in-sample, for observed \eqn{y}) or \eqn{y - \tilde{y}}{y - ytilde}
#' (out-of-sample, for new or held-out \eqn{y}). See
#' \code{\link[rstanarm]{predictive_error.stanreg}} in the \pkg{\link{rstanarm}}
#' package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @return \code{predictive_error} methods should return a \code{ndraws} by
#'   \code{nobs} matrix.
#'
predictive_error <- function(object, ...) {
  UseMethod("predictive_error")
}
