# Part of the rstantools package
# Copyright (C) 2018, 2019 Martin Lysy
# Copyright (C) 2019 Trustees of Columbia University
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
#' Create a new \R package with compiled Stan programs
#'
#' @aliases rstan_package_skeleton
#'
#' @description
#'   \if{html}{\figure{stanlogo.png}{options: width="25px" alt="https://mc-stan.org/about/logo/"}}
#'   The `rstan_create_package()` function helps get you started developing a
#'   new \R package that interfaces with Stan via the \pkg{rstan} package. First
#'   the basic package structure is set up via [usethis::create_package()].
#'   Then several adjustments are made so the package can include Stan programs
#'   that can be built into binary versions (i.e., pre-compiled Stan C++ code).
#'
#'   The **Details** section below describes the process and the
#'   **See Also** section provides links to recommendations for developers
#'   and a step-by-step walk-through.
#'
#'   As of version `2.0.0` of \pkg{rstantools} the
#'   `rstan_package_skeleton()` function is defunct and only
#'   `rstan_create_package()` is supported.
#'
#' @export
#' @param path The path to the new package to be created (terminating in the
#'   package name).
#' @param fields,rstudio,open Same as [usethis::create_package()]. See
#'   the documentation for that function, especially the note in the
#'   **Description** section about the side effect of changing the active
#'   project.
#' @param stan_files A character vector with paths to `.stan` files to include
#'   in the package.
#' @param roxygen Should \pkg{roxygen2} be used for documentation?  Defaults to
#'   `TRUE`. If so, a file `R/{pkgname}-package.R`` is added to the package with
#'   roxygen tags for the required import lines. See the **Note** section below
#'   for advice specific to the latest versions of \pkg{roxygen2}.
#' @param travis Should a `.travis.yml` file be added to the package directory?
#'   Defaults to `TRUE`.  While the file contains some presets to help with
#'   compilation issues, at present it is not guaranteed to work on
#'   [travis-ci](https://travis-ci.org/) without manual adjustments.
#' @template args-license
#' @template args-auto_config
#'
#' @details
#' This function first creates a regular \R package using
#' `usethis::create_package()`, then adds the infrastructure required to compile
#' and export `stanmodel` objects. In the package root directory, the user's
#' Stan source code is located in:
#' \preformatted{
#' inst/
#'   |_stan/
#'   |   |_include/
#'   |
#'   |_include/
#' }
#' All `.stan` files containing instructions to build a `stanmodel`
#' object must be placed in `inst/stan`.  Other `.stan` files go in
#' any `stan/` subdirectory, to be invoked by Stan's `#include`
#' mechanism, e.g.,
#' \preformatted{
#' #include "include/mylib.stan"
#' #include "data/preprocess.stan"
#' }
#' See \pkg{rstanarm} for many examples.
#'
#' The folder `inst/include` is for all user C++ files associated with the
#' Stan programs.  In this folder, the only file to directly interact with the
#' Stan C++ library is `stan_meta_header.hpp`; all other `#include`
#' directives must be channeled through here.
#'
#' The final step of the package creation is to invoke
#' [rstan_config()], which creates the following files for
#' interfacing with Stan objects from \R:
#' \itemize{
#'   \item `src` contains the `stan_ModelName{.cc/.hpp}` pairs
#'   associated with all `ModelName.stan` files in `inst/stan` which
#'   define `stanmodel` objects.
#'   \item `src/Makevars[.win]` which link to the `StanHeaders` and
#'   Boost (`BH`) libraries.
#'   \item `R/stanmodels.R` loads the C++ modules containing the
#'   `stanmodel` class definitions, and assigns an \R instance of each
#'   `stanmodel` object to a `stanmodels` list (with names
#'   corresponding to the names of the Stan files).
#' }
#' @template details-auto_config
#' @template details-license
#' @details Authors willing to license their Stan programs of general interest
#'   under the GPL are invited to contribute their `.stan` files and
#'   supporting \R code to the \pkg{rstanarm} package.
#'
#' @template section-running-stan
#'
#' @note For \pkg{devtools} users, because of changes in the latest versions of
#'   \pkg{roxygen2} it may be necessary to run `pkgbuild::compile_dll()`
#'   once before `devtools::document()` will work.
#'
#' @seealso
#' * [use_rstan()] for adding Stan functionality to an existing
#'   \R package and [rstan_config()] for updating an existing package
#'   when its Stan files are changed.
#' * The \pkg{rstanarm} package [repository](https://github.com/stan-dev/rstanarm)
#'   on GitHub.
#' @template seealso-vignettes
#' @template seealso-get-help
#' @template seealso-useR2016-video
#'
rstan_create_package <- function(path,
                                 fields = NULL,
                                 rstudio = TRUE,
                                 open = TRUE,
                                 stan_files = character(),
                                 roxygen = TRUE,
                                 travis = TRUE,
                                 license = TRUE,
                                 auto_config = TRUE) {
  if (!requireNamespace("usethis", quietly = TRUE)) {
    stop("Please install package 'usethis' to use function 'rstan_create_package'.",
         call. = FALSE)
  }
  DIR <- dirname(path)
  name <- basename(path)
  .check_stan_ext(stan_files)

  if (rstudio && !requireNamespace("rstudioapi", quietly = TRUE)) {
    stop("Please install package 'rstudioapi' to use option 'rstudio = TRUE'.",
         call. = FALSE)
    rstudio <- rstudio && rstudioapi::isAvailable()
  }
  if (open && rstudio) {
    on.exit(rstudioapi::openProject(file.path(DIR, name), newSession = TRUE))
  }

  # run usethis::create_package()
  if (file.exists(path)) {
    stop("Directory '", path, "' already exists.", call. = FALSE)
  }
  message("Creating package skeleton for package: ", name, domain = NA)
  suppressMessages(
    usethis::create_package(
      path = path,
      fields = fields,
      rstudio = rstudio,
      open = FALSE
    )
  )

  # add Stan-specific functionality to the new package
  pkgdir <- .check_pkgdir(file.path(DIR, name))
  .rstan_make_pkg(pkgdir, stan_files, roxygen, travis, license, auto_config)
  invisible(NULL)
}

