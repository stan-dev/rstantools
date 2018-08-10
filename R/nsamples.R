#' Generic function for extracting the number of posterior samples
#'
#' Extract the number of posterior samples stored in a fitted Bayesian model.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @examples
#' # Example using rstanarm package:
#' # nsamples method for 'stanreg' objects
#' \donttest{
#' if (require("rstanarm")) {
#'   fit <- stan_glm(mpg ~ wt + am, data = mtcars)
#'   nsamples(fit)
#' }
#' }
#'
nsamples <- function(object, ...) {
  UseMethod("nsamples")
}
