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
#'   \if{html}{\figure{stanlogo.png}{options: width="50px" alt="http://mc-stan.org/about/logo/"}}
#'   The \code{rstan_package_skeleton} function helps get you started developing
#'   \R packages that interface with Stan via the \pkg{rstan} package.
#'   \code{rstan_package_skeleton} is very similar to
#'   \code{\link[utils]{package.skeleton}} but is designed for source packages
#'   that want to include Stan Programs that can be built into binary versions
#'   (i.e., pre-compiled like \pkg{rstanarm}). See \strong{Details} for a few
#'   ways that it differs from \code{package.skeleton}.
#'
#'   See the \strong{See Also} section below for links to recommendations for
#'   developers and a step by step walkthrough of what to do after running
#'   \code{rstan_package_skeleton}.
#'
#' @export
#' @param name,list,environment,path,force,code_files Same as
#'   \code{\link[utils]{package.skeleton}}.
#' @param stan_files A character vector with paths to \code{.stan} files to
#'   include in the package (these files will be included in the
#'   \code{src/stan_files} directory). Otherwise similar to the
#'   \code{code_files} argument.
#' @param travis Should a \code{.travis.yml} file be added to the package
#'   directory? Defaults to \code{TRUE}. The file has some settings already set
#'   to help with compilation issues, but we do not guarantee that it will work
#'   on \href{https://travis-ci.org/}{travis-ci}.
#'
#' @details This function first calls \code{\link[utils]{package.skeleton}} and
#'   then adds the files listed in \code{stan_files} to the
#'   \code{src/stan_files} directory. Finally, it downloads several files from
#'   \pkg{rstanarm} package's
#'   \href{http://github.com/stan-dev/rstanarm}{GitHub repository} to facilitate
#'   building the resulting package. Note that \pkg{\link[rstanarm]{rstanarm}}
#'   is licensed under the GPL >= 3, so package builders who do not want to be
#'   governed by that license should not use the downloaded files that contain
#'   \R code (that said, \pkg{Rcpp} is GPL, so not using the \pkg{rstanarm}
#'   files is not the only thing impeding use of other licenses). Otherwise, it
#'   may be worth considering whether it would be easier to include your
#'   \code{.stan} programs and supporting \R code in the \pkg{rstanarm} package.
#'
#'   Unlike \code{package.skeleton}, \code{rstan_package_skeleton} also creates
#'   a file in the \code{R/} directory called "\code{name}-package.R", where
#'   \code{name} is the package name. In this file \code{rstan_package_skeleton}
#'   writes lines (using \pkg{roxygen2} tags) for ensuring that some necessary
#'   content makes it into the \code{NAMESPACE} file. Before terminating,
#'   \code{rstan_package_skeleton} will run \code{roxygen2::roxygenise} so that
#'   the NAMESPACE is created.
#'
#'   \code{rstan_package_skeleton} will also create an RStudio project file
#'   for the package with a \code{.Rproj} extension. If not using RStudio
#'   this file can be deleted or ignored.
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
  function(name = "anRpackage",
           list = character(),
           environment = .GlobalEnv,
           path = ".",
           force = FALSE,
           code_files = character(),
           stan_files = character(),
           travis = TRUE) {

    if (!requireNamespace("roxygen2", quietly = TRUE)) {
      stop("Please install the 'roxygen2' package to use this function.")
    }

    message("Creating package skeleton for package: ", name, domain = NA)

    if (length(stan_files) > 0 && !all(grepl("\\.stan$", stan_files))) {
      stop(
        "All files named in 'stan_files' must end with a ",
        "'.stan' extension."
      )
    }

    mc <- match.call()
    mc$stan_files <- NULL
    mc[[1]] <- quote(utils::package.skeleton)

    if (is.null(mc$environment)) {
      has_objects <- length(ls(envir = environment))
      if (!has_objects) {
        mc$environment <- new.env(parent = emptyenv())
        mc$environment$delete_data <- "placeholder data to avoid package.skeleton error"
      }
    }

    message("Running package.skeleton ...", domain = NA)
    suppressMessages(eval(mc))
    DIR <- file.path(path, name)

    message("Creating tools directory ...", domain = NA)
    TOOLS <- file.path(DIR, "tools")
    dir.create(TOOLS)
    download.file(
      .rstanarm_path("tools/make_cc.R"),
      destfile = file.path(TOOLS, "make_cc.R"),
      quiet = TRUE
    )

    message("Creating src directory ...", domain = NA)
    SRC <- file.path(DIR, "src")
    dir.create(SRC, showWarnings = FALSE)
    download.file(
      .rstanarm_path("src/Makevars"),
      destfile = file.path(SRC, "Makevars"),
      quiet = TRUE
    )
    download.file(
      .rstanarm_path("src/Makevars.win"),
      destfile = file.path(SRC, "Makevars.win"),
      quiet = TRUE
    )

    # register cpp (src/init.cpp)
    init_cpp(name, path = DIR)

    message("Creating directory for .stan files ...", domain = NA)
    STAN_FILES <- file.path(SRC, "stan_files")
    dir.create(STAN_FILES)
    file.copy(stan_files, STAN_FILES)

    message("Creating directory for Stan code chunks ...", domain = NA)
    CHUNKS <- file.path(STAN_FILES, "chunks")
    dir.create(CHUNKS)
    download.file(
      .rstanarm_path("src/stan_files/pre/license.stan"),
      destfile = file.path(CHUNKS, "license.stan"),
      quiet = TRUE
    )
    system2("sed", args = paste0("-i.bak 's@rstanarm@", name, "@g' ",
                                 file.path(CHUNKS, "license.stan")),
            stdout = FALSE, stderr = FALSE)
    file.remove(file.path(CHUNKS, "license.stan.bak"))

    message("Creating directory for custom C++ functions ...", domain = NA)
    INST <- file.path(DIR, "inst")
    dir.create(INST)
    INCLUDE <- file.path(INST, "include")
    dir.create(INCLUDE)
    cat("// Insert all #include<foo.hpp> statements here",
        file = file.path(INCLUDE, "meta_header.hpp"), sep = "\n")


    message("Cleaning up unused files ...", domain = NA)
    .remove_unused_files(DIR)

    message("Updating DESCRIPTION ...", domain = NA)
    .update_description_file(DIR)

    message("Updating R directory ...", domain = NA)
    R <- file.path(DIR, "R")
    dir.create(R, showWarnings = FALSE)
    download.file(
      .rstanarm_path("R/stanmodels.R"),
      destfile = file.path(R, "stanmodels.R"),
      quiet = TRUE
    )
    system2(
      "sed",
      args = paste0("-i.bak 's@rstanarm@", name, "@g' ", file.path(R, "stanmodels.R")),
      stdout = FALSE,
      stderr = FALSE
    )
    file.remove(file.path(R, "stanmodels.R.bak"))
    cat(
      '.onLoad <- function(libname, pkgname) {',
      '  modules <- paste0("stan_fit4", names(stanmodels), "_mod")',
      '  for (m in modules) loadModule(m, what = TRUE)',
      '}',
      file = file.path(R, "zzz.R"),
      sep = "\n",
      append = TRUE
    )
    .write_main_package_R_file(DIR)

    if (travis) {
      message("Adding .travis.yml file ...", domain = NA)
      .create_travis_file(DIR)
    }

    # rstudio project file
    .create_rproj(DIR)

    message("Updating NAMESPACE ...", domain=NA)
    suppressMessages(roxygen2::roxygenise(package.dir = DIR, clean = TRUE))

    message("Writing Read-and-delete-me file with additional instructions ...",
            domain = NA)
    .write_read_and_delete_me(DIR)

    message("Finished skeleton for package: ", name, ".\n")
    message(
      domain = NA,
      sprintf(
        "Further steps are described in '%s'.",
        file.path(DIR, "Read-and-delete-me")
      )
    )

    invisible(NULL)
  }


