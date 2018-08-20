# context("rstan_package_skeleton")
#
# if (requireNamespace("rstan", quietly = TRUE)) { # FIXME when travis can install rstan again
#   rstan_package_skeleton(
#     path = file.path(tempdir(), "testPackage"),
#     stan_files = testthat::test_path("test.stan")
#   )
#   pkg_path <- file.path(tempdir(), "testPackage")
#   pkg_files <- list.files(pkg_path, recursive = TRUE, all.files = TRUE)
#
#   test_that("package directory has correct name", {
#     expect_true(dir.exists(pkg_path))
#   })
#
#   test_that("package directory has required structure", {
#     nms <- c("DESCRIPTION", "inst", "man", "NAMESPACE", "R",
#              "Read-and-delete-me", "src", "tools")
#     ans <- list.files(pkg_path)
#     cat(ans, sep = "\n")
#     expect_equal(sort(nms), sort(ans))
#   })
#   test_that(".travis.yml file included", {
#     expect_true(".travis.yml" %in% pkg_files)
#
#     travis <- readLines(file.path(pkg_path, ".travis.yml"))
#     expect_false(any(grepl("rstanarm", travis)))
#     expect_true(any(grepl("testPackage", travis)))
#   })
#   test_that(".Rbuildignore file included", {
#     expect_true(".Rbuildignore" %in% pkg_files)
#   })
#   test_that(".stan file included", {
#     expect_true("src/stan_files/test.stan" %in% pkg_files)
#   })
#   test_that("R/stanmodels.R file included", {
#     expect_true("R/stanmodels.R" %in% pkg_files)
#   })
#   test_that("src/init.cpp file included", {
#     expect_true("src/init.cpp" %in% pkg_files)
#     init <- readLines(file.path(pkg_path, "src/init.cpp"))
#     expect_true(any(grepl("R_init_testPackage", init)))
#   })
#
#   test_that("messages are generated", {
#     expect_message(
#       rstan_package_skeleton(
#         path = file.path(tempdir(),"testPackage2"),
#         stan_files = test_path("test.stan")
#       ),
#       regexp = "Creating package skeleton for package: testPackage2"
#     )
#     expect_message(
#       rstan_package_skeleton(
#         path = file.path(tempdir(),"testPackage3"),
#         stan_files = test_path("test.stan")
#       ),
#       regexp = "Running usethis::create_package"
#     )
#     expect_message(
#       rstan_package_skeleton(
#         path = file.path(tempdir(),"testPackage4"),
#         stan_files = c("test.stan")
#       ),
#       regexp = "Finished skeleton for package: testPackage4"
#     )
#     expect_output(
#       rstan_package_skeleton(
#         path = file.path(tempdir(),"testPackage5"),
#         stan_files = c("test.stan")
#       ),
#       regexp = "Setting active project"
#     )
#   })
#
#   test_that("error if stan_files specified incorrectly", {
#     expect_error(
#       rstan_package_skeleton(
#         path = file.path(tempdir(),"testPackage6"),
#         stan_files = c("test")
#       ),
#       regexp = "must end with a '.stan' extension",
#       fixed = TRUE
#     )
#
#     expect_error(
#       rstan_package_skeleton(
#         path = file.path(tempdir(),"testPackage7"),
#         stan_files = c("test.stan", "test")
#       ),
#       regexp = "must end with a '.stan' extension",
#       fixed = TRUE
#     )
#   })
# }
