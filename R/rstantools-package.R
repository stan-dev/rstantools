#' Tools for Developing \R Packages Interfacing with Stan
#'
#' @name rstantools-package
#' @aliases rstantools
#'
#' @description
#' \if{html}{
#'   \figure{stanlogo.png}{options: width="50" alt="mc-stan.org"}
#' } *Stan Development Team*
#'
#' The \pkg{rstantools} package provides various tools for developers of \R
#' packages interfacing with Stan (<https://mc-stan.org>), including
#' functions to set up the required package structure, S3 generic methods to
#' unify function naming across Stan-based \R packages, and vignettes with
#' guidelines for developers. To get started building a package see
#' [rstan_create_package()].
#'
#' @template seealso-vignettes
#' @template seealso-get-help
#'
#' @importFrom RcppParallel RcppParallelLibs
#'
"_PACKAGE"


# internal ----------------------------------------------------------------

# release reminders (for devtools)
release_questions <- function() { # nocov start
  c(
    "Have you updated the developer guidelines in the vignette?"
  )
} # nocov end
