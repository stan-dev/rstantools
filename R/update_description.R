# update DESCRIPTION file to include all packages required to compile Stan code.
# rstantools: whether or not package should import rstantools (for linking via config file)
# msg: display message if attempt to create is made
# return value: whether or not file was modified
.update_description <- function(pkgdir, rstantools = FALSE, msg = TRUE) {
  desc_pkg <- read.dcf(file.path(pkgdir, "DESCRIPTION"))
  desc_pkg <- gsub("\n", " ", desc_pkg)
  desc_old <- desc_pkg
  desc_rstan <- read.dcf(.system_file("DESCRIPTION"))
  dep_fields <- c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")
  pkg_fields <- dep_fields[dep_fields %in% colnames(desc_rstan)]
  if(!rstantools) {
    # remove dependence on rstantools
    imp_field <- .version_split(desc_rstan[,"Imports"])
    imp_field <- .version_comb(imp_field[imp_field[,"pkg"] != "rstantools",])
    desc_rstan[,"Imports"] <- imp_field
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
