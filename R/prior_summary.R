#' Generic function for extracting information about prior distributions
#'
#' See \code{\link[rstanarm]{prior_summary.stanreg}} in the
#' \pkg{\link[rstanarm]{rstanarm}} package for an example.
#'
#' @export
#' @template args-object
#' @template args-dots
#'
#' @return \code{prior_summary} methods should return an object containing
#'   information about the prior distribution(s) used for the given model.
#'   The structure of this object will depend on the method.
#'
#'   The default method just returns \code{object$prior.info}, which is
#'   \code{NULL} if there is no \code{'prior.info'} element.
#'
#' @template seealso-rstanarm-pkg
#' @template seealso-dev-guidelines
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
