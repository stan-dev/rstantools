# This file is part of rstantools
# Copyright (C) 2015, 2016, 2017 Trustees of Columbia University
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
#'   The \code{rstan_package_skeleton} function helps get you started developing
#'   \R packages that interface with Stan via the \pkg{rstan} package. As of
#'   \pkg{rstantools} v1.5.0, \code{rstan_package_skeleton} calls
#'   \code{usethis::create_package} (instead of \code{utils::package.skeleton})
#'   and then makes necessary adjustments so that the package can include Stan
#'   Programs that can be built into binary versions (i.e., pre-compiled like
#'   \pkg{rstanarm}).
#'
#'   See the \strong{See Also} section below for links to recommendations for
#'   developers and a step by step walk-through of what to do after running
#'   \code{rstan_package_skeleton}.
#'
#' @export
#' @param path A relative or absolute path to the new package to be created
#'   (terminating in the package name).
#' @param fields,rstudio,open See \code{usethis::create_package}.
#' @param stan_files A character vector with paths to \code{.stan} files to
#'   include in the package (these files will be included in the
#'   \code{src/stan_files} directory). If not specified then the \code{.stan}
#'   files for the package can be manually placed into the appropriate directory
#'   later.
#' @param travis Should a \code{.travis.yml} file be added to the package
#'   directory? Defaults to \code{TRUE}. The file has some settings already set
#'   to help with compilation issues, but we do not guarantee that it will work
#'   on \href{https://travis-ci.org/}{travis-ci} without manual adjustments.
#'
#' @note This function downloads several files from \pkg{rstanarm} package's
#'   \href{http://github.com/stan-dev/rstanarm}{GitHub repository} to facilitate
#'   building the resulting package. Note that \pkg{\link[rstanarm]{rstanarm}}
#'   is licensed under the GPL >= 3, so package builders who do not want to be
#'   governed by that license should not use the downloaded files that contain
#'   \R code (that said, \pkg{Rcpp} is GPL, so not using the \pkg{rstanarm}
#'   files is not the only thing impeding use of other licenses). Otherwise, it
#'   may be worth considering whether it would be easier to include your
#'   \code{.stan} programs and supporting \R code in the \pkg{rstanarm} package.
#'
#' @seealso
#' \itemize{
#'   \item \href{https://github.com/stan-dev/rstanarm}{The \pkg{rstanarm} repository on GitHub.}
#' }
#' @template seealso-dev-guidelines
#' @template seealso-get-help
#' @template seealso-useR2016-video
#'
#' @importFrom utils download.file packageVersion available.packages
#'
#'
rstan_package_skeleton <-
  function(path,
           fields = getOption("devtools.desc"),
           rstudio = TRUE,
           open = TRUE,
           stan_files = character(),
           travis = TRUE) {

    if (!requireNamespace("usethis", quietly = TRUE)) {
      stop("Please install the 'usethis' package to use this function.")
    }
    if (!requireNamespace("rstudioapi", quietly = TRUE)) {
      stop("Please install the 'rstudioapi' package to use this function.")
    }
    if (!requireNamespace("roxygen2", quietly = TRUE)) {
      stop("Please install the 'roxygen2' package to use this function.")
    }

    rstudio <- rstudio && rstudioapi::isAvailable()
    if (file.exists(path)) {
      stop("Directory ", normalizePath(path), " already exists.")
    }
    name <- basename(path)
    message("Creating package skeleton for package: ", name, domain = NA)

    if (length(stan_files) > 0 && !all(grepl("\\.stan$", stan_files))) {
      stop(
        "All files named in 'stan_files' must end with a ",
        "'.stan' extension."
      )
    }

    message("Running usethis::create_package ...", domain = NA)
    usethis::create_package(
        path = path,
        fields = fields,
        rstudio = rstudio,
        open = FALSE
      )

    DIR <- normalizePath(path)
    if (open && rstudio) {
      on.exit(rstudioapi::openProject(DIR, newSession = TRUE))
    }


    # tools
    usethis::use_directory("tools")
    use_rstanarm_file("tools/make_cc.R")


    # src
    usethis::use_directory("src")
    use_rstanarm_file("src/Makevars")
    use_rstanarm_file("src/Makevars.win")

    # register cpp (src/init.cpp)
    init_cpp(name, path = DIR)

    usethis::use_directory(file.path("src", "stan_files"))
    STAN_FILES <- file.path(DIR, "src", "stan_files")
    file.copy(stan_files, STAN_FILES)

    usethis::use_directory(file.path("src", "stan_files", "chunks"))
    download.file(
      .rstanarm_path("src/stan_files/pre/license.stan"),
      destfile = file.path(STAN_FILES, "chunks", "license.stan"),
      quiet = TRUE
    )
    system2(
      "sed",
      args = paste0(
        "-i.bak 's@rstanarm@", name, "@g' ",
        file.path(STAN_FILES, "chunks", "license.stan")
      ),
      stdout = FALSE,
      stderr = FALSE
    )
    file.remove(file.path(STAN_FILES, "chunks", "license.stan.bak"))


    # inst
    usethis::use_directory("inst")
    usethis::use_directory(file.path("inst", "include"))
    cat("// Insert all #include<foo.hpp> statements here",
        file = file.path(DIR, "inst", "include", "meta_header.hpp"), sep = "\n")


    # R
    message("Updating R directory ...", domain = NA)
    use_rstanarm_file("R/stanmodels.R")
    system2(
      "sed",
      args = paste0("-i.bak 's@rstanarm@", name, "@g' ",
                    file.path(DIR, "R", "stanmodels.R")),
      stdout = FALSE,
      stderr = FALSE
    )
    file.remove(file.path(DIR, "R", "stanmodels.R.bak"))
    cat(
      '.onLoad <- function(libname, pkgname) {',
      '  modules <- paste0("stan_fit4", names(stanmodels), "_mod")',
      '  for (m in modules) loadModule(m, what = TRUE)',
      '}',
      file = file.path(DIR, "R", "zzz.R"),
      sep = "\n",
      append = TRUE
    )
    .write_main_package_R_file(DIR)


    # travis (experimental feature)
    if (travis) {
      message("Adding .travis.yml file ...", domain = NA)
      .create_travis_file(DIR)
    }


    # description, namespace, read-and-delete-me
    message("Updating DESCRIPTION with necessary dependencies ...", domain = NA)
    .update_description_file(DIR)

    message("Updating NAMESPACE ...", domain=NA)
    NAMESPACE <- file.path(DIR, "NAMESPACE")
    if (file.exists(NAMESPACE)) {
      file.remove(NAMESPACE)
    }
    suppressMessages(roxygen2::roxygenise(package.dir = DIR, clean = TRUE))

    message("Writing Read-and-delete-me file with additional instructions ...",
            domain = NA)
    use_read_and_delete_me(DIR)


    message("\nFinished skeleton for package: ", name)
    message(
      domain = NA,
      sprintf(
        "Further steps are described in '%s'.",
        file.path(DIR, "Read-and-delete-me")
      )
    )

    invisible(TRUE)
  }



