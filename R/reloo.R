#' Generic function for recomputing 'loo' for a subset of observations
#'
#' This is a generic function for which methods can be developed for different
#' fitted model objects. The purpose is to compute exact cross-validation for
#' problematic observations for which approximate leave-one-out cross-validation
#' may return incorrect results. See the methods in the \pkg{rstanarm} and
#' \pkg{brms} packages for examples.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
reloo <- function(object, ...) {
  UseMethod("reloo")
}
