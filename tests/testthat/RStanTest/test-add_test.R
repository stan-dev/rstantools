context("add_test")

test_that("external C++ code works", {
  n <- sample(1:20, 1)
  x <- rnorm(n)
  y <- rnorm(n)
  expect_equal(add_test(x, y), x + y)
})
