context("generics with no methods")
set.seed(1111)
x <- matrix(rnorm(150), 50, 3)
y <- rnorm(ncol(x))


test_that("generics without defaults ok", {
  expect_true(exists("log_lik", mode = "function"))
  expect_true(exists("posterior_predict", mode = "function"))
  expect_error(log_lik(2), "no applicable method")
  expect_error(posterior_predict(2), "no applicable method")

  expect_output(print(methods("log_lik")), "no methods found")
  expect_output(print(methods("posterior_predict")), "no methods found")
})
