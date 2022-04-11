#' Update `DESCRIPTION` to include all packages required to compile Stan code.
#'
#' @noRd
#' @param pkgdir Package root directory.
#' @param auto_config Whether or not package should configure itself.  This
#'   means importing `rstantools` for linking via `configure[.win]`) and setting
#'   `Biarch: true` in the `DESCRIPTION`.
#' @param msg Whether or not to display a message if an attempt to update
#'   `DESCRIPTION` is made.
#'
#' @return Whether or not `DESCRIPTION` file was modified.
#'
#' @details Sanitizes the package dependencies as follows:
#' \itemize{
#'   \item If `rstantools` dependency version is lower, don't update
#'   existing dependency.
#'   \item If `rstantools` `Imports` dependency already exists in
#'   `Depends`, keep the `Depends` package but increase version if
#'   needed.
#' }
#'
#' Issues the following messages:
#' \itemize{
#'   \item If `auto_config = FALSE` and `rstantools` is imported.
#'   \item If `auto_config = FALSE` and `Biarch: true`.
#' }
#'
.update_description <- function(pkgdir, auto_config = FALSE, msg = TRUE) {
  # current desc file
  desc_pkg <- desc::description$new(file.path(pkgdir, "DESCRIPTION"))
  # save a copy
  desc_old <- desc::description$new(file.path(pkgdir, "DESCRIPTION"))
  # rstantools desc file
  desc_rstan <- desc::description$new(.system_file("DESCRIPTION"))
  # check for Biarch field
  has_biarch <- desc_pkg$has_fields("Biarch")
  if(!auto_config) {
    # check for rstantools dependence
    has_rstantools <- desc_pkg$has_dep("rstantools", type = "Imports") ||
      desc_pkg$has_dep("rstantools", type = "Depends")
    # check if Biarch: true
    has_biarch <- has_biarch && tolower(desc_pkg$get_field("Biarch")) == "true"
    # don't add dependence on rstantools
    desc_rstan$del_dep("rstantools", type = "Imports")
  } else {
    # use latest version of rstantools
    desc_rstan$set_dep("rstantools", type = "Imports",
                       version = paste0(">= ",
                                        utils::packageVersion("rstantools")))
    # add Biarch: true for multiarch Windows
    desc_pkg$set(Biarch = "true")
  }
  # update dependencies
  dep_pkg <- desc_pkg$get_deps()
  names(dep_pkg)[3] <- "vpkg"
  dep_rstan <- desc_rstan$get_deps()
  names(dep_rstan)[3] <- "vrstan"
  # convert all rstan Imports to Depends if they are in package Depends
  di <- dep_rstan$package %in% dep_pkg$package[dep_pkg$type == "Depends"]
  dep_rstan$type[di & dep_rstan$type == "Imports"] <- "Depends"
  # combine all dependencies
  dep_comb <- merge(x = dep_pkg, y = dep_rstan,
                    by = c("type", "package"), all = TRUE)
  # larger version of each package
  dep_comb <- cbind(dep_comb[1:2],
                    version = .version_max(dep_comb$vpkg, dep_comb$vrstan))
  desc_pkg$set_deps(dep_comb)
  # add additional elements from template DESCRIPTION file
  extra_fields <- c("SystemRequirements", "Encoding")
  do.call(desc_pkg$set, as.list(desc_rstan$get(extra_fields)))
  # check if description has changed
  acc <- !identical(desc_pkg$str(), desc_old$str())
  if(acc) {
    if(msg) message("Updating DESCRIPTION ...")
    desc_pkg$write()
  }
  if(!auto_config && msg) {
    if(has_rstantools) {
      message("'Import: rstantools' detected in DESCRIPTION with 'auto_config = FALSE'.\n",
              "If you did not add this dependence yourself then it's safe to remove it.\n")
    }
    if(has_biarch) {
      message("'Biarch: true' detected in DESCRIPTION with 'auto_config = FALSE'.\n",
              "If you did not add this line yourself then it's safe to remove it.\n")
    }
  }
  invisible(acc)
}

# return greater of two version numbers in desc::desc_get_dep format
.version_max <- function(ver1, ver2) {
    # convert non-existing/any version packages to 0
    ver1 <- gsub("^[^[:digit:]]*([[:digit:]]*)",
                 replacement = "\\1", ver1)
    ver1[is.na(ver1) | ver1 == ""] <- 0
    ver2 <- gsub("^[^[:digit:]]*([[:digit:]]*)",
                 replacement = "\\1", ver2)
    ver2[is.na(ver2) | ver2 == ""] <- 0
    # take greater of two versions
    vmax <- mapply(function(x, y) utils::compareVersion(x, y) >= 0,
                   x = ver1, y = ver2)
    vmax <- ifelse(vmax, ver1, ver2)
    ifelse(vmax == "0", "*", paste0(">= ", vmax))
}
