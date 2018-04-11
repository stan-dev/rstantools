#' Add Stan infrastructure to an existing package.
#'
#' @template args-pkgdir
#' @template args-license
#' @details Prepares a package to compile and use Stan code by performing the following steps:
#' \enumerate{
#'   \item Update \code{DESCRIPTION} file to contain all needed dependencies.
#'   \item If \code{src} folder does not exist, create system file \code{src/init.cpp} to ensure Stan C++ modules are recognized by \R.
#'   \item Create system file \code{src/stan_files/chunks/license.stan} containing default license information.
#'   \item Create system file \code{inst/include/meta_header.hpp} for C++ headers used by Stan code.
#' }
#' @return Invisibly, whether or not any files or folders where created or modified.
#' @export
use_rstan <- function(pkgdir = ".", license = TRUE) {
  pkgdir <- .check_pkgdir(pkgdir)
  # stan folders
  acc <- .add_standir(pkgdir, "inst", "stan", "include",
                      msg = TRUE, warn = FALSE)
  acc <- acc | .add_standir(pkgdir, "inst", "include",
                            msg = TRUE, warn = FALSE)
  acc <- acc | .add_standir(pkgdir, "src", "stan_files",
                            msg = TRUE, warn = FALSE)
  # add license.stan
  license <- .make_license(pkgdir, license)
  if(!is.null(license)) {
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
  acc <- acc | .add_staninit(pkgdir)
  # add packages to DESCRIPTION file
  acc <- acc | .update_description(pkgdir, msg = TRUE)
  # modify NAMESPACE, or output instructions for how to do so
  acc <- acc | .update_namespace(pkgdir, msg = TRUE)
  if(!acc) {
    message("rstan is already initialized.")
  }
  invisible(acc)
}

# make (or read) license file from logical/character specification
.make_license <- function(pkgdir, license) {
  if(is.logical(license) && !license) {
    # license == FALSE
    license <- NULL
  } else {
    if(is.logical(license)) {
      # default license
      license <- readLines(system.file("include", "sys", "license.stan",
                                       package = "rstantools"))
      license <- gsub("RSTAN_PACKAGE_NAME", basename(pkgdir), license)
    } else if(is.character(license)) {
      license <- readLines(license)
    } else {
      stop("license must be logical or character string.")
    }
  }
  license
}


# message for remaining steps obtained by scanning NAMESPACE
# msg: display message if NAMESPACE needs to be modified
# return value: whether or not NAMESPACE needed to be modified
.update_namespace <- function(pkgdir, msg = TRUE) {
  namespc <- file.path(pkgdir, "NAMESPACE")
  namespc <- readLines(namespc)
  lib_req <- c(methods = NA, rcpp = NA, dynlib = NA)
  if(identical(namespc, "exportPattern(\"^[[:alpha:]]+\")")) {
    if(msg) message("Updating NAMESPACE ...")
    # default namespace
    cat("import(Rcpp, methods)",
        paste0("useDynLib(", basename(pkgdir), ", .registration = TRUE)"),
        file = file.path(pkgdir, "NAMESPACE"),
        sep = "\n", append = TRUE)
    lib_req <- c(methods = FALSE, rcpp = FALSE, dynlib = FALSE)
  } else {
    # figure out what's missing from namespace
    namespc <- paste0(namespc, collapse = "\n")
    namespc <- gsub("[ \n\t\r\v\f]*", "", namespc)
    lib_req["methods"] <- !grepl("(^import|[)]import)[(]([^,]*,)*methods",
                                 namespc)
    lib_req["rcpp"]  <- !grepl("(^import|[)]import)[(]([^,]*,)*Rcpp", namespc)
    dynlib <- paste0("(^useDynLib|[)]useDynLib)[(]", basename(pkgdir),
                     ",[.]registration=TRUE[)]")
    lib_req["dynlib"] <- !grepl(dynlib, namespc)
  }
  acc <- any(lib_req)
  if(acc) {
    msg_lines <- c("import(methods)",
                   "import(Rcpp)",
                   paste0("useDynLib(", basename(pkgdir),
                          ", .registration = TRUE)"))
    if(msg) {
      message("\nNext, add the following lines to your NAMESPACE:\n\n",
              paste0(msg_lines[lib_req], collapse = "\n"), "\n")
    }
  }
  invisible(acc)
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
