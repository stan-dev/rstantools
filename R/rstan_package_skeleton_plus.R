# rstan_package_skeleton
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
#' Create the skeleton of a new \R package with Stan programs
#'
#' @description
#'   \if{html}{\figure{stanlogo.png}{options: width="25px" alt="http://mc-stan.org/about/logo/"}}
#'   These functions help get you started developing
#'   \R packages that interface with Stan via the \pkg{rstan} package.  The \R package is created, several adjustments are made so that it can include Stan programs that can be built into binary versions (i.e., pre-compiled Stan C++ code).
#'
#'   See the \strong{See Also} section below for links to recommendations for
#'   developers and a step-by-step walk-through.
#'
#' @name rstan_package_skeleton
#' @aliases rstan_create_package
#' @export
#' @param path For \code{rstan_create_package}, the path to the new package to be created (terminating in the package name).  For \code{rstan_create_package}, the path in which to create the package directory.
#' @param name,list,environment,force,code_files Same as in
#'   \code{\link[utils]{utils::package.skeleton}}.
#' @param fields,rstudio,open Same as for \code{\link[usethis]{usethis::create_package}}.
#' @param stan_files A character vector with paths to \code{.stan} files to
#'   include in the package.
#' @param travis Should a \code{.travis.yml} file be added to the package
#'   directory? Defaults to \code{TRUE}.  While the file contains some presets to help with compilation issues, at present it is not guaranteed to work
#'   on \href{https://travis-ci.org/}{travis-ci} without manual adjustments.
#' @template args-license
#'
#' @details These functions first create a regular \R package using either of the \code{\link[utils]{utils::package.skeleton}} or \code{\link[usethis]{usethis::create_package}} mechanisms, then addthe folder infrastructure to compile and export \code{stanmodel} objects.  In the package root directory, the user's Stan source code is located in
#' \preformatted{
#' inst/
#'   |_stan/
#'   |   |_include/
#'   |
#'   |_include/
#' }
#' All \code{.stan} files containing instructions to build a \code{stanmodel} object must be placed in \code{inst/stan}.  Other \code{.stan} files go in any \code{stan/} subdirectory, to be invoked by Stan's \code{#include} mechanism, e.g.,
#' \preformatted{
#' #include "include/mylib.stan"
#' #include "data/preprocess.stan"
#' }
#' See \pkg{\link[rstanarm]{rstanarm}} for many examples.
#'
#' The folder \code{inst/include} is for all user C++ files associated with the Stan programs.  In this folder, the only file to directly interact with the Stan C++ library is \code{stan_meta_header.hpp}; all other \code{#include} directives must be channeled through here.
#'
#' The final step of the package creation is to invoke \code{\link{rstan_config}}, which creates the following files for interfacing Stan objects from \R:
#' \itemize{
#'   \item \code{src} contains the \code{stan_ModelName{.cc/.hpp}} pairs associated with all \code{ModelName.stan} files in \code{inst/stan} which define \code{stanmodel} objects.
#'   \item \code{src/Makevars[.win]} which link to the \code{StanHeaders} and Boost (\code{BH}) libraries.
#'   \item \code{R/stanmodels.R} loads the C++ modules containing the \code{stanmodel} class definitions, and assigns an \R instance of each \code{stanmodel} object to a \code{stanmodels} list.
#' }
#' @template details-license
#' @details Authors willing to license their Stan programs of general interest under the GPL are invited to contribute their \code{.stan} files and supporting \R code to the \pkg{\link{rstanarm}} package.
#'
#'
#'
#' @seealso
#' \itemize{
#'   \item \code{\link{use_rstan}} for adding Stan functionality to an existing \R package, \code{\link{rstan_config}} for updating an existing package when its Stan files are changed.
#'   \item \href{https://github.com/stan-dev/rstanarm}{The \pkg{rstanarm} repository on GitHub.}
#' }
#' @template seealso-dev-guidelines
#' @template seealso-get-help
#' @template seealso-useR2016-video
#'
rstan_create_package <- function(path,
                                 fields = getOption("devtools.desc"),
                                 rstudio = TRUE,
                                 open = TRUE,
                                 stan_files = character(),
                                 travis = TRUE,
                                 license = TRUE) {
  DIR <- dirname(path)
  name <- basename(path)
  # check stan extensions
  if(length(stan_files) > 0 && !all(grepl("\\.stan$", stan_files))) {
    stop("All files named in 'stan_files' must end ",
         "with a '.stan' extension.")
  }
  # check rstudio dependency
  if(rstudio && !requireNamespace("rstudioapi", quietly = TRUE)) {
    stop("Please install 'rstudioapi' for option 'rstudio = TRUE'.")
    rstudio <- rstudio && rstudioapi::isAvailable()
  }
  if (open && rstudio) {
    on.exit(rstudioapi::openProject(DIR, newSession = TRUE))
  }
  # run package skeleton
  if (file.exists(path)) {
    stop("Directory '", DIR, "' already exists.")
  }
  message("Creating package skeleton for package: ", name, domain = NA)
  suppressMessages(usethis::create_package(path = path, fields = fields,
                                           rstudio = rstudio, open = FALSE))
  pkgdir <- .check_pkgdir(file.path(DIR, name)) # package folder
  # add rest of stan functionality to package
  .rstan_make_pkg(pkgdir, stan_files, travis, license)
  invisible(NULL)
}

#' @rdname rstan_package_skeleton
#' @export
rstan_package_skeleton <- function(name = "anRpackage",
                                   list = character(),
                                   environment = .GlobalEnv,
                                   path = ".",
                                   force = FALSE,
                                   code_files = character(),
                                   stan_files = character(),
                                   travis = TRUE, license = TRUE) {
  # check stan extensions
  if(length(stan_files) > 0 && !all(grepl("\\.stan$", stan_files))) {
    stop("All files named in 'stan_files' must end ",
         "with a '.stan' extension.")
  }
  # run package skeleton
  message("Creating package skeleton for package: ", name, domain = NA)
  mc <- match.call()
  mc[[1]] <- quote(utils::package.skeleton)
  env <- parent.frame(1)
  mc <- mc[c(1, which(names(mc) %in% names(formals(utils::package.skeleton))))]
  ## mc$stan_files <- NULL
  ## mc$travis <- NULL
  ## mc$license <- NULL
  ## mc[[1]] <- quote(utils::package.skeleton)
  suppressMessages(eval(mc, envir = env))
  ## suppressMessages(utils::package.skeleton(name = name, list = list,
  ##                                          environment = environment,
  ##                                          path = path, force = force,
  ##                                          code_files = code_files))
  pkgdir <- .check_pkgdir(file.path(path, name)) # package folder
  # remove all man files
  # (so package can be installed immediately after running package_skeleton)
  file.remove(list.files(file.path(pkgdir, "man"), full.names = TRUE))
  .rstan_make_pkg(pkgdir, stan_files, travis, license)
  invisible(NULL)
}

#--- helper functions ----------------------------------------------------------

# add travis file
.add_travis <- function(pkgdir) {
  travis_file <- readLines(.system_file(".travis.yml"))
  .add_stanfile(gsub("RSTAN_PACKAGE_NAME", basename(pkgdir), travis_file),
                pkgdir, ".travis.yml",
                noedit = FALSE, msg = TRUE, warn = FALSE)
  # also create an .Rbuildignore for travis file
  .add_stanfile("^\\.travis\\.yml$", pkgdir, ".Rbuildignore",
                noedit = FALSE)
}

# add stan functionality to package
.rstan_make_pkg <- function(pkgdir, stan_files, travis, license) {
  # add travis file
  if(travis) .add_travis(pkgdir)
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
