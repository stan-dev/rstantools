[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/rstantools?color=blue)](https://cran.r-project.org/web/packages/rstantools)
[![Travis-CI Build Status](https://travis-ci.org/stan-dev/rstantools.svg?branch=master)](https://travis-ci.org/stan-dev/rstantools)
[![Downloads](https://cranlogs.r-pkg.org/badges/rstantools?color=blue)](https://cran.rstudio.com/package=rstantools)

<br>

<div style="text-align:left">
<span><a href="http://mc-stan.org">
<img src="https://raw.githubusercontent.com/stan-dev/logos/master/logo_tm.png" width=100 alt="Stan Logo"/> </a><h2><strong>rstantools</strong></h2><h4>Tools for developers of R packages interfacing with Stan</h4></span>
</div>

<br>
The **rstantools** package provides various tools for developers of R packages
interfacing with [Stan](https://mc-stan.org), including functions to set up the
required package structure, S3 generic methods to unify function naming across
Stan-based R packages, and vignettes with guidelines for developers.

## Getting Started

To get started building a package see the two __rstantools__ vignettes for
developers:

* [Guidelines for Developers of R Packages Interfacing with Stan](http://mc-stan.org/rstantools/articles/developer-guidelines.html)

* [Step by step guide for creating a package that depends on RStan](http://mc-stan.org/rstantools/articles/minimal-rstan-package.html)


## Installation

Install the latest release from **CRAN**

```r
install.packages("rstantools")
```

Install latest development version from GitHub (requires [remotes](https://github.com/r-lib/remotes) package):

```r
if (!require("remotes")) {
  install.packages("remotes")
}
  
remotes::install_github("stan-dev/rstantools")
```

This installation from GitHub will not build the vignettes, but we recommend 
viewing the them online at [mc-stan.org/rstantools/articles](https://mc-stan.org/rstantools/articles/).

