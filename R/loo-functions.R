#' Generic functions for LOO predictions
#'
#' See \code{loo_predict.stanreg} in the \pkg{rstanarm} package for an
#' example.
#'
#' @name LOO-prediction
#'
#' @template args-object
#' @template args-dots
#'
#' @return
#' \code{loo_predict} and \code{loo_linpred} methods should return a vector
#' and \code{loo_predictive_interval} methods should return a two-column
#' matrix similar to \code{\link{predictive_interval}}.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-dev-guidelines
#'
#' @examples
#' # Default method takes a numeric matrix (of draws from posterior
#' # predictive distribution)
#' ytilde <- matrix(rnorm(100 * 5, sd = 2), 100, 5) # fake draws
#' predictive_interval(ytilde, prob = 0.8)
#'
#' # Also see help("predictive_interval", package = "rstanarm")
#'

#' @rdname LOO-prediction
#' @export
loo_predict <- function(object, ...) {
  UseMethod("loo_predict")
}

#' @rdname LOO-prediction
#' @export
loo_linpred <- function(object, ...) {
  UseMethod("loo_linpred")
}

#' @rdname LOO-prediction
#' @export
loo_predictive_interval <- function(object, ...) {
  UseMethod("loo_predictive_interval")
}
