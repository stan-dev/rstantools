require(rstan) # for log_prob & unconstrain_pars

stan_quiet <- function(expr) {
  suppressMessages(suppressWarnings(expr))
}

context("postsamp")

test_that("postsamp1: logposterior", {
  # data
  x <- rnorm(1)
  logpost <- stan_quiet(postsamp1(x = x, nsamples = 1))
  # parameter values
  nsim <- sample(20:30, 1)
  Pars <- replicate(n = nsim, expr = {
    list(mu = rnorm(1))
  }, simplify = FALSE)
  # log-posterior in R
  lpR <- sapply(1:nsim, function(ii) {
    mu <- Pars[[ii]]$mu
    dnorm(x, mu, 1, log = TRUE)
  })
  # log-posterior in stan
  lpStan <- sapply(1:nsim, function(ii) {
    upars <- unconstrain_pars(object = logpost, pars = Pars[[ii]])
    log_prob(object = logpost, upars = upars, adjust_transform = FALSE)
  })
  expect_equal(max(abs(diff(lpR-lpStan))), 0, tolerance = 1e-6)
})

test_that("postsamp2: logposterior", {
  # data
  x <- rnorm(1)
  logpost <- stan_quiet(postsamp2(x = x, nsamples = 1))
  # parameter values
  nsim <- sample(20:30, 1)
  Pars <- replicate(n = nsim, expr = {
    list(sigma = runif(1, .2, 4))
  }, simplify = FALSE)
  # log-posterior in R
  lpR <- sapply(1:nsim, function(ii) {
    sigma <- Pars[[ii]]$sigma
    dnorm(x, 0, sigma, log = TRUE)
  })
  # log-posterior in stan
  lpStan <- sapply(1:nsim, function(ii) {
    upars <- unconstrain_pars(object = logpost, pars = Pars[[ii]])
    log_prob(object = logpost, upars = upars, adjust_transform = FALSE)
  })
  expect_equal(max(abs(diff(lpR-lpStan))), 0, tolerance = 1e-6)
})
