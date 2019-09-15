#--- test rstan_create_package -----------------------------------------------

# 1. create package under various conditions
# 2. pkgload::load_all package
# 3. run tests on package
# 4. delete package source

# setup
run_all_tests <- FALSE # if TRUE disables skip_on_cran and skip_on_travis
source("rstan_package_skeleton-testfunctions.R") # helper functions to run tests
pkg_name <- "RStanTest" # base name of package
# path to base directory where packages will be created
tmp_test_path <- TRUE # put all tests in temporary folder
if(tmp_test_path) test_path <- tempfile(pattern = "rstantools_")
dir.create(test_path, recursive = TRUE)
rand_path <- TRUE # randomize destination path
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
# package C++ files
src_files <- file.path(pkg_src_path, "AddTest.cpp")

# various test conditions
test_descr <- expand.grid(
  ## create_package = c(TRUE, FALSE), # use create_package or package_skeleton
  create_package = TRUE, # package_skeleton now depreciated
  roxygen = c(TRUE, FALSE) # use roxygen for documentation
)
ntest <- nrow(test_descr)

# run tests
for(ii in 1:ntest) {
  if(rand_path) {
    pkg_dest_path <- file.path(test_path,
                               basename(tempfile(pattern = pkg_name)),
                               pkg_name)
  } else {
    pkg_dest_path <- file.path(test_path, pkg_name)
  }
  # specific test condition
  use_create_package <- test_descr$create_package[ii]
  use_roxygen <- test_descr$roxygen[ii]
  context(paste0(
    ifelse(use_create_package,
           yes = "rstan_create_package",
           no = "rstan_package_skeleton"),
    " -- ",
    ifelse(use_roxygen, "with", "without"),
    " roxygen")
    )
  # create package
  if(rand_path) dir.create(dirname(pkg_dest_path), recursive = TRUE)
  if(use_create_package) {
    # use rstan_create_package
    rstan_create_package(path = pkg_dest_path,
                         rstudio = FALSE, open = FALSE,
                         ## stan_files = stan_files,
                         roxygen = use_roxygen)
    # add R files
    file.copy(from = code_files,
              to = file.path(pkg_dest_path, "R", basename(code_files)))
  } else {
    stop("rstan_package_skeleton has been depreciated.")
    # use rstan_package_skeleton
    rstan_package_skeleton(name = pkg_name, path = dirname(pkg_dest_path),
                           ## stan_files = stan_files,
                           code_files = code_files,
                           roxygen = use_roxygen)
  }
  # add stan files (need to do this separately or else rstan_config complains)
  file.copy(from = stan_files,
            to = file.path(pkg_dest_path,
                           "inst", "stan", basename(stan_files)))
  # add stan/include files
  file.copy(from = incl_files,
            to = file.path(pkg_dest_path,
                           "inst", "stan", "include", basename(incl_files)))
  # add C++ files
  file.copy(from = src_files,
            to = file.path(pkg_dest_path, "src", basename(src_files)))
  rstan_config(pkg_dest_path)
  ## Rcpp::compileAttributes(pkg_dest_path)
  # install & load package
  test_that("Package loads correctly", {
    if(!run_all_tests) {
      skip_on_cran()
      skip_on_travis()
    }
    ## if(!use_roxygen) pkgbuild::compile_dll(pkg_dest_path)
    tmp <- capture.output(load_out <- pkgload::load_all(pkg_dest_path,
                                                 export_all = TRUE,
                                                 quiet = TRUE))
    expect_type(load_out, "list")
  })
  if(use_roxygen) {
    # check roxygen documentation
    # TODO: stop test if roxygen2 not found
    test_that("roxygen works properly", {
      if(!run_all_tests) {
        skip_on_cran()
        skip_on_travis()
      }
      skip_if_not_installed("roxygen2")
      ## pkgbuild::compile_dll(pkg_dest_path)
      ## devtools::document(pkg_dest_path)
      tmp <- capture.output(pkgload::unload(pkg_name))
      roxygen2::roxygenize(pkg_dest_path)
      roxygen2::roxygenize(pkg_dest_path)
      tmp <- capture.output(load_out <- pkgload::load_all(pkg_dest_path,
                                                          export_all = TRUE,
                                                          quiet = TRUE))
      expect_identical(readLines(file.path(pkg_dest_path, "NAMESPACE")),
                       readLines(file.path(pkg_src_path, "NAMESPACE")))
    })
  }
  # check that functions work as expected
  test_that("logpost_R == logpost_Stan: postsamp1", {
    if(!run_all_tests) {
      skip_on_cran()
      skip_on_travis()
    }
    compare_postsamp1()
  })
  test_that("logpost_R == logpost_Stan: postsamp2", {
    if(!run_all_tests) {
      skip_on_cran()
      skip_on_travis()
    }
    compare_postsamp2()
  })
  test_that("external C++ code works", {
    if(!run_all_tests) {
      skip_on_cran()
      skip_on_travis()
    }
    n <- sample(1:20, 1)
    x <- rnorm(n)
    y <- rnorm(n)
    expect_equal(add_test(x, y), x + y)
  })
  # uninstall + delete package
  # tmp <- capture.output(pkgload::unload(pkg_name))
  ## detach(paste0("package:", pkg_name),
  ##        unload = TRUE, character.only = TRUE)
  ## remove.packages(pkgs = pkg_name, lib = lib_path) # remove installed package
  if(rand_path) {
    unlink(dirname(pkg_dest_path),
           recursive = TRUE, force = TRUE)
  } else {
    unlink(pkg_dest_path,
           recursive = TRUE, force = TRUE)
  }
}

# make sure everything gets deleted even if there are errors
teardown(code = {
  ## if(isNamespaceLoaded(pkg_name)) {
  ##   detach(paste0("package:", pkg_name),
  ##          unload = TRUE, character.only = TRUE)
  ## }
  if(tmp_test_path) unlink(test_path, recursive = TRUE, force = TRUE)
})
