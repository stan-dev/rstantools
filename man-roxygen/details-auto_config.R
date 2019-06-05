#' @details When \code{auto_config = TRUE}, a \code{configure[.win]} file is
#'   added to the package, calling \code{rstantools::\link{rstan_config}}
#'   whenever the package is installed.  Consequently, the package must list
#'   \code{rstantools} in the \code{DESCRIPTION} Imports field for this
#'   mechanism to work.  Setting \code{auto_config = FALSE} removes the
#'   package's dependency on \code{rstantools}.  However, the package then must
#'   be manually configured by running \code{\link{rstan_config}} whenever
#'   \code{stanmodel} files in \code{inst/stan} are added/removed/modified.
