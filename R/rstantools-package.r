#' Tools for Developing \R Packages Interfacing with Stan
#'
#' @name rstantools
#' @docType package
#'
#' @description
#' \if{html}{
#'   \figure{stanlogo.png}{options: width="50px" alt="mc-stan.org"}
#'   \emph{Stan Development Team}
#' }
#'
#' The \pkg{rstantools} package provides various tools for developers of \R
#' packages interfacing with Stan (\url{http://mc-stan.org}), including
#' functions to set up the required package structure, S3 generic methods to
#' unify function naming across Stan-based \R packages, and a vignette with
#' guidelines for developers. To get started building a package see
#' \code{\link{rstan_package_skeleton}}.
#'
#' @template seealso-dev-guidelines
#' @template seealso-get-help
#'
NULL


# internal ----------------------------------------------------------------

# release reminders (for devtools)
release_questions <- function() { # nocov start
  c(
    "Have you updated the developer guidelines in the vignette?"
  )
} # nocov end
