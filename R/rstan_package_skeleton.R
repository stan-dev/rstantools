# This file is part of RStan
# Copyright (C) 2015, 2016 Trustees of Columbia University
#
# RStan is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# RStan is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#' Create a skeleton for a new source package with Stan programs
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
#'
#' @details This function first calls \code{\link[utils]{package.skeleton}} and
#' then adds the files listed in \code{stan_files} to an exec directory.
#' Finally, it downloads several files from the \pkg{rstanarm} GitHub
#' repository to facilitate building the resulting package. Note that
#' \pkg{rstanarm} is licensed under the GPL >= 3, so package builders who do not
#' want to be governed by that license should not use the downloaded files that
#' contain R code. Otherwise, it may be worth considering whether it would be
#' easier to include your \code{.stan} programs and supporting \R code in the
#' \pkg{rstanarm} package.
#'
#' @template seealso-rstanarm-pkg
#' @seealso The \pkg{rstanarm} GitHub repository
#'   (\url{https://github.com/stan-dev/rstanarm}).
#'
rstan_package_skeleton <-
  function(name = "anRpackage",
           list = character(),
           environment = .GlobalEnv,
           path = ".",
           force = FALSE,
           code_files = character(),
           stan_files = character()) {
    if (length(stan_files) > 0 && !all(grepl("\\.stan$", stan_files)))
      stop("All files named in 'stan_files' must end ",
           "with a '.stan' extension.")

    mc <- match.call()
    mc$stan_files <- NULL
    mc[[1]] <- quote(utils::package.skeleton)
    eval(mc)

    if (R.version[["major"]] < 3 ||
        (R.version[["major"]] == 3 && R.version[["minor"]] < 2.2)) {
      warning(
        "rstan_package_skeleton is only fully operational with R >= 3.2.2, ",
        "but you can still follow the package skeleton of the rstanarm package ",
        "on GitHub to set up the rest of your package."
      )
      return(invisible(NULL))
    }

    DIR <- file.path(path, name)
    download.file(
      .rstanarm_path("cleanup"),
      destfile = file.path(DIR, "cleanup"),
      quiet = TRUE
    )
    download.file(
      .rstanarm_path("cleanup.win"),
      destfile = file.path(DIR, "cleanup.win"),
      quiet = TRUE
    )
    cat(
      "cleanup*",
      file = file.path(DIR, ".Rbuildignore"),
      sep = "\n"
    )

    TOOLS <- file.path(DIR, "tools")
    dir.create(TOOLS)
    download.file(
      .rstanarm_path("tools/make_cpp.R"),
      destfile = file.path(TOOLS, "make_cpp.R"),
      quiet = TRUE
    )
    EXEC <- file.path(DIR, "exec")
    dir.create(EXEC)
    file.copy(stan_files, EXEC)

    INST <- file.path(DIR, "inst")
    dir.create(INST)
    CHUNKS <- file.path(DIR, "inst", "chunks")
    dir.create(CHUNKS)
    file.create(file.path(CHUNKS, "common_functions.stan"))
    file.create(file.path(CHUNKS, "license.stan"))

    SRC <- file.path(DIR, "src")
    dir.create(SRC, showWarnings = FALSE)
    download.file(
      .rstanarm_path("src/Makevars"),
      destfile = file.path(SRC, "Makevars"),
      quiet = TRUE
    )

    R <- file.path(DIR, "R")
    dir.create(R, showWarnings = FALSE)
    download.file(
      .rstanarm_path("R/stanmodels.R"),
      destfile = file.path(R, "stanmodels.R"),
      quiet = TRUE
    )
    cat(
      '.onLoad <- function(libname, pkgname) {',
      'if (!("methods" %in% .packages())) attachNamespace("methods")',
      'modules <- paste0("stan_fit4", names(stanmodels), "_mod")',
      'for (m in modules) loadModule(m, what = TRUE)',
      '}',
      file = file.path(R, "zzz.R"),
      sep = "\n",
      append = TRUE
    )

    if (!length(stan_files)) {
      module_names <- "NAME"
    } else {
      module_names <- paste0(
        "stan_fit4",
        sub("\\.stan$", "", basename(stan_files)),
        "_mod"
      )
    }
    cat(
      "Depends: R (>= 3.0.2), Rcpp (>= 0.12.0)",
      "Imports: rstan (>= 2.12.1)",
      "LinkingTo: StanHeaders (>= 2.12.0), rstan (>= 2.12.1), BH (>= 1.60.0), Rcpp (>= 0.12.0), RcppEigen",
      file = file.path(DIR, "DESCRIPTION"),
      sep = "\n",
      append = TRUE
    )
    cat(
      "\n\nStan specific notes:\n",
      "* Be sure to add useDynLib(mypackage, .registration = TRUE) to NAMESPACE.",
      "* You can put into inst/chunks/common_functions.stan any function that is needed by any .stan file, ",
      "in which case any .stan file can have #include 'common_functions.stan' in its functions block.",
      "* The precompiled stanmodel objects will appear in a named list called 'stanmodels'.",
      "* The 'cleanup' and 'cleanup.win' scripts in the root of the directory must be made executable.",
      file = file.path(DIR, "Read-and-delete-me"),
      sep = "\n",
      append = TRUE
    )

    return(invisible(NULL))
  }


# internal ----------------------------------------------------------------
.rstanarm_path <- function(relative_path) {
  base_url <- "https://raw.githubusercontent.com/stan-dev/rstanarm/master"
  file.path(base_url, relative_path)
}
