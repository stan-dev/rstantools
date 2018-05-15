#--- test rstan_config ---------------------------------------------

context("rstan_config")

# 0.  setup
# 1.  create empty package
# 2.  add stan files, check contents
# 3.  rerun config, check that file.mtimes are identical
# 4.  create fake .o files to mimick contents of src without compiling package.  also add other files to src.
# 5.  remove one stan file, rerun config, check that files are removed and other files are the same.
# 6.  delete package source

#--- 0.  setup -----------------------------------------------------------------

# helper functions to run tests
source("rstan_package_skeleton-testfunctions.R")
pkg_name <- "RStanTest" # name of package
# path to directory where package will be created
test_path <- tempfile(pattern = "rstantools_")
dir.create(test_path, recursive = TRUE)
pkg_dest_path <- file.path(test_path, pkg_name)
# path to package source files
pkg_src_path <- system.file("include", "RStanTest",
                            package = "rstantools")
# package R files
code_files <- file.path(pkg_src_path, "postsamp.R")
# package stan files
stan_files <- file.path(pkg_src_path, c("SimpleModel.stan", "SimpleModel2.stan"))

#--- 1.  create package --------------------------------------------------------

rstan_create_package(path = pkg_dest_path,
                     rstudio = FALSE, open = FALSE,
                     stan_files = character(), roxygen = FALSE,
                     license = FALSE, auto_config = FALSE)
# copy R files
file.copy(from = code_files,
          to = file.path(pkg_dest_path, "R", basename(code_files)))

#--- 2.  add stan files, check contents ----------------------------------------

# copy stan files
file.copy(from = stan_files,
          to = file.path(pkg_dest_path, "inst", "stan",
                         basename(stan_files)))

# check that md5sums match those on record
test_that("Stan src files are created properly", {
  rstan_config(pkg_dest_path)
  for(stan_file in stan_files) {
    check_md5(stan_file,
              pkg_src_path = pkg_src_path,
              pkg_dest_path = pkg_dest_path)
  }
})

#--- 3.  rerun config, check that file.mtimes are identical --------------------

test_that("Unmodified Stan src files are not overwritten", {
  pre_mtime <- lapply(stan_files, check_mtime, pkg_dest_path = pkg_dest_path)
  pre_mtime <- do.call(c, pre_mtime)
  rstan_config(pkg_dest_path)
  post_mtime <- lapply(stan_files, check_mtime, pkg_dest_path = pkg_dest_path)
  post_mtime <- do.call(c, post_mtime)
  expect_identical(pre_mtime, post_mtime)
})

#--- 4.  create fake .o files and other src files ------------------------------

# fake .o files
invisible(sapply(gsub("\\.stan$", "", basename(stan_files)), function(sf) {
  cat("fake .o file\n",
      file = file.path(pkg_dest_path, "src",
                       rstantools:::.stan_prefix(sf, ".o")))
}))

# dummy src files
src_files <- c("foo.cpp", "stanExports_foo.txt", "abcstanExports_foo.cc")
invisible(sapply(src_files, function(sf) {
  cat("// fake source file\n",
      file = file.path(pkg_dest_path, "src", sf))
}))


#--- 5.  remove one stan file, rerun config ------------------------------------

test_that("src is properly updated after removing inst/stan files", {
  # check modification time of all files in src
  pre_files <- list.files(file.path(pkg_dest_path, "src"),
                          full.names = TRUE)
  pre_mtime <- file.mtime(pre_files)
  # remove files associated with one stan file
  rm_file <- sample(basename(stan_files), 1) # file to remove
  file.remove(file.path(pkg_dest_path, "inst", "stan", rm_file))
  rstan_config(pkg_dest_path) # re-configure
  # calculate modification times
  post_files <- list.files(file.path(pkg_dest_path, "src"), full.names = TRUE)
  post_mtime <- file.mtime(post_files)
  # deduce which of pre_files should remain
  rm_file <- tools::file_path_sans_ext(rm_file)
  pre_filter <- !grepl(paste0("^stanExports_", rm_file, "\\.(cc|h|o)"),
                   basename(pre_files))
  expect_identical(pre_files[pre_filter], post_files)
  # now check modification times
  pre_filter <- pre_filter & (basename(pre_files) != "RcppExports.cpp")
  post_filter <- basename(post_files) != "RcppExports.cpp"
  expect_identical(pre_mtime[pre_filter], post_mtime[post_filter])
})

#--- 6.  delete package source -------------------------------------------------

unlink(pkg_dest_path, recursive = TRUE, force = TRUE)

#--- scratch -------------------------------------------------------------------

## sf <- "stanExports_SimpleModel.h"
## setNames(c(tools::md5sum(file.path(pkg_dest_path, sf)),
##            tools::md5sum(file.path(pkg_dest_path, "src", sf)),
##            tools::md5sum(file.path(pkg_src_path, sf))), NULL)
