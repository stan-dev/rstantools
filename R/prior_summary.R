#' Generic function for extracting information about prior distributions
#'
#' See [prior_summary.stanreg()](https://mc-stan.org/rstanarm/reference/prior_summary.stanreg.html)
#' in the \pkg{rstanarm} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @return `prior_summary()` methods should return an object containing
#'   information about the prior distribution(s) used for the given model.
#'   The structure of this object will depend on the method.
#'
#'   The default method just returns `object$prior.info`, which is
#'   `NULL` if there is no `'prior.info'` element.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-vignettes
#'
#' @examples
#' # See help("prior_summary", package = "rstanarm")
#'
prior_summary <- function(object, ...) {
  UseMethod("prior_summary")
}

#' @rdname prior_summary
#' @export
prior_summary.default <- function(object, ...) {
  object$prior.info
}
