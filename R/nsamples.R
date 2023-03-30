#' Generic function for extracting the number of posterior samples
#'
#' @export
#' @keywords internal
#' @template args-object
#' @template args-dots
#'
nsamples <- function(object, ...) {
  UseMethod("nsamples")
}
