# run things silently
eval_quiet <- function(expr, no_warnings = FALSE) {
  if(no_warnings) {
    suppressMessages(suppressWarnings(expr))
  } else {
    suppressMessages(expr)
  }
}

eval_quiet(require(rstan)) # for log_prob & unconstrain_pars


#---------------------------------------------------------------------------

# return R and Stan log-posteriors for same parameter values

# R/Stan diff check for postsamp1
compare_postsamp1 <- function() {
  # simulate data
  x <- rnorm(1)
  logpost <- eval_quiet(postsamp1(x = x, nsamples = 1), no_warnings = TRUE)
  # parameter values
  ntest <- sample(20:30, 1)
  Pars <- replicate(n = ntest, expr = {
    list(mu = rnorm(1))
  }, simplify = FALSE)
  # log-posterior in R
  lpR <- sapply(1:ntest, function(ii) {
    mu <- Pars[[ii]]$mu
    dnorm(x, mu, 1, log = TRUE)
  })
  # log-posterior in Stan
  lpStan <- sapply(1:ntest, function(ii) {
    upars <- unconstrain_pars(object = logpost, pars = Pars[[ii]])
    log_prob(object = logpost, upars = upars, adjust_transform = FALSE)
  })
  # check that they differ by only a constant
  expect_equal(max(abs(diff(lpR-lpStan))), 0, tolerance = 1e-6)
}

# R/Stan diff check for postsamp2
compare_postsamp2 <- function() {
  # simulate data
  x <- rnorm(1)
  logpost <- eval_quiet(postsamp2(x = x, nsamples = 1), no_warnings = TRUE)
  # parameter values
  ntest <- sample(20:30, 1)
  Pars <- replicate(n = ntest, expr = {
    list(sigma = runif(1, .2, 4))
  }, simplify = FALSE)
  # log-posterior in R
  lpR <- sapply(1:ntest, function(ii) {
    sigma <- Pars[[ii]]$sigma
    dnorm(x, 0, sigma, log = TRUE)
  })
  # log-posterior in Stan
  lpStan <- sapply(1:ntest, function(ii) {
    upars <- unconstrain_pars(object = logpost, pars = Pars[[ii]])
    log_prob(object = logpost, upars = upars, adjust_transform = FALSE)
  })
  # check that they differ by only a constant
  expect_equal(max(abs(diff(lpR-lpStan))), 0, tolerance = 1e-6)
}

#-------------------------------------------------------------------------------

# check contents of src files
check_lines <- function(stan_file, pkg_src_path, pkg_dest_path) {
  sf <- sub("\\.stan$", "", basename(stan_file))
  for(ext in c(".cc", ".h")) {
    src_files <- rstantools:::.stan_prefix(sf, ext)
    src_files <- c(file.path(pkg_src_path, src_files),
                   file.path(pkg_dest_path, "src", src_files))
    # v3
    expect_known_output(object = cat(readLines(src_files[2]), sep = "\n"),
                        file = src_files[1])
    ## # v2
    ## expect_identical(readLines(src_files[1]), readLines(src_files[2]))
    ## # v1
    ## src_md5 <- tools::md5sum(src_files)
    ## names(src_md5) <- NULL
    ## expect_identical(src_md5[1], src_md5[2])
  }
}

# check modification times for src files
check_mtime <- function(stan_file, pkg_dest_path) {
  sf <- sub("\\.stan$", "", basename(stan_file))
  src_files <- rstantools:::.stan_prefix(sf, c(".cc", ".h"))
  file.mtime(file.path(pkg_dest_path, "src", src_files))
}

#-------------------------------------------------------------------------------

# unload, uninstall, and delete source for given package
remove_package <- function(pkg_name, pkg_path, lib_path,
                           unload = TRUE,
                           uninstall = TRUE,
                           unlink = TRUE) {
  if(unload && isNamespaceLoaded(pkg_name)) {
    # unload package from R session
    detach(paste0("package:", pkg_name),
           unload = TRUE, character.only = TRUE)
  }
  if(uninstall && dir.exists(file.path(lib_path, pkg_name))) {
    # uninstall package
    remove.packages(pkg_name, lib_path)
  }
  if(unlink && dir.exists(file.path(pkg_path, pkg_name))) {
    unlink(file.path(pkg_path, pkg_name), recursive = TRUE, force = TRUE)
  }
}
