#' Update \code{DESCRIPTION} to include all packages required to compile Stan code.
#'
#' @param pkgdir Package root directory.
#' @param auto_config Whether or not package should configure itself.  This means importing \code{rstantools} for linking via \code{configure[.win]}) and setting \code{Biarch: true} in the \code{DESCRIPTION}.
#' @param msg Whether or not to display a message if an attempt to update \code{DESCRIPTION} is made.
#'
#' @return Whether or not \code{DESCRIPTION} file was modified.
#'
#' @details Sanitizes the package dependencies as follows:
#' \itemize{
#'   \item If \code{rstantools} dependency version is lower, don't update existing dependency.
#'   \item If \code{rstantools} \code{Imports} dependency already exists in \code{Depends}, keep the \code{Depends} package but increase version if needed.
#' }
#'
#' Issues the following messages:
#' \itemize{
#'   \item If \code{auto_config = FALSE} and \code{rstantools} is imported.
#'   \item If \code{auto_config = FALSE} and \code{Biarch: true}.
#' }
#' @keywords internal
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
  # check if description has changed
  acc <- !identical(desc_pkg$str(), desc_old$str())
  if(acc) {
    if(msg) message("Updating DESCRIPTION ...")
    desc_pkg$write()
    ## cat(desc_pkg$str(normalize = FALSE), "\n",
    ##     file = file.path(pkgdir, "DESCRIPTION"))
    ## dep_fields <- dep_fields[dep_fields %in% colnames(desc_pkg)]
    ## write.dcf(desc_pkg, file = file.path(pkgdir, "DESCRIPTION"),
    ##           keep.white = dep_fields)
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
    vmax <- mapply(function(x, y) compareVersion(x, y) >= 0,
                   x = ver1, y = ver2)
    vmax <- ifelse(vmax, ver1, ver2)
    ifelse(vmax == "0", "*", paste0(">= ", vmax))
}

# update DESCRIPTION file to include all packages required to compile Stan code.
# auto_config: whether or not package should configure itself.
# this means importing rstantools (for linking via configure[.win] file) and
# setting option Biarch: true
# msg: display message if attempt to create is made
# also when setting auto_config = FALSE, issues a message
# if rstantools is already imported and/or Biarch: true
# return value: whether or not file was modified
.update_description_old <- function(pkgdir, auto_config = FALSE, msg = TRUE) {
  desc_pkg <- read.dcf(file.path(pkgdir, "DESCRIPTION"))
  desc_pkg <- gsub("\n", " ", desc_pkg)
  desc_old <- desc_pkg
  desc_rstan <- read.dcf(.system_file("DESCRIPTION"))
  dep_fields <- c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")
  pkg_fields <- dep_fields[dep_fields %in% colnames(desc_rstan)]
  # check for Biarch field
  has_biarch <- "Biarch" %in% colnames(desc_pkg)
  if(!auto_config) {
    # check for rstantools dependence
    if("Imports" %in% colnames(desc_pkg)) {
      has_rstantools <- .version_split(desc_pkg[,"Imports"])
      has_rstantools <- any(grepl(pattern = "(?<!\\w)rstantools(?!\\w)",
                                  x = has_rstantools[,"pkg"], perl = TRUE))
    } else has_rstantools <- FALSE
    # check if Biarch: true
    has_biarch <- has_biarch && grepl(pattern = "(?<!\\w)true(?!\\w)",
                                      x = desc_pkg[,"Biarch"],
                                      perl = TRUE, ignore.case=TRUE)
    # don't add dependence on rstantools
    imp_field <- .version_split(desc_rstan[,"Imports"])
    imp_field <- .version_comb(imp_field[imp_field[,"pkg"] != "rstantools",])
    desc_rstan[,"Imports"] <- imp_field
  } else {
    # add Biarch: true for multiarch Windows
    if(has_biarch) {
      desc_pkg[,"Biarch"] <- "true"
    } else {
      desc_pkg <- cbind(desc_pkg, Biarch = "true")
    }
  }
  for(fname in pkg_fields) {
    # update each field with packages and versions required by Stan
    if(fname %in% colnames(desc_pkg)) {
      desc_pkg[,fname] <- .append_pkgfield(desc_pkg[,fname], desc_rstan[,fname])
    } else {
      desc_pkg <- cbind(desc_pkg, desc_rstan[,fname])
      colnames(desc_pkg)[ncol(desc_pkg)] <- fname
    }
  }
  # TODO: make sure all packages listed more than once have the same version
  desc_pkg <- .format_description(desc_pkg)
  # check if description has changed
  acc <- !identical(desc_pkg, .format_description(desc_old))
  if(acc) {
    if(msg) message("Updating DESCRIPTION ...")
    dep_fields <- dep_fields[dep_fields %in% colnames(desc_pkg)]
    write.dcf(desc_pkg, file = file.path(pkgdir, "DESCRIPTION"),
              keep.white = dep_fields)
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

#--- helper functions ----------------------------------------------------------

# split tcf field of package names into name + version (if any, or NA)
.version_split <- function(pkg_names) {
  # comma indicates separation between packages
  pkgs <- strsplit(pkg_names, "[ ]*,[ ]*")[[1]]
  # space separation on version
  ver <- strsplit(pkgs, "[ ]+")
  ver <- sapply(ver, function(str) {
    if(length(str) == 1) {
      c(str, "")
    } else c(str[1], paste0(str[-1], collapse = " "))
  })
  rownames(ver) <- c("pkg", "ver")
  t(ver)
}

# recombine into single string
.version_comb <- function(ver) {
  pkgs <- apply(ver, 1, function(vv) paste0(vv[vv != ""], collapse = " "))
  pkgs <- paste0(pkgs, collapse = ", ")
  names(pkgs) <- NULL
  pkgs
}

# update current packages and versions if new ones provided,
# otherwise don't change
.append_pkgfield <- function(curr_pkg, new_pkg) {
  cver <- .version_split(curr_pkg)
  nver <- .version_split(new_pkg)
  update <- cver[,1] %in% nver[,1]
  pkg_ver <- matrix(NA, nrow(nver) + sum(!update), 2)
  colnames(pkg_ver) <- c("pkg", "ver")
  # update packages
  for(ii in 1:nrow(cver)) {
    if(update[ii]) {
      pkg_ver[ii,] <- nver[nver[,1] == cver[ii,1],]
    } else {
      pkg_ver[ii,] <- cver[ii,]
    }
  }
  # add new packages
  add_pkgs <- !(nver[,1] %in% cver[,1])
  if(any(add_pkgs)) {
    pkg_ver[nrow(cver)+1:sum(add_pkgs),] <- nver[add_pkgs,]
  }
  .version_comb(pkg_ver)
}

# order description fields
# first should have: Package, Type, Title, Version, Date, Author, Maintainer, Description, License.
# then should have Depends, Imports, LinkingTo, Suggests, Enhances
# then everything else, unordered.
.format_description <- function(desc) {
  field_names <- colnames(desc)
  field_set <- c("Package", "Type", "Title", "Version", "Date",
                 "Author", "Maintainer", "Authors@R",
                 "Description", "License",
                 "Depends", "Imports", "LinkingTo", "Suggests", "Enhances")
  ordered_fields <- field_set[field_set %in% field_names]
  ordered_fields <- c(ordered_fields, field_names[!field_names %in% field_set])
  desc <- desc[,ordered_fields,drop=FALSE]
  rownames(desc) <- NULL
  desc
}

#--- compare versions ----------------------------------------------------------

# ok.  to do this, can just strip out the relation indicators.
