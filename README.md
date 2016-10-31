# rstantools

[![Travis-CI Build Status](https://travis-ci.org/stan-dev/rstantools.svg?branch=master)](https://travis-ci.org/stan-dev/rstantools)
[![codecov](https://codecov.io/gh/stan-dev/rstantools/branch/master/graph/badge.svg)](https://codecov.io/gh/stan-dev/rstantools)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rstantools?color=blue)](http://cran.r-project.org/web/packages/rstantools)

Tools for Developing R Packages Interfacing with Stan

## Installation

You can install __rstantools__ from GitHub with:

```r
if (!require("devtools"))
  install.packages("devtools")
  
devtools::install_github("stan-dev/rstantools", build_vignettes = TRUE)
```