# internal ----------------------------------------------------------------
use_rstanarm_file <- function(rstanarm_relative_path) {
  proj <- usethis::proj_get()
  utils::download.file(
    url = .rstanarm_path(rstanarm_relative_path),
    destfile = file.path(proj, rstanarm_relative_path),
    quiet = TRUE
  )
}

.rstanarm_path <- function(relative_path) {
  base_url <- "https://raw.githubusercontent.com/stan-dev/rstanarm/master"
  file.path(base_url, relative_path)
}


use_read_and_delete_me <- function(pkg_dir) {
  cat(
    "* The precompiled stanmodel objects will appear in a named list called 'stanmodels', ",
    "and you can call them with something like rstan::sampling(stanmodels$foo, ...)",
    "* You can put into src/stan_files/chunks any file that is needed by any .stan file in src/stan_files, ",
    "* You can put into inst/include any C++ files that are needed by any .stan file in src/stan_files, ",
    "but be sure to #include your C++ files in inst/include/meta_header.hpp",
    "* While developing your package use devtools::install('.', local=FALSE) ",
    "to reinstall the package AND recompile Stan programs, or set local=FALSE to skip the recompilation.",
    file = file.path(pkg_dir, "Read-and-delete-me"),
    sep = "\n",
    append = FALSE
  )
}

