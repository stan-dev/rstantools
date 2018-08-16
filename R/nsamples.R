#' Generic function for extracting the number of posterior samples
#'
#' Extract the number of posterior samples stored in a fitted Bayesian model.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
nsamples <- function(object, ...) {
  UseMethod("nsamples")
}
