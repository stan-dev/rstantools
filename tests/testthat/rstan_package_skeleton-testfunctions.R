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
