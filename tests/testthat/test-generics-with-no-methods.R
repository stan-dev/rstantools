context("generics with no methods")
set.seed(1111)
x <- matrix(rnorm(150), 50, 3)
y <- rnorm(ncol(x))


generics_w_no_default <-
  c(
    "log_lik",
    "posterior_predict",
    "posterior_linpred",
    "loo_predict",
    "loo_linpred",
    "loo_predictive_interval"
  )

test_that("generics without defaults ok", {
  for (f in generics_w_no_default) {
    expect_true(exists(f, mode = "function"), info = f)
    expect_error(get(f, mode = "function")(2), "no applicable method", info = f)
    expect_output(print(methods(f)), "no methods found", info = f)
  }
})