#--- helper functions ----------------------------------------------------------

# check stan extensions
.check_stan_ext <- function(stan_files) {
  if (length(stan_files) && !all(grepl("\\.stan$", stan_files))) {
    stop("All files named in 'stan_files' must end ",
         "with a '.stan' extension.", call. = FALSE)
  }
}

# add travis file
.add_travis <- function(pkgdir) {
  travis_file <- readLines(.system_file("travis.yml"))
  .add_stanfile(gsub("RSTAN_PACKAGE_NAME", basename(pkgdir), travis_file),
                pkgdir, ".travis.yml",
                noedit = FALSE, msg = TRUE, warn = FALSE)
}

# add .gitignore and .Rbuildignore files
.add_gitignore_Rbuildignore <- function(pkgdir, travis) {
  gitignore_files <- c("^rcppExports.cpp$", "^stanExports_*")
  .add_stanfile(gitignore_files, pkgdir, ".gitignore",
                noedit = FALSE, msg = TRUE, warn = FALSE)

  Rbuildignore_files <- c(gitignore_files, if (travis) "^\\.travis\\.yml$")
  .add_stanfile(Rbuildignore_files, pkgdir, ".Rbuildignore",
                noedit = FALSE, msg = TRUE, warn = FALSE)
}

# add R/mypkg-package.R file with roxygen import comments
# also add Encoding: UTF-8 to DESCRIPTION
.add_roxygen <- function(pkgdir) {
  pkg_file <- readLines(.system_file("rstanpkg-package.R"))
  pkg_file <- gsub("RSTAN_PACKAGE_NAME", basename(pkgdir), pkg_file)
  pkg_file <- gsub("RSTAN_REFERENCE", .rstan_reference(), pkg_file)
  .add_stanfile(pkg_file, pkgdir,
                "R", paste0(basename(pkgdir), "-package.R"),
                noedit = FALSE, msg = TRUE, warn = FALSE)
  desc_pkg <- desc::description$new(file.path(pkgdir, "DESCRIPTION"))
  desc_pkg$set(Encoding = "UTF-8")
  desc_pkg$write()
}

# reference to rstan package
.rstan_reference <- function() {
  has_version <- utils::packageDescription("rstan", fields = "Version")
  version_year <- substr(utils::packageDescription("rstan", fields = "Date"), 1, 4)
  paste0(
    "Stan Development Team (", version_year,"). ",
    "RStan: the R interface to Stan. ",
    "R package version ", has_version, ". ",
    "https://mc-stan.org"
  )
}

# add stan functionality to package
.rstan_make_pkg <- function(pkgdir, stan_files,
                            roxygen, travis, license, auto_config) {

  use_rstan(pkgdir, license = license, auto_config = auto_config)
  file.copy(
    from = stan_files,
    to = file.path(pkgdir, "inst", "stan", basename(stan_files))
  )
  if (roxygen) .add_roxygen(pkgdir)
  if (travis) .add_travis(pkgdir)
  .add_gitignore_Rbuildignore(pkgdir, travis)

  message("Configuring Stan compile and module export instructions ...")
  rstan_config(pkgdir)

  # open = "at" implies text is appended
  con <- file(file.path(pkgdir, "Read-and-delete-me"), open = "at")
  writeLines(readLines(.system_file("Read_and_delete_me")), con)
  close(con)

  message(
    domain = NA,
    sprintf(
      "Further Stan-specific steps are described in '%s'.",
      file.path(basename(pkgdir), "Read-and-delete-me")
    )
  )
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
##    - if (!exists) message

## 3. add default files.
##    - src/stan_init.cpp
##    - inst/include/stan_meta_header.cpp

## 4. update NAMESPACE
##    - if (default) modify else message(remaining steps)

## 5. update DESCRIPTION
##    - if (modified) message else do_nothing

## 4. add stan_files

## 5. configure build
##    - make src/stan_files/*.{cc/hpp}
##      only overwrite if different
##    - add src/Makevars[.win]
##      only overwrite if different
##    - add R/stanmodels.R
##    - if (is_empty(inst/stan)) no Makevars, empty stanmodels.R

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
