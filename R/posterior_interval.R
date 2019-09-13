#' Generic function and default method for posterior uncertainty intervals
#'
#' These intervals are often referred to as credible intervals, but we use the
#' term uncertainty intervals to highlight the fact that wider intervals
#' correspond to greater uncertainty. See
#' [posterior_interval.stanreg()](https://mc-stan.org/rstanarm/reference/posterior_interval.stanreg.html)
#' in the \pkg{rstanarm} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @param prob A number \eqn{p \in (0,1)}{p (0 < p < 1)} indicating the desired
#'   probability mass to include in the intervals.
#'
#' @return `posterior_interval()` methods should return a matrix with two
#'   columns and as many rows as model parameters (or a subset of parameters
#'   specified by the user). For a given value of `prob`, \eqn{p}, the
#'   columns correspond to the lower and upper \eqn{100p}\% interval limits and
#'   have the names \eqn{100\alpha/2}\% and \eqn{100(1 - \alpha/2)}\%, where
#'   \eqn{\alpha = 1-p}. For example, if `prob=0.9` is specified (a
#'   \eqn{90}\% interval), then the column names would be `"5%"` and
#'   `"95%"`, respectively.
#'
#'   The default method just takes `object` to be a matrix (one column per
#'   parameter) and computes quantiles, with `prob` defaulting to `0.9`.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#'
#' @examples
#' # Default method takes a numeric matrix (of posterior draws)
#' draws <- matrix(rnorm(100 * 5), 100, 5) # fake draws
#' colnames(draws) <- paste0("theta_", 1:5)
#' posterior_interval(draws)
#'
#' # Also see help("posterior_interval", package = "rstanarm")
#'
posterior_interval <- function(object, ...) {
  UseMethod("posterior_interval")
}

#' @rdname posterior_interval
#' @export
posterior_interval.default <- function(object, prob = 0.9, ...) {
  if (!is.matrix(object))
    stop("For the default method 'object' should be a matrix.")
  .central_intervals(object, prob)
}
