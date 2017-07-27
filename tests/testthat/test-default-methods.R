context("default methods")
set.seed(1111)
x <- matrix(rnorm(150), 50, 3)
y <- rnorm(ncol(x))

test_that("posterior_interval.default hasn't changed", {
  expect_equal_to_reference(
    posterior_interval(x, prob = 0.5),
    "posterior_interval.RDS"
  )
})
test_that("predictive_interval.default hasn't changed", {
  expect_equal_to_reference(
    predictive_interval(x, prob = 0.8),
    "predictive_interval.RDS"
  )
})
test_that("predictive_error.default works", {
  expect_equal_to_reference(
    predictive_error(x, y),
    "predictive_error.RDS"
  )
})
test_that("prior_summary.default works", {
  obj <- list(prior.info = "prior info")
  expect_identical(prior_summary(obj), obj[[1]])

  expect_null(prior_summary(list(abc = "prior_info")))
})
test_that("loo_pit.default works", {
  lw <- matrix(rnorm(150), 50, 3)
  expect_equal_to_reference(
    loo_pit(x, y, lw),
    "loo_pit.RDS"
  )
})
test_that("bayes_R2.default hasn't changed", {
  expect_equal_to_reference(
    bayes_R2(x, y),
    "bayes_R2.RDS"
  )
})

test_that("default methods throw correct errors", {
  expect_error(posterior_interval(1:10), "should be a matrix")
  expect_error(predictive_interval(1:10), "should be a matrix")
  expect_error(predictive_error(1:10, 1:10), "should be a matrix")
  expect_error(bayes_R2(1:10, 1:10), "should be a matrix")
  expect_error(bayes_R2(cbind(1:10, 1:10), 1:9),
               "ncol(object) == length(y) is not TRUE",
               fixed = TRUE)
})


# helper functions --------------------------------------------------------
test_that(".central_intervals returns correct structure", {
  a <- .central_intervals(x, prob = 0.5)
  expect_equal(dim(a), c(ncol(x), 2))
  expect_identical(colnames(a), c("25%", "75%"))
})
test_that("central_intervals throws errors", {
  err_msg <- "'prob' should be a single number greater than 0 and less than 1"
  expect_error(.central_intervals(x, prob = c(0.5, 0.25)), err_msg)
  expect_error(.central_intervals(x, prob = 0, err_msg))
  expect_error(.central_intervals(x, prob = 1, err_msg))
})
test_that(".central_intervals returns correct structure", {
  a <- .central_intervals(x, prob = 0.5)
  expect_equal(dim(a), c(ncol(x), 2))
  expect_identical(colnames(a), c("25%", "75%"))
})

test_that(".pred_errors returns correct structure", {
  err <- .pred_errors(x, y)
  expect_true(is.matrix(err))
  expect_equal(dim(err), dim(x))
})
test_that(".pred_errors throws errors", {
  expect_error(.pred_errors(x, y[-1]), "length(y) == ncol(object) is not TRUE",
               fixed = TRUE)
  expect_error(.pred_errors(x[,1], y), "is.matrix(object) is not TRUE",
               fixed = TRUE)
})