# internal ----------------------------------------------------------------
.rstanarm_path <- function(relative_path) {
  base_url <- "https://raw.githubusercontent.com/stan-dev/rstanarm/master"
  file.path(base_url, relative_path)
}

.write_read_and_delete_me <- function(dir) {
  cat(
    "* Delete the file at 'data/delete_data.rda' if it exists ",
    "(this file is created to avoid an error from package.skeleton called with an empty environment).",
    "* The precompiled stanmodel objects will appear in a named list called 'stanmodels', ",
    "and you can call them with something like rstan::sampling(stanmodels$foo, ...)",
    "* You can put into src/stan_files/chunks any file that is needed by any .stan file in src/stan_files, ",
    "* You can put into inst/include any C++ files that are needed by any .stan file in src/stan_files, ",
    "but be sure to #include your C++ files in inst/include/meta_header.hpp",
    "* While developing your package use devtools::install('.', local=FALSE) ",
    "to reinstall the package AND recompile Stan programs, or set local=FALSE to skip the recompilation.",
    file = file.path(dir, "Read-and-delete-me"),
    sep = "\n",
    append = FALSE
  )
}

.update_description_file <- function(dir) {
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
    file = file.path(dir, "DESCRIPTION"),
    sep = "\n",
    append = TRUE
  )

  DES <- readLines(file.path(dir, "DESCRIPTION"))
  DES[grep("^License:", DES)] <- "License: GPL (>=3)"
  cat(
    DES,
    file = file.path(dir, "DESCRIPTION"),
    sep = "\n",
    append = FALSE
  )
}

