context("rstan_package_skeleton")

if (requireNamespace("rstan", quietly = TRUE)) { # FIXME when travis can install rstan again
  rstan_package_skeleton(
    name = "testPackage",
    path = tempdir(),
    stan_files = test_path("test.stan"),
    force = TRUE
  )
  pkg_path <- file.path(tempdir(), "testPackage")
  pkg_files <- list.files(pkg_path, recursive = TRUE, all.files = TRUE)

  test_that("package directory has correct name", {
    expect_true(dir.exists(pkg_path))
  })

  test_that("package directory has required structure", {
    nms <- c("DESCRIPTION", "inst", "man", "NAMESPACE", "R",
             "Read-and-delete-me", "src", "tools", "testPackage.Rproj")
    ans <- list.files(pkg_path)
    if ("data" %in% ans) {
      nms <- c(nms, "data")
    }
    expect_equal(sort(nms), sort(ans))
  })
  test_that(".travis.yml file included", {
    expect_true(".travis.yml" %in% pkg_files)

    travis <- readLines(file.path(pkg_path, ".travis.yml"))
    expect_false(any(grepl("rstanarm", travis)))
    expect_true(any(grepl("testPackage", travis)))
  })
  test_that(".Rbuildignore file included", {
    expect_true(".Rbuildignore" %in% pkg_files)
  })
  test_that(".stan file included", {
    expect_true("src/stan_files/test.stan" %in% pkg_files)
  })
  test_that("R/stanmodels.R file included", {
    expect_true("R/stanmodels.R" %in% pkg_files)
  })
  test_that("src/init.cpp file included", {
    expect_true("src/init.cpp" %in% pkg_files)
    init <- readLines(file.path(pkg_path, "src/init.cpp"))
    expect_true(any(grepl("R_init_testPackage", init)))
  })

  test_that("messages are generated", {
    expect_message(
      rstan_package_skeleton(
        name = "testPackage2",
        path = tempdir(),
        stan_files = test_path("test.stan"),
        force = TRUE
      ),
      regexp = "Creating package skeleton for package: testPackage2"
    )
    expect_message(
      rstan_package_skeleton(
        name = "testPackage3",
        path = tempdir(),
        stan_files = c("test.stan"),
        force = TRUE
      ),
      regexp = "Finished skeleton for package: testPackage3"
    )
  })

  test_that("error if stan_files specified incorrectly", {
    expect_error(
      rstan_package_skeleton(
        name = "testPackage4",
        path = tempdir(),
        stan_files = c("test"),
        force = TRUE
      ),
      regexp = "must end with a '.stan' extension",
      fixed = TRUE
    )

    expect_error(
      rstan_package_skeleton(
        name = "testPackage4",
        path = tempdir(),
        stan_files = c("test.stan", "test"),
        force = TRUE
      ),
      regexp = "must end with a '.stan' extension",
      fixed = TRUE
    )
  })
}
