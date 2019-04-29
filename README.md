[<img src="https://raw.githubusercontent.com/stan-dev/logos/master/logo_tm.png" width=100 alt="Stan Logo"/>](http://mc-stan.org)

# rstantools

[![Travis-CI Build Status](https://travis-ci.org/stan-dev/rstantools.svg?branch=master)](https://travis-ci.org/stan-dev/rstantools)
[![codecov](https://codecov.io/gh/stan-dev/rstantools/branch/master/graph/badge.svg)](https://codecov.io/gh/stan-dev/rstantools)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/rstantools?color=blue)](https://cran.r-project.org/package=rstantools)

The __rstantools__ package provides tools for developing R packages interfacing
with [Stan](https://mc-stan.org/). The package vignettes provide guidelines and
recommendations for developers as well as a demonstration of creating a working
R package with a pre-compiled Stan program.
 
* [Guidelines for developers of R Packages interfacing with Stan](https://mc-stan.org/rstantools/articles/developer-guidelines.html)

* [Step by step guide for creating a package that depends on RStan](https://mc-stan.org/rstantools/articles/minimal-rstan-package.html)

### Resources

* [mc-stan.org/rstantools](https://mc-stan.org/rstantools) (online documentation, vignettes)
* [Ask a question](https://discourse.mc-stan.org) (Stan Forums on Discourse)
* [Open an issue](https://github.com/stan-dev/rstantools/issues) (GitHub issues for bug reports, feature requests)

### Installation


* Install from CRAN:

```r
install.packages("rstantools")
```

* Install latest development version from GitHub (requires [remotes](https://github.com/r-lib/remotes) package):

```r
if (!require("remotes")) {
  install.packages("remotes")
}
  
remotes::install_github("stan-dev/rstantools")
```

This installation from GitHub will not build the vignettes, but we recommend 
viewing the them online at [mc-stan.org/rstantools/articles](https://mc-stan.org/rstantools/articles/).
