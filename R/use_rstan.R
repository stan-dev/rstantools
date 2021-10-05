# Part of the rstantools package
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

#' Add Stan infrastructure to an existing package
#'
#' Add Stan infrastructure to an existing \R package. To create a *new* package
#' containing Stan programs use [rstan_create_package()] instead.
#'
#' @template args-pkgdir
#' @template args-license
#' @template args-auto_config
#'
#' @details Prepares a package to compile and use Stan code by performing the
#'   following steps:
#' 1. Create `inst/stan` folder where all `.stan` files defining
#'   Stan models should be stored.
#' 1. Create `inst/stan/include` where optional `license.stan` file is stored.
#' 1. Create `inst/include/stan_meta_header.hpp` to include optional header
#'   files used by Stan code.
#' 1. Create `src` folder (if it doesn't exist) to contain the Stan C++ code.
#' 1. Create `R` folder (if it doesn't exist) to contain wrapper code to expose
#'   Stan C++ classes to \R.
#' 1. Update `DESCRIPTION` file to contain all needed dependencies to compile
#'   Stan C++ code.
#' 1. If `NAMESPACE` file is generic (i.e., created by [rstan_create_package()]),
#'   append `import(Rcpp, methods)`, `importFrom(rstan, sampling)`,
#'   and `useDynLib` directives.  If `NAMESPACE` is not generic, display message
#'   telling user what to add to `NAMESPACE` for themselves.
#'
#' @template details-auto_config
#' @template section-running-stan
#'
#' @return Invisibly, `TRUE` or `FALSE` indicating whether or not any files or
#'   folders where created or modified.
#'
#' @export
use_rstan <- function(pkgdir = ".", license = TRUE, auto_config = TRUE) {
  pkgdir <- .check_pkgdir(pkgdir)

  # stan folders
  acc <- .add_standir(pkgdir, "inst", "stan", "include",
                      msg = TRUE, warn = FALSE)
  acc <- acc | .add_standir(pkgdir, "inst", "include",
                            msg = TRUE, warn = FALSE)
  acc <- acc | .add_standir(pkgdir, "src",
                            msg = TRUE, warn = FALSE)
  acc <- acc | .add_standir(pkgdir, "R",
                            msg = TRUE, warn = FALSE)

  # add license.stan
  license <- .make_license(pkgdir, license)
  if (!is.null(license)) {
    .add_stanfile(license, pkgdir,
                  "inst", "stan", "include", "license.stan",
                  noedit = FALSE, msg = FALSE, warn = FALSE)
  }

  # add stan_meta_header.hpp
  meta_header <- .system_file("stan_meta_header.hpp")
  .add_stanfile(readLines(meta_header), pkgdir,
                "inst", "include", "stan_meta_header.hpp",
                noedit = FALSE, msg = FALSE, warn = FALSE)

  # add stan_init.cpp
  # not needed for compiling without src/stan_files subdirectory
  ## acc <- acc | .add_staninit(pkgdir)

  # add packages to DESCRIPTION file
  acc <- acc | .update_description(pkgdir,
                                   auto_config = auto_config, msg = TRUE)

  # add or remove configure files
  acc <- acc | any(.setup_configure(pkgdir, auto_config))

  # modify NAMESPACE, or output instructions for how to do so
  acc <- acc | .update_namespace(pkgdir, msg = TRUE)
  if (!acc) {
    message("Stan functionality is already enabled.")
  } else {
    message("Done.")
  }
  invisible(acc)
}

# make (or read) license file from logical/character specification
.make_license <- function(pkgdir, license) {
  if (is.logical(license) && !license) {
    # license == FALSE
    license <- NULL
  } else {
    if (is.logical(license)) {
      # default license
      license <- readLines(system.file("include", "sys", "lice_nse.stan",
                                       package = "rstantools"))
      license <- gsub("RSTAN_PACKAGE_NAME", basename(pkgdir), license)
    } else if (is.character(license)) {
      license <- readLines(license)
    } else {
      stop("license must be logical or character string.", call. = FALSE)
    }
  }
  license
}


