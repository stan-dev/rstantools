#' @section Using the pre-compiled Stan programs in your package: The
#'   `stanmodel` objects corresponding to the Stan programs included with your
#'   package are stored in a list called `stanmodels`. To run one of the Stan
#'   programs from within an R function in your package just pass the
#'   appropriate element of the `stanmodels` list to one of the \pkg{rstan}
#'   functions for model fitting (e.g., `sampling()`). For example, for a Stan
#'   program `"foo.stan"` you would use `rstan::sampling(stanmodels$foo, ...)`.
