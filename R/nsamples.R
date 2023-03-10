#' Extract the number of posterior samples stored in a fitted Bayesian model.
#'
#' @export
#' @keywords internal
#' @template args-object
#' @template args-dots
#'
nsamples <- function(object, ...) {
  .Deprecated("ndraws from the posterior package")
  UseMethod("nsamples")
}
