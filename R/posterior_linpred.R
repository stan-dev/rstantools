#' Generic function for accessing the posterior distribution of the linear
#' predictor
#'
#' Extract the posterior draws of the linear predictor, possibly transformed by
#' the inverse-link function. See
#' \code{\link[rstanarm]{posterior_linpred.stanreg}} in the
#' \pkg{\link[rstanarm]{rstanarm}} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @param transform Should the linear predictor be transformed using the
#'   inverse-link function? The default is \code{FALSE}, in which case the
#'   untransformed linear predictor is returned.
#' @return \code{posterior_linpred} methods should return a \eqn{D} by \eqn{N}
#'   matrix, where \eqn{D} is the number of draws from the posterior
#'   distribution distribution and \eqn{N} is the number of data points.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-dev-guidelines
#'
#' @examples
#' # See help("posterior_linpred", package = "rstanarm")
#'
posterior_linpred <- function(object, transform = FALSE, ...) {
  UseMethod("posterior_linpred")
}
