#' Generic function for pointwise log-likelihood
#'
#' We define a new function \code{log_lik} rather than a
#' \code{\link[stats]{logLik}} method because (in addition to the conceptual
#' difference) the documentation for \code{logLik} states that the return value
#' will be a single number, whereas \code{log_lik} returns a matrix. See
#' \code{\link[rstanarm]{log_lik.stanreg}} in the \pkg{rstanarm} package for an
#' example.
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
#' # See help("log_lik", package = "rstanarm")
#'
log_lik <- function(object, ...) {
  UseMethod("log_lik")
}
