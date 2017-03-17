#' Generic function for predictive intervals
#'
#' See \code{\link[rstanarm]{predictive_interval.stanreg}} in the
#' \pkg{\link[rstanarm]{rstanarm}} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#' @param prob A number \eqn{p \in (0,1)}{p (0 < p < 1)} indicating the desired
#'   probability mass to include in the intervals.
#'
#' @return \code{predictive_interval} methods should return a matrix with two
#'   columns and as many rows as data points being predicted. For a given value
#'   of \code{prob}, \eqn{p}, the columns correspond to the lower and upper
#'   \eqn{100p}\% interval limits and have the names \eqn{100\alpha/2}\% and
#'   \eqn{100(1 - \alpha/2)}\%, where \eqn{\alpha = 1-p}. For example, if
#'   \code{prob=0.9} is specified (a \eqn{90}\% interval), then the column names
#'   would be \code{"5\%"} and \code{"95\%"}, respectively.
#'
#'   The default method just takes \code{object} to be a matrix and computes
#'   quantiles, with \code{prob} defaulting to 0.9.
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
predictive_interval <- function(object, ...) {
  UseMethod("predictive_interval")
}

#' @rdname predictive_interval
#' @export
predictive_interval.default <- function(object, prob = 0.9, ...) {
  if (!is.matrix(object))
    stop("For the default method 'object' should be a matrix.")
  .central_intervals(object, prob)
}


# internal ----------------------------------------------------------------

# Compute central intervals
#
#' @importFrom stats quantile
#
# @param object A numeric matrix
# @param prob Probability mass to include in intervals (in (0,1))
# @return See @return above.
#
.central_intervals <- function(object, prob) {
  stopifnot(is.matrix(object))
  if (length(prob) != 1L || prob <= 0 || prob >= 1)
    stop("'prob' should be a single number greater than 0 and less than 1.",
         call. = FALSE)
  alpha <- (1 - prob) / 2
  probs <- c(alpha, 1 - alpha)
  labs <- paste0(100 * probs, "%")
  out <- t(apply(object, 2, quantile, probs = probs))
  structure(out, dimnames = list(colnames(object), labs))
}
