[<img src="https://raw.githubusercontent.com/stan-dev/logos/master/logo_tm.png" width=100 alt="Stan Logo"/>](http://mc-stan.org)

# rstantools

[![Travis-CI Build Status](https://travis-ci.org/stan-dev/rstantools.svg?branch=master)](https://travis-ci.org/stan-dev/rstantools)
[![codecov](https://codecov.io/gh/stan-dev/rstantools/branch/master/graph/badge.svg)](https://codecov.io/gh/stan-dev/rstantools)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rstantools?color=blue)](http://cran.r-project.org/web/packages/rstantools)

The __rstantools__ package provides tools for developing R packages interfacing
with [Stan](http://mc-stan.org/). The package vignettes provides guidelines and
recommendations for developers as well as a demonstration of creating a working
package with a pre-compiled Stan program.
 
* [Guidelines for Developers of R Packages Interfacing with Stan](http://mc-stan.org/rstantools/articles/developer-guidelines.html)

* [Step by step guide for creating a package that depends on RStan](http://mc-stan.org/rstantools/articles/minimal-rstan-package.html)

### Resources

* [mc-stan.org/rstantools](http://mc-stan.org/rstantools) (online documentation, vignettes)
* [Ask a question](http://discourse.mc-stan.org) (Stan Forums on Discourse)
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
  
remotes::install_github("stan-dev/rstantools", build_opts = "")
```
