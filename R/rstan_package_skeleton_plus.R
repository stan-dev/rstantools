# rstan_package_skeleton_plus
# Copyright (C) 2018 Martin Lysy
#
# rstantools is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# rstantools is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#' Create a skeleton for a new \R package with Stan programs
#'
#' This function is very similar to \code{\link[utils]{package.skeleton}} but is
#' designed for source packages that want to include Stan Programs that can be
#' built into binary versions.
#'
#' @export
#' @param name,list,environment,path,force,code_files Same as in
#'   \code{\link[utils]{package.skeleton}}.
#' @param stan_files A character vector with paths to \code{.stan} files to
#'   include in the package. Otherwise similar to \code{code_files}.
#' @param travis Should a \code{.travis.yml} file be added to the package
#'   directory? Defaults to \code{TRUE}.
#' @template args-license
#'
#' @details This function first calls \code{\link[utils]{package.skeleton}}, then adds the folder infrastructure to compile and export \code{stanmodel} objects.  In the package root directory, the user's Stan source code is located in
#' \preformatted{
#' inst/
#'   |_stan/
#'   |   |_include/
#'   |
#'   |_include/
#' }
#' All \code{.stan} files containing instructions to build a \code{stanmodel} object must be placed in \code{inst/stan}.  Other \code{.stan} files go in any \code{stan/} subdirectory, to be invoked by Stan's include mechanism, e.g.,
#' \preformatted{
#' #include "include/mylib.stan"
#' #include "data/preprocess.stan"
#' }
#' See \pkg{\link[rstanarm]{rstanarm}} for many examples.
#'
#' The folder \code{inst/include} is for all user C++ files associated with Stan program.  In this folder, the only file to directly interact with the Stan C++ library is \code{stan_meta_header.hpp}; all other \code{#include} directives must be channeled through here.
#'
#' The final step of \code{rstan_package_skeleton} is to invoke \code{\link{rstan_config}}, which creates the following files for interfacing Stan objects from \R:
#' \itemize{
#'   \item \code{src} contains the \code{stan_ModelName{.cc/.hpp}} pairs associated with all \code{ModelName.stan} files in \code{inst/stan} which define \code{stanmodel} objects.
#'   \item \code{src/Makevars[.win]} which link to the \code{StanHeaders} and Boost (\code{BH}) libraries..
#'   \item \code{R/stanmodels.R} loads the C++ modules containing the \code{stanmodel} class definitions, and assigns an \R instance of each \code{stanmodel} object to a \code{stanmodels} list.
#' }
#'
#' @template seealso-get-help
#'
rstan_package_skeleton_plus <- function(name = "anRpackage",
                                        list = character(),
                                        environment = .GlobalEnv,
                                        path = ".",
                                        force = FALSE,
                                        code_files = character(),
                                        stan_files = character(),
                                        travis = TRUE, license = TRUE) {
  # check R version
  # nocov start
  if (R.version[["major"]] < 3 || R.version[["minor"]] < 2.2) {
    stop("rstan_package_skeleton_plus requires R >= 3.2.2.")
  }
  # nocov end
  # check stan extensions
  if(length(stan_files) > 0 && !all(grepl("\\.stan$", stan_files))) {
    stop("All files named in 'stan_files' must end ",
         "with a '.stan' extension.")
  }
  # run package skeleton
  mc <- match.call()
  mc$stan_files <- NULL
  mc$travis <- NULL
  mc$license <- NULL
  mc[[1]] <- quote(utils::package.skeleton)
  message("Running package.skeleton ...", domain = NA)
  suppressMessages(eval(mc))
  pkgdir <- .check_pkgdir(file.path(path, name)) # package folder
  # remove all man files
  # (so package can be installed immediately after running package_skeleton)
  file.remove(list.files(file.path(pkgdir, "man"), full.names = TRUE))
  ## man_files <- list.files(file.path(pkgdir, "man"), full.names = TRUE)
  ## man_files <- man_files[basename(man_files) != paste0(basename(pkgdir),
  ##                                                      "-package.Rd")]
  ## file.remove(man_files)
  # add stan compile + export functionality
  # add travis file
  if(travis) {
    travis_file <- readLines(.system_file(".travis.yml"))
    .add_stanfile(gsub("RSTAN_PACKAGE_NAME", basename(pkgdir), travis_file),
                  pkgdir, ".travis.yml",
                  noedit = FALSE, msg = TRUE, warn = FALSE)
    # also create an .Rbuildignore for travis file
    .add_stanfile("^\\.travis\\.yml$", pkgdir, ".Rbuildignore",
                  noedit = FALSE)
  }
  ## if(length(stan_files) > 0) {
  ##   # add useDynlib to namespace
  ##   message("Adding import(Rcpp, methods) and useDynLib to NAMESPACE ...")
  ##   cat("import(Rcpp, methods)",
  ##       paste0("useDynLib(", basename(pkgdir), ", .registration = TRUE)"),
  ##       file = file.path(pkgdir, "NAMESPACE"),
  ##       sep = "\n", append = TRUE)
  ## }
  # add stan folder structure
  use_rstan(pkgdir, license = license)
  # add user's stan files
  file.copy(from = stan_files,
            to = file.path(pkgdir, "inst", "stan", basename(stan_files)))
  # add stan system files for compiling
  message("Configuring Stan compile and module export instructions ...")
  rstan_config(pkgdir)
  # add instructions to Read-and-delete-me
  cat(readLines(.system_file("Read-and-delete-me")), "\n",
      file = file.path(pkgdir, "Read-and-delete-me"),
      sep = "\n", append = TRUE)
  message(domain = NA,
          sprintf("Further Stan-specific steps are described in '%s'.",
                  file.path(basename(pkgdir), "Read-and-delete-me")))
  invisible(NULL)
}

#-------------------------------------------------------------------------------

## outline of steps:

## 1. run package skeleton.
##    - rm man files

## 2. create stan_dirs.
##    - inst/stan
##    - inst/stan/include
##    - inst/include
##    - src/stan_files
##    - if(!exists) message

## 3. add default files.
##    - src/stan_init.cpp
##    - inst/include/stan_meta_header.cpp

## 4. update NAMESPACE
##    - if(default) modify else message(remaining steps)

## 5. update DESCRIPTION
##    - if(modified) message else do_nothing

## 4. add stan_files

## 5. configure build
##    - make src/stan_files/*.{cc/hpp}
##      only overwrite if different
##    - add src/Makevars[.win]
##      only overwrite if different
##    - add R/stanmodels.R
##    - if(is_empty(inst/stan)) no Makevars, empty stanmodels.R

## messages:
##   - when creating directories
##   - when updating DESCRIPTION or NAMESPACE
##   - when adding files? sometimes

## warnings:
##   - when attempting to overwrite non-stan file with stan file of same name

## error:
##   - when {dir/file}.create fails even though it doesn't exist


## ok stan_meta_header.hpp is problematic, because want to warn if already exists, but only if it's there from before...

## so .add_stanfile(file_lines, pkgdir, ...,
##                  noedit = TRUE, msg = FALSE, warn = TRUE)
