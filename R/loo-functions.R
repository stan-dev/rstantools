#' Generic functions for LOO predictions
#'
#' Examples of methods for these generics will appear in a future release
#' of the \pkg{\link[rstanarm]{rstanarm}} package.
#'
#' @name loo-prediction
#'
#' @template args-object
#' @template args-dots
#'
#' @return \code{loo_predict}, \code{loo_linpred}, and \code{loo_pit}
#'   (probability integral transform) methods should return a vector with length
#'   equal to the number of observations in the data.
#'   \code{loo_predictive_interval} methods should return a two-column matrix
#'   formatted in the same way as for \code{\link{predictive_interval}}.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-dev-guidelines
#'

#' @rdname loo-prediction
#' @export
loo_linpred <- function(object, ...) {
  UseMethod("loo_linpred")
}

#' @rdname loo-prediction
#' @export
loo_predict <- function(object, ...) {
  UseMethod("loo_predict")
}

#' @rdname loo-prediction
#' @export
loo_predictive_interval <- function(object, ...) {
  UseMethod("loo_predictive_interval")
}

#' @rdname loo-prediction
#' @export
loo_pit <- function(object, ...) {
  UseMethod("loo_pit")
}

#' @rdname loo-prediction
#' @export
#' @param y For the default method of \code{loo_pit}, a vector of \eqn{y} values
#'   the same length as the number of columns in the matrix used as
#'   \code{object}.
#' @param lw For the default method of \code{loo_pit}, a matrix of log-weights
#'   of the same length as the number of columns in the matrix used as
#'   \code{object}.
#'
loo_pit.default <- function(object, y, lw, ...) {
  if (!is.matrix(object))
    stop("For the default method 'object' should be a matrix.")
  stopifnot(
    is.numeric(object), is.numeric(y), length(y) == ncol(object),
    is.matrix(lw), identical(dim(lw), dim(object))
  )
  .loo_pit(y = y, yrep = object, lw = lw)
}


# internal ----------------------------------------------------------------
.loo_pit <- function(y, yrep, lw) {
  vapply(seq_len(ncol(yrep)), function(j) {
    sel <- yrep[, j] <= y[j]
    .exp_log_sum_exp(lw[sel, j])
  }, FUN.VALUE = 1)
}
.exp_log_sum_exp <- function(x) {
  m <- suppressWarnings(max(x))
  exp(m + log(sum(exp(x - m))))
}
