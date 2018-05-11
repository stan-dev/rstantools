#--- test rstan_create_package ---------------------------------------------

# 1.  create package under various conditions
# 2.  install package
# 3.  run tests on package
# 4.  detach package and uninstall

# setup
source("rstan_package_skeleton-testfunctions.R") # helper functions to run tests
pkg_name <- "RStanTest" # name of package
# path to directory where package will be created
test_path <- tempfile(pattern = "rstantools_")
dir.create(test_path, recursive = TRUE)
# path where package will be installed
lib_path <- file.path(test_path, "library")
dir.create(lib_path, recursive = TRUE)
# path to package source files
pkg_src_path <- system.file("include", "RStanTest",
                            package = "rstantools")
# package R files
code_files <- file.path(pkg_src_path, c("RStanTest-package.R", "postsamp.R"))
# package stan files
stan_files <- file.path(pkg_src_path, c("SimpleModel.stan", "SimpleModel2.stan"))
# package C++ files
src_files <- file.path(pkg_src_path, "AddTest.cpp")

# various test conditions
test_descr <- expand.grid(
  create_package = c(TRUE, FALSE), # use create_package or package_skeleton
  roxygen = c(TRUE, FALSE) # use roxygen for documentation
)
ntest <- nrow(test_descr)

# run tests
for(ii in 1:ntest) {
  if(dir.exists(file.path(test_path, pkg_name))) {
    # remove package source if it exists
    unlink(file.path(test_path, pkg_name),
           recursive = TRUE, force = TRUE)
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
  if(use_create_package) {
    # use rstan_create_package
    rstan_create_package(path = file.path(test_path, pkg_name),
                         rstudio = FALSE, open = FALSE,
                         stan_files = stan_files)
    # add R files
    file.copy(from = code_files,
              to = file.path(test_path, pkg_name, "R", basename(code_files)))
  } else {
    # use rstan_package_skeleton
    rstan_package_skeleton(name = pkg_name, path = test_path,
                           stan_files = stan_files, code_files = code_files)
  }
  # add C++ files
  file.copy(from = src_files,
            to = file.path(test_path, pkg_name, "src", basename(src_files)))
  Rcpp::compileAttributes(file.path(test_path, pkg_name))
  # enable roxygen documentation
  if(use_roxygen) {
    # TODO: stop test if devtools not found
    test_that("roxygen works properly", {
      skip_on_cran()
      devtools::document(file.path(test_path, pkg_name))
      expect_identical(readLines(file.path(test_path, pkg_name, "NAMESPACE")),
                       readLines(file.path(pkg_src_path, "NAMESPACE")))
    })
  }
  # install & load package
  test_that("Package installs correctly", {
    skip_on_cran()
    install.packages(pkgs = file.path(test_path, pkg_name),
                     lib = lib_path, repos = NULL,
                     type = "source", quiet = TRUE)
    expect_true(library(package = pkg_name, lib.loc = lib_path,
                        character.only = TRUE, quietly = TRUE,
                        logical.return = TRUE))
  })
  # check that functions work as expected
  test_that("logpost_R == logpost_Stan: postsamp1", {
    skip_on_cran()
    compare_postsamp1()
  })
  test_that("logpost_R == logpost_Stan: postsamp2", {
    skip_on_cran()
    compare_postsamp2()
  })
  test_that("external C++ code works", {
    skip_on_cran()
    n <- sample(1:20, 1)
    x <- rnorm(n)
    y <- rnorm(n)
    expect_equal(add_test(x, y), x + y)
  })
  # uninstall + delete package
  ## detach(paste0("package:", pkg_name),
  ##        unload = TRUE, character.only = TRUE)
  ## remove.packages(pkgs = pkg_name, lib = lib_path) # remove installed package
}

# make sure everything gets deleted even if there are errors
## teardown(code = {
  ## if(isNamespaceLoaded(pkg_name)) {
  ##   detach(paste0("package:", pkg_name),
  ##          unload = TRUE, character.only = TRUE)
  ## }
##   unlink(test_path, recursive = TRUE, force = TRUE)
## })
