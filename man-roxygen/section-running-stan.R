#' @section Using the pre-compiled Stan programs in your package:
#'   The \code{stanmodel} objects corresponding to the Stan programs
#'   included with your package are stored in a list called \code{stanmodels}.
#'   To run one of the Stan programs from within an R function in your package
#'   just pass the appropriate element of the \code{stanmodels} list to one of
#'   the \pkg{rstan} functions for model fitting (e.g., \code{sampling}). For
#'   example, for a Stan program "foo.stan" you would use
#'   \code{rstan::sampling(stanmodels$foo, ...)}.
