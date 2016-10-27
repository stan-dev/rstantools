context("rstan_package_skeleton")

rstan_package_skeleton(
  name = "testPackage",
  path = tempdir(),
  stan_files = c("test.stan"),
  force = TRUE
)
pkg_path <- file.path(tempdir(), "testPackage")
pkg_files <- list.files(pkg_path, recursive = TRUE)

test_that("package directory has correct name", {
  expect_true(dir.exists(pkg_path))
})

test_that("package directory has required structure", {
  expect_equal(
    sort(list.files(pkg_path)),
    sort(c("cleanup", "cleanup.win", "DESCRIPTION", "exec", "inst", "man",
      "NAMESPACE", "R", "Read-and-delete-me", "src", "tools"))
  )
})
test_that(".stan file included", {
  expect_true("exec/test.stan" %in% pkg_files)
})
test_that("R/stanmodels.R file included", {
  expect_true("R/stanmodels.R" %in% pkg_files)
})
