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
#' @export
use_rstan <- function(pkgdir = ".", license = TRUE) {
  pkgdir <- .check_pkgdir(pkgdir)
  # stan folders
  message("Creating inst/stan directory ...")
  .add_standir(pkgdir, "inst", "stan", "include")
  message("Creating inst/include directory ...")
  .add_standir(pkgdir, "inst", "include")
  message("Creating src/stan_files directory ...")
  .add_standir(pkgdir, "src", "stan_files")
  # add packages to DESCRIPTION file
  message("Updating DESCRIPTION file ...")
  .update_description(pkgdir)
  # add license.stan
  license <- .make_license(pkgdir, license)
  if(!is.null(license)) {
    .add_stanfile(license, pkgdir, noedit = FALSE,
                  "inst", "stan", "include", "license.stan")
  }
  # add stan_meta_header.hpp
  meta_header <- .system_file("stan_meta_header.hpp")
  .add_stanfile(readLines(meta_header), pkgdir, noedit = FALSE,
                "inst", "include", "stan_meta_header.hpp")
  .msg_namespace(pkgdir)
  invisible(NULL)
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
.msg_namespace <- function(pkgdir) {
  namespc <- file.path(pkgdir, "NAMESPACE")
  namespc <- paste0(readLines(namespc)[c(2:6,1)], collapse = "\n")
  namespc <- gsub("[ \n\t\r\v\f]*", "", namespc)
  has_methods <- grepl("(^import|[)]import)[(]([^,]*,)*methods", namespc)
  has_rcpp <- grepl("(^import|[)]import)[(]([^,]*,)*Rcpp", namespc)
  has_dynlib <- paste0("(^useDynLib|[)]useDynLib)[(]", basename(pkgdir),
                       ",[.]registration=TRUE[)]")
  has_dynlib <- grepl(has_dynlib, namespc)
  lib_req <- c(methods = !has_methods, rcpp = !has_rcpp, dynlib = !has_dynlib)
  if(any(lib_req)) {
    msg <- c("import(methods)",
             "import(Rcpp)",
             paste0("useDynLib(", basename(pkgdir),
                    ", .registration = TRUE)"))
    message("\nNext, add the following lines to your NAMESPACE:\n\n",
            paste0(msg[lib_req], collapse = "\n"), "\n")
  }
  invisible(NULL)
}
