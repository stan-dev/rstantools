#' Generic function for computing posterior uncertainty intervals
#'
#' These intervals are often referred to as credible intervals, but we use the
#' term uncertainty intervals to highlight the fact that wider intervals
#' correspond to greater uncertainty. See
#' \code{\link[rstanarm]{posterior_interval.stanreg}} in the
#' \pkg{\link{rstanarm}} package for an example.
#'
#' @export
#' @param object Fitted model object.
#' @param ... Arguments passed to methods.
#' @return \code{posterior_interval} methods should return a matrix with two
#'   columns and as many rows as model parameters (or a subset of parameters
#'   specified by the user). For a given probability, \eqn{p}, the columns
#'   correspond to the lower and upper \eqn{100p}\% interval limits and have the
#'   names \eqn{100\alpha/2}\% and \eqn{100(1 - \alpha/2)}\%, where \eqn{\alpha
#'   = 1-p}. For example, for \eqn{90}\% intervals, the column names should be
#'   \code{"5\%"} and \code{"95\%"}.
#'
posterior_interval <- function(object, ...) {
  UseMethod("posterior_interval")
}
