#' Generic functions for LOO predictions
#'
#' See the methods in the \pkg{rstanarm} package for examples.
#'
#' @name loo-prediction
#'
#' @template args-object
#' @template args-dots
#'
#' @return `loo_predict()`, `loo_linpred()`, and `loo_pit()`
#'   (probability integral transform) methods should return a vector with length
#'   equal to the number of observations in the data.
#'   For discrete observations, probability integral transform is randomised to
#'   ensure theoretical uniformity. Fix random seed for reproducible results 
#'   with discrete data. For more details, see Czado et al. (2009).
#'   `loo_predictive_interval()` methods should return a two-column matrix
#'   formatted in the same way as for [predictive_interval()].
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#' @template reference-randomised-pit

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
#' @param y For the default method of `loo_pit()`, a vector of `y` values the
#'   same length as the number of columns in the matrix used as `object`.
#' @param lw For the default method of `loo_pit()`, a matrix of log-weights of
#'   the same length as the number of columns in the matrix used as `object`.
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
  if (is.null(lw) || !all(is.finite(lw))) {
    stop("lw needs to be not null and finite.")
  }
  pits <- vapply(seq_len(ncol(yrep)), function(j) {
    sel_min <- yrep[, j] < y[j]
    pit <- .exp_log_sum_exp(lw[sel_min, j])
    sel_sup <- yrep[, j] == y[j]
    if (any(sel_sup)) {
      # randomized PIT for discrete y (see, e.g., Czado, C., Gneiting, T.,
      # Held, L.: Predictive model assessment for count data.
      # Biometrics 65(4), 1254–1261 (2009).)
      pit_sup <- pit + .exp_log_sum_exp(lw[sel_sup, j])
      pit <- stats::runif(1, pit, pit_sup)
    }
    pit
  }, FUN.VALUE = 1)
  if (any(pits > 1)) {
    warning(cat(
      "Some PIT values larger than 1! Largest: ",
      max(pits),
      "\nRounding PIT > 1 to 1."
    ))
  }
  pmin(1, pits)
}

.exp_log_sum_exp <- function(x) {
  m <- suppressWarnings(max(x))
  exp(m + log(sum(exp(x - m))))
}
