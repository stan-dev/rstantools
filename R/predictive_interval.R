#' Generic function for computing predictive intervals
#'
#' These intervals are often referred to as credible intervals, but we use the
#' term uncertainty intervals to highlight the fact that wider intervals
#' correspond to greater uncertainty. See
#' \code{\link[rstanarm]{posterior_interval.stanreg}} in the
#' \pkg{\link{rstanarm}} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @param prob A number \eqn{p \in (0,1)}{p (0 < p < 1)} indicating the desired
#'   probability mass to include in the intervals. The default is to report
#'   \eqn{90}\% intervals (\code{prob=0.9}) rather than the traditionally used
#'   \eqn{95}\% (see Details).
#'
#' @return \code{predictive_interval} methods should return a matrix with two
#'   columns and as many rows as data points being predicted. For a given value
#'   of \code{prob}, \eqn{p}, the columns correspond to the lower and upper
#'   \eqn{100p}\% interval limits and have the names \eqn{100\alpha/2}\% and
#'   \eqn{100(1 - \alpha/2)}\%, where \eqn{\alpha = 1-p}. For example, if
#'   \code{prob=0.9} is specified (a \eqn{90}\% interval), then the column names
#'   would be \code{"5\%"} and \code{"95\%"}, respectively.
#'
#'   The default method just takes \code{object} to be a vector or matrix and
#'   computes quantiles.
#'
#'
predictive_interval <- function(object, ...) {
  UseMethod("predictive_interval")
}

#' @rdname predictive_interval
#' @export
predictive_interval.default <- function(object, prob = 0.9, ...) {
  central_intervals(object, prob)
}


# internal ----------------------------------------------------------------
central_intervals <- function(x, prob) {
  if (!identical(length(prob), 1L) || prob <= 0 || prob >= 1)
    stop("'prob' should be a single number greater than 0 and less than 1.",
         call. = FALSE)
  alpha <- (1 - prob) / 2
  probs <- c(alpha, 1 - alpha)
  labs <- paste0(100 * probs, "%")
  out <- t(apply(x, 2L, quantile, probs = probs))
  structure(out, dimnames = list(colnames(x), labs))
}

