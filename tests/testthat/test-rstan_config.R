#--- test rstan_config ---------------------------------------------

context("rstan_config")

# 0.  setup
# 1.  create empty package
# 2.  add stan files and (weakly) check them via expect_known_output.
# 3.  rerun config, check that file.mtimes are identical
# 4.  create fake .o files to mimick contents of src without compiling package.  also add other files to src.
# 5.  remove one stan file, rerun config, check that files are removed and other files are the same.
# 6.  delete package source

#--- 0.  setup -----------------------------------------------------------------

run_all_tests <- FALSE # if TRUE disables skip_on_cran and skip_on_travis
backtest_stan_cpp <- FALSE # if FALSE disables check of stan cc/h files
# against what is on record.  typically this test only fails
# when the user and package stan C++ library are out of sync.
# helper functions to run tests
source("rstan_package_skeleton-testfunctions.R")
pkg_name <- "RStanTest" # name of package
# path to directory where package will be created
tmp_test_path <- TRUE # put tests in temporary folder
if(tmp_test_path) test_path <- tempfile(pattern = "rstantools_")
dir.create(test_path, recursive = TRUE)
pkg_dest_path <- file.path(test_path, pkg_name)
# path to package source files
pkg_src_path <- "RStanTest"
## pkg_src_path <- system.file("include", "RStanTest",
##                             package = "rstantools")
# package R files
code_files <- file.path(pkg_src_path, "postsamp.R")
# package stan files
stan_files <- file.path(pkg_src_path, c("SimpleModel.stan", "SimpleModel2.stan"))
# package stan/include files
incl_files <- file.path(pkg_src_path, "helper.stan")

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
# copy stan/include files
file.copy(from = incl_files,
          to = file.path(pkg_dest_path, "inst", "stan", "include",
                         basename(incl_files)))


# add Stan C++ code
rstan_config(pkg_dest_path)

# check that Stan C++ source code lines match those on record
# this should only fail when output from rstan::stanc gets modified, e.g.,
# because stan version has changed.
# subsequent runs (in interactive mode) will pass as records get overwritten.
# R CMD check will not overwrite record: see testthat::expect_known_output
if(backtest_stan_cpp) {
  test_that("Stan src files are created properly", {
    if (!run_all_tests) {
      skip_on_cran()
      skip_on_travis()
    }
    for(sf in stan_files) {
      check_lines(sf,
                  pkg_src_path = pkg_src_path,
                  pkg_dest_path = pkg_dest_path)
    }
  })
}

#--- 3.  rerun config, check that file.mtimes are identical --------------------

test_that("Unmodified Stan src files are not overwritten", {
  if (!run_all_tests) {
    skip_on_cran()
    skip_on_travis()
  }
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
  writeLines("fake .o file",
             con = file.path(pkg_dest_path, "src",
                             rstantools:::.stan_prefix(sf, ".o")))
}))

# dummy src files
src_files <- c("foo.cpp", "stanExports_foo.txt", "abcstanExports_foo.cc")
invisible(sapply(src_files, function(sf) {
  writeLines("// fake source file\n",
             con = file.path(pkg_dest_path, "src", sf))
}))


#--- 5.  remove stan file(s) rerun config --------------------------------------

test_that("src is properly updated after removing one inst/stan files", {
  if (!run_all_tests) {
    skip_on_cran()
    skip_on_travis()
  }

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

test_that("src is properly updated after removing all inst/stan files", {
  if (!run_all_tests) {
    skip_on_cran()
    skip_on_travis()
  }

  rm_files <- list.files(file.path(pkg_dest_path, "inst", "stan"),
                         pattern = "[.]stan$",
                         full.names = TRUE)
  file.remove(rm_files)
  rstan_config(pkg_dest_path) # re-configure
  curr_files <- sort(list.files(file.path(pkg_dest_path, "src"),
                                full.names = TRUE))
  exp_files <- sort(file.path(pkg_dest_path, "src", src_files))
  expect_identical(curr_files, exp_files)
})

#--- 6.  delete package source -------------------------------------------------

unlink(pkg_dest_path, recursive = TRUE, force = TRUE)

# make sure everything gets deleted even if there are errors
teardown(code = {
  if(tmp_test_path) unlink(test_path, recursive = TRUE, force = TRUE)
})


#--- scratch -------------------------------------------------------------------

## sf <- "stanExports_SimpleModel.h"
## setNames(c(tools::md5sum(file.path(pkg_dest_path, sf)),
##            tools::md5sum(file.path(pkg_dest_path, "src", sf)),
##            tools::md5sum(file.path(pkg_src_path, sf))), NULL)
