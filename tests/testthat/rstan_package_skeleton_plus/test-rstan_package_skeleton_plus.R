# ok so what tests?

require(devtools)

license_type <- TRUE                    # true/false/custom
user_Makevars <- FALSE                  # user has Makevars (don't overwrite)
nstan <- 1                              # number of stan files: 0-2
has_code <- TRUE                        # provide code
install_tmp <- FALSE                    # install to tmp directory
auto_delete <- TRUE                     # remove existing package if found

# use_rstan

# pre-existing package called RStanTest


pkg_name <- "RStanTest"
pkg_path <- file.path(getwd())
if(install_tmp) {
  install_path <- tempfile("RStanTest_")
} else {
  install_path <- .libPaths()[1]
}

if(nstan == 0) {
  stan_files <- character(0)
} else {
  stan_files <- c("SimpleModel.stan", "SimpleModel2.stan")
  stan_files <- file.path(pkg_path, stan_files[1:nstan])
}

if(has_code) {
  code_files <- file.path(pkg_path, "postsamp.R")
} else {
  code_files <- character(0)
}

# create package
if(auto_delete) {
  # BE SUPER CAREFUL WITH THIS!!!
  system(paste0("rm -rf ", file.path(pkg_path, pkg_name)))
}
rstan_package_skeleton_plus(name = pkg_name,
                            code_files = code_files,
                            stan_files = stan_files,
                            license = license_type)
# add remaining files
if(!has_code) {
  file.copy(from = file.path(pkg_path, "postsamp.R"),
            to = file.path(pkg_path, "R", "postsamp.R"))
}

# install package
install.packages(pkg_name, repos = NULL, type = "source",
                 INSTALL_opts = "--install-tests")

# add tests
use_testthat(pkg_name)
file.copy(from = "test-postsamp.R",
          to = file.path(pkg_name, "tests", "testthat", "test-postsamp.R"))
