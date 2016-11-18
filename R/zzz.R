.onAttach <- function(...) {
  ver <- utils::packageVersion("rstantools")
  packageStartupMessage("This is rstantools version ", ver)
}
