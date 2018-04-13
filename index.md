[![Travis-CI Build Status](https://travis-ci.org/stan-dev/rstantools.svg?branch=master)](https://travis-ci.org/stan-dev/rstantools)
[![codecov](https://codecov.io/gh/stan-dev/rstantools/branch/master/graph/badge.svg)](https://codecov.io/gh/stan-dev/rstantools)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rstantools?color=blue)](http://cran.r-project.org/web/packages/rstantools)

<br><br>

<div style="text-align:left">
<br>
<a href="http://mc-stan.org">
<img src="https://raw.githubusercontent.com/stan-dev/logos/master/logo.png" width=100 alt="Stan Logo"/> </a><h2><strong>rstantools</strong></h1>
<h4>Tools for developers of R packages interfacing with Stan</h4>
</div>

<br>
The **rstantools** package provides various tools for developers of R packages
interfacing with [Stan](http://mc-stan.org), including functions to set up the
required package structure, S3 generic methods to unify function naming across
Stan-based R packages, and vignettes with guidelines for developers.

## Getting Started

To get started building a package see the two __rstantools__ vignettes for
developers:

* [Guidelines for Developers of R Packages Interfacing with Stan](http://mc-stan.org/rstantools/articles/developer-guidelines.html)

* [Step by step guide for creating a package that depends on RStan](http://mc-stan.org/rstantools/articles/minimal-rstan-package.html)

<br>

## Installation

Install the latest release from **CRAN**

```r
install.packages("rstantools")
```

Install the latest development version from **GitHub**

```r
if (!require("devtools")) {
  install.packages("devtools")
}

devtools::install_github("stan-dev/rstantools", build_vignettes = TRUE)
```
