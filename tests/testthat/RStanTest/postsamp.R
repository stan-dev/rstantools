#' Posterior Sampler for SimpleModel
#' @export
postsamp1 <- function(x, nsamples) {
  sampling(object = stanmodels$SimpleModel, data = list(x = x),
           iter = nsamples, chains = 1)
}

#' Posterior Sampler for SimpleModel2
#' @export
postsamp2 <- function(x, nsamples) {
  sampling(object = stanmodels$SimpleModel2, data = list(x = x),
           iter = nsamples, chains = 1)
}

## #' Posterior Sampler for SimpleModel3
## #' @export
## postsamp3 <- function(x, nsamples) {
##   sampling(object = stanmodels$SimpleModel3, data = list(x = x),
##            iter = nsamples, chains = 1)
## }
