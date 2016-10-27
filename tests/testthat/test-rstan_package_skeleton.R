context("rstan_package_skeleton")

rstan_package_skeleton(
  name = "testPackage",
  path = tempdir(),
  stan_files = c("test.stan"),
  force = TRUE
)
pkg_path <- file.path(tempdir(), "testPackage")

test_that("package directory has correct name", {
  expect_true(dir.exists(pkg_path))
})
test_that("package directory has required structure", {
  expect_equal_to_reference(
    list.files(pkg_path, recursive = FALSE),
    "pkg_skeleton.RDS"
  )
})
test_that(".stan file included", {
  expect_true("exec/test.stan" %in% list.files(pkg_path, recursive = TRUE))
})
