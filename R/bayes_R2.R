#' Generic function and default method for Bayesian R-squared
#'
#' Generic function and default method for Bayesian version of R-squared for
#' regression models. A generic for LOO-adjusted R-squared is also provided. See
#' the [bayes_R2.stanreg()](https://mc-stan.org/rstanarm/reference/bayes_R2.stanreg.html)
#' method in the \pkg{rstanarm} package for an example of defining a method.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @return `bayes_R2()` and `loo_R2()` methods should return a vector of
#'   length equal to the posterior sample size.
#'
#'   The default `bayes_R2()` method just takes `object` to be a matrix of y-hat
#'   values (one column per observation, one row per posterior draw) and `y` to
#'   be a vector with length equal to `ncol(object)`.
#'
#'
#' @references
#' Andrew Gelman, Ben Goodrich, Jonah Gabry, and Aki Vehtari (2018). R-squared
#' for Bayesian regression models. *The American Statistician*, to appear.
#' DOI: 10.1080/00031305.2018.1549100.
#' ([Preprint](http://www.stat.columbia.edu/~gelman/research/published/bayes_R2_v3.pdf),
#' [Notebook](https://avehtari.github.io/bayes_R2/bayes_R2.html))
#'
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#'
bayes_R2 <- function(object, ...) {
  UseMethod("bayes_R2")
}

#' @rdname bayes_R2
#' @export
#' @param y For the default method, a vector of `y` values the same length
#'   as the number of columns in the matrix used as `object`.
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


#' @rdname bayes_R2
#' @export
loo_R2 <- function(object, ...) {
  UseMethod("loo_R2")
}
