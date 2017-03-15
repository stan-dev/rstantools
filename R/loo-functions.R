#' Generic functions for LOO predictions
#'
#' Examples of methods for these generics will appear in a future release
#' of the \pkg{rstanarm} package.
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
