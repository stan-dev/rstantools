library(testthat)
library(rstantools)

foo <- function(x) {"test function"}

test_check("rstantools")

# if (identical(Sys.getenv("TRAVIS"), "true")) {
#   test_check("rstantools", filter = "methods")
# } else {
#   test_check("rstantools")
# }