.write_main_package_R_file <- function(dir) {
  pkgname <- basename(dir)
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
    file = file.path(dir, "R", paste0(pkgname, "-package.R")),
    sep = "\n",
    append = FALSE
  )
}

.remove_unused_files <- function(dir) {
  pkgname <- basename(dir)

  if (file.exists(file.path(dir, "NAMESPACE"))) {
    file.remove(file.path(dir, "NAMESPACE"))
  }

  DATA <- file.path(dir, "data")
  if (file.exists(file.path(DATA, "delete_data.rds"))) {
    file.remove(file.path(DATA, "delete_data.rds"))
  }
  if (!length(list.files(DATA))) {
    file.remove(DATA)
  }

  MAN <- file.path(dir, "man")
  if (file.exists(file.path(MAN, "delete_data.Rd"))) {
    file.remove(file.path(MAN, "delete_data.Rd"))
  }
  if (file.exists(file.path(MAN, paste0(pkgname, "-package.Rd")))) {
    file.remove(file.path(MAN, paste0(pkgname, "-package.Rd")))
  }
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

.create_rproj <- function(dir) {
  pkgname <- basename(dir)
  if (!file.exists(file.path(dir, paste0(pkgname, ".Rproj")))) {
    message("Creating .Rproj file ...")
    download.file(
      "https://raw.githubusercontent.com/rstudio/ptexamples/master/ptexamples.Rproj",
      destfile = file.path(dir, paste0(pkgname, ".Rproj")),
      quiet = TRUE
    )
  }
  cat(
    "^.*\\.Rproj$",
    "^\\.Rproj\\.user$",
    file = file.path(dir, ".Rbuildignore"),
    sep = "\n",
    append = TRUE
  )
}

.create_travis_file <- function(dir) {
  pkgname <- basename(dir)
  download.file(
    .rstanarm_path(".travis.yml"),
    destfile = file.path(dir, ".travis.yml"),
    quiet = TRUE
  )

  travis <- readLines(file.path(dir, ".travis.yml"))
  travis <- travis[!grepl("covr::codecov|/covr|r_github_packages", travis)]
  travis <- travis[!grepl("r_build_args|r_check_args", travis)]
  cat(
    gsub("rstanarm", pkgname, travis),
    file = file.path(dir, ".travis.yml"),
    sep = "\n",
    append = FALSE
  )
  cat(
    "^\\.travis\\.yml$",
    file = file.path(dir, ".Rbuildignore"),
    sep = "\n",
    append = TRUE
  )
}
