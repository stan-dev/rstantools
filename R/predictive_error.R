#' Generic function and default method for predictive errors
#'
#' Generic function and default method for computing predictive errors
#' \eqn{y - y^{rep}}{y - yrep} (in-sample, for observed \eqn{y}) or
#' \eqn{y - \tilde{y}}{y - ytilde} (out-of-sample, for new or held-out \eqn{y}).
#' See [predictive_error.stanreg()](https://mc-stan.org/rstanarm/reference/predictive_error.stanreg.html)
#' in the \pkg{rstanarm} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @return `predictive_error()` methods should return a \eqn{D} by \eqn{N}
#'   matrix, where \eqn{D} is the number of draws from the posterior predictive
#'   distribution and \eqn{N} is the number of data points being predicted per
#'   draw.
#'
#'   The default method just takes `object` to be a matrix and `y` to be a
#'   vector.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#'
#' @examples
#' # default method
#' y <- rnorm(10)
#' ypred <- matrix(rnorm(500), 50, 10)
#' pred_errors <- predictive_error(ypred, y)
#' dim(pred_errors)
#' head(pred_errors)
#'
#' # Also see help("predictive_error", package = "rstanarm")
#'
predictive_error <- function(object, ...) {
  UseMethod("predictive_error")
}

#' @rdname predictive_error
#' @export
#' @param y For the default method, a vector of `y` values the same length as
#'   the number of columns in the matrix used as `object`.
predictive_error.default <- function(object, y, ...) {
  if (!is.matrix(object))
    stop("For the default method 'object' should be a matrix.")
  .pred_errors(object, y)
}


# internal ----------------------------------------------------------------

# @param object A matrix
# @param y A vector the same length as ncol(object)
.pred_errors <- function(object, y) {
  stopifnot(is.matrix(object), length(y) == ncol(object))
  sweep(-1 * object, MARGIN = 2, STATS = as.array(y), FUN = "+")
}