# either updates the existing NAMESPACE if it is generic,
# or produces a message for needed modifications.
# msg: display message if NAMESPACE needs to be modified
# return value: whether or not NAMESPACE needed to be modified
.update_namespace <- function(pkgdir, msg = TRUE) {
  # read namespace file
  namespc <- file.path(pkgdir, "NAMESPACE")
  namespc <- readLines(namespc)
  # required namespace lines
  req_lines <- c("import(Rcpp)",
                 "import(methods)",
                 "importFrom(rstan, sampling)",
                 paste0("useDynLib(", basename(pkgdir),
                        ", .registration = TRUE)"))
  ## lib_req <- c(methods = NA, rcpp = NA, dynlib = NA)
  if (.is_generic_namespace(namespc)) {
    # automatically update default NAMESPACE
    if (msg) message("Updating NAMESPACE ...")
    writeLines(c("# Generated by roxygen2: fake comment so roxygen2 overwrites silently.",
                 namespc[!grepl("^#", namespc)],
                 req_lines),
                 con = file.path(pkgdir, "NAMESPACE"))
    acc <- TRUE # namespace was modified
  } else {
    # print message stating required dependencies
    # format existing namespace with no white space
    # and one directive per line
    whitespc <- "[ \n\t\r\v\f]*" # any white space
    namespc <- namespc[!grepl("^#", namespc)]
    namespc <- paste0(namespc, collapse = "\n")
    namespc <- gsub(whitespc, "", namespc)
    namespc <- paste0(strsplit(namespc, split = "[)]")[[1]], ")")
    # check for namespace dependencies
    msg_lines <- NULL
    acc <- FALSE
    if (!.has_import(namespc, pkg = "Rcpp")) {
      # import(Rcpp)
      msg_lines <- c(msg_lines, req_lines[1])
      acc <- TRUE
    }
    if (!.has_import(namespc, pkg = "methods")) {
      # import(methods)
      msg_lines <- c(msg_lines, req_lines[2])
      acc <- TRUE
    }
    if (!.has_import(namespc, pkg = "rstan", fun = "sampling")) {
      # importFrom(rstan, sampling)
      msg_lines <- c(msg_lines, req_lines[3])
      acc <- TRUE
    }
    dynlib <- paste0("^useDynLib[(]", basename(pkgdir),
                     ",[.]registration=TRUE[)]")
    if (!any(grepl(dynlib, namespc))) {
      # useDynLib(RSTAN_PACKAGE_NAME, .registration = TRUE)
      msg_lines <- c(msg_lines, req_lines[4])
      acc <- TRUE
    }
    if (acc && msg) {
      message("\nNext, add the following lines (e.g., via <package-name>-package.R if using roxygen) to your NAMESPACE:\n\n",
              paste0(msg_lines, collapse = "\n"), "\n")
    }
  }
  invisible(acc)
}

# whether or not namespc imports given pkg, or given fun from pkg
# assume namespc has been white space formatted
.has_import <- function(namespc, pkg, fun) {
  # check if whole package is imported
  import_pkg <- any(grepl("^import[(]", namespc) &
                    grepl(paste0("(,|[(])", pkg, "(,|[)])"), namespc))
  if (missing(fun)) {
    import_pkg
  } else {
    # check if given function is imported
    import_pkg || any(grepl(paste0("^importFrom[(]", pkg, ",", fun, "[)]"),
                            namespc))
  }
}

# check whether namespace is generic
.is_generic_namespace <- function(namespc) {
  # package.skeleton generic
  gen1 <- "exportPattern(\"^[[:alpha:]]+\")"
  # create_package generic
  gen2 <- c("# Generated by roxygen2: fake comment so roxygen2 overwrites silently.",
            "exportPattern(\"^[^\\\\.]\")")
  identical(namespc, gen1) || identical(namespc, gen2)
}

# add or remove configure files
.setup_configure <- function(pkgdir, add = TRUE) {
  conf_names <- c("configure", "configure.win")
  if (add) {
    acc <- sapply(conf_names, function(conf_name) {
      config <- readLines(.system_file(conf_name))
      .add_stanfile(config, pkgdir, conf_name,
                            noedit = TRUE, msg = FALSE, warn = TRUE)
    })
    if (any(acc)) message("Adding 'configure' files ...")
    # make scripts executable
    sapply(conf_names[acc], function(conf_name) {
      system(paste0('chmod +x "', file.path(pkgdir, conf_name), '"'))
    })
  } else {
    acc <- sapply(conf_names, function(conf_name) {
      noedit_msg <- .rstantools_noedit(conf_name)
      conf_name <- file.path(pkgdir, conf_name)
      if (file.exists(conf_name) &&
         (noedit_msg %in% readLines(conf_name, n = 5))) {
        file.remove(conf_name) # Stan file found.  remove it
      } else FALSE # no stan file found
    })
    if (any(acc)) message("Removing 'configure' files ...")
  }
  acc
}

#-------------------------------------------------------------------------------

# compile work flow
# 0.  optionally create package with package.skeleton.
#     delete man files so install.packages produces no errors.
# 1.  create necessary dirs.
#     don't need to warn if they already exist, because nothing happens
#     then anyways.  Add stan_meta_header.hpp and stan_init.cpp at this stage?
# 2.  update NAMESPACE.  if NAMESPACE doesn't exist or is default exportPattern,
#     add useDynLib and import(Rcpp, methods).
#     Otherwise, tell user what's left to be done.
# 3.  add stan_files if any.
# 4.  configure stan_files specific compile + export instructions, i.e.,
#     Makevars[.win] and stanmodels.R.  If no stan_files are present,
#     these files should be removed.

# question: what happens when no stan_files are present?
# i think stan_init.cpp should still be present.  otherwise, package doesn't
# compile if NAMESPACE has useDynLib.  how about stan_meta_header.cpp?
# let's say for now just have it.
