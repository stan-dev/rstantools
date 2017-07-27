#' Generic function and default method for Bayesian R-squared
#'
#' Generic function and default method for Bayesian version of R-squared for
#' regression models. See \code{bayes_R2.stanreg} in the
#' \pkg{\link[rstanarm]{rstanarm}} package for an example of defining a method.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @return \code{bayes_R2} methods should return a vector of length equal to the
#'   posterior sample size.
#'
#'   The default method just takes \code{object} to be a matrix of y-hat values
#'   (one column per observation, one row per posterior draw) and \code{y} to be
#'   a vector with length equal to \code{ncol(object)}.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-dev-guidelines
#'
bayes_R2 <- function(object, ...) {
  UseMethod("bayes_R2")
}

#' @rdname bayes_R2
#' @export
#' @param y For the default method, a vector of \eqn{y} values the same length
#'   as the number of columns in the matrix used as \code{object}.
#'
#' @importFrom stats var
#'
bayes_R2.default <-
  function(object, y,
           ...) {
    if (!is.matrix(object))
      stop("For the default method 'object' should be a matrix.")
    stopifnot(NCOL(y) == 1, ncol(object) == length(y))
    ypred <- object
    e <- -1 * sweep(ypred, 2, y)
    var_ypred <- apply(ypred, 1, var)
    var_e <- apply(e, 1, var)
    var_ypred / (var_ypred + var_e)
  }