.update_description_file <- function(pkg_dir) {
  available_pkgs <- available.packages(repos = "https://cran.rstudio.com/")[, c("Package", "Version")]
  available_pkgs <- data.frame(available_pkgs, stringsAsFactors = FALSE)
  .pkg_dependency <- function(pkg, last = FALSE) {
    ver <- available_pkgs$Version[available_pkgs$Package == pkg]
    paste0(pkg, " (>= ", ver, ")", if (!last) ", ")
  }

  cat(
    paste0("Depends: R (>= 3.4.0), ",
           .pkg_dependency("Rcpp"),
           "methods"),
    paste0("Imports: ",
           .pkg_dependency("rstan"),
           .pkg_dependency("rstantools", last=TRUE)),
    paste0("LinkingTo: ",
           .pkg_dependency("StanHeaders"),
           .pkg_dependency("rstan"),
           .pkg_dependency("BH"),
           .pkg_dependency("Rcpp"),
           .pkg_dependency("RcppEigen", last=TRUE)),
    "SystemRequirements: GNU make",
    "NeedsCompilation: yes",
    file = file.path(pkg_dir, "DESCRIPTION"),
    sep = "\n",
    append = TRUE
  )

  DES <- readLines(file.path(pkg_dir, "DESCRIPTION"))
  DES[grep("^License:", DES)] <- "License: GPL (>=3)"
  cat(
    DES,
    file = file.path(pkg_dir, "DESCRIPTION"),
    sep = "\n",
    append = FALSE
  )
}

.write_main_package_R_file <- function(pkg_dir) {
  pkgname <- basename(pkg_dir)
  cat(
    paste0("#' The '", pkgname, "' package."),
    "#' ",
    "#' @description A DESCRIPTION OF THE PACKAGE",
    "#' ",
    "#' @docType package",
    paste0("#' @name ", pkgname, "-package"),
    paste0("#' @aliases ", pkgname),
    paste0("#' @useDynLib ", pkgname, ", .registration = TRUE"),
    "#' @import methods",
    "#' @import Rcpp",
    "#' @import rstantools",
    "#' @importFrom rstan sampling",
    "#' ",
    "#' @references ",
    paste0("#' ", .rstan_reference()),
    "#' ",
    "NULL",
    file = file.path(pkg_dir, "R", paste0(pkgname, "-package.R")),
    sep = "\n",
    append = FALSE
  )
}


.rstan_reference <- function() {
  has_version <- utils::packageDescription("rstan", fields = "Version")
  version_year <- substr(utils::packageDescription("rstan", fields = "Date"), 1, 4)
  paste0(
    "Stan Development Team (", version_year,"). ",
    "RStan: the R interface to Stan. ",
    "R package version ", has_version, ". ",
    "http://mc-stan.org"
  )
}

.create_travis_file <- function(pkg_dir) {
  pkgname <- basename(pkg_dir)
  download.file(
    .rstanarm_path(".travis.yml"),
    destfile = file.path(pkg_dir, ".travis.yml"),
    quiet = TRUE
  )

  travis <- readLines(file.path(pkg_dir, ".travis.yml"))
  travis <- travis[!grepl("covr::codecov|/covr|r_github_packages", travis)]
  travis <- travis[!grepl("r_build_args|r_check_args", travis)]
  cat(
    gsub("rstanarm", pkgname, travis),
    file = file.path(pkg_dir, ".travis.yml"),
    sep = "\n",
    append = FALSE
  )
  cat(
    "^\\.travis\\.yml$",
    file = file.path(pkg_dir, ".Rbuildignore"),
    sep = "\n",
    append = TRUE
  )
}

