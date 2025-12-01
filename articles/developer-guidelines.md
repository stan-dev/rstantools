# Guidelines for Developers of R Packages Interfacing with Stan

## Note to developers

One of the coolest things about working on a project like Stan has been
seeing some of our users begin to develop tools for making Stan more
accessible to audiences that may otherwise not benefit from what Stan
offers. In particular, recently we have started seeing a growing number
of R packages that provide high-level interfaces to Stan, using the
[**rstan**](https://mc-stan.org/rstan/) package for estimating models
without requiring that the user be familiar with the Stan modeling
language itself.

This is a great development and we would like to support such efforts
going forward, but to-date we have made little effort to coordinate the
development of these packages. To avoid a Wild West, so to speak, of
Stan-based R packages, we think it is important that developers make
every effort to adhere to certain guidelines in order to ensure these
packages are of the highest possible quality and provide the best
possible experience for users. To that end, in this post we present a
set of recommendations for the development of R packages that interface
with Stan. These recommendations are based on software design principles
we value as well as many things we are learning as we continue
developing our own packages and review packages being developed by
others. There are exceptions to some of these recommendations (e.g., the
**brms** package is a sensible exception to one of guidelines about Stan
code), but we strongly recommend trying to follow them whenever
possible.

These recommendations are not set in stone. We expect them to evolve and
we very much appreciate feedback on how they can be improved. And, of
course, we look forward to seeing the packages you develop using Stan,
so please let us know about them!

## Guidelines for R packages providing interfaces to Stan

### General package structure and development

- The **rstantools** package provides the
  [`rstan_create_package()`](https://mc-stan.org/rstantools/reference/rstan_create_package.md)
  function, which you should use to create the basic structure of your
  package. (As of `v2.0.0` this replaces the `rstan_package_skeleton`
  function.) This will set up a package with functionality for
  pre-compiled Stan programs, in the style of the
  [**rstanarm**](https://mc-stan.org/rstanarm/) package (source code:
  <https://github.com/stan-dev/rstanarm>).

- Use version control (e.g., git).

- Unless you are developing proprietary private software, organize your
  code in a repository that is *public* on [GitHub](https://github.com/)
  (or a similar service, but preferably GitHub). It should be public
  even at early stages of development, not only when officially
  released. We recommend you add a note to your README file on how to
  install the development version of your package, like in the
  [**bayesplot**
  README](https://github.com/stan-dev/bayesplot#installation)

- Unit testing is essential. There are several R packages that make it
  relatively easy to write tests for your package. Most of our R
  packages (e.g., **rstanarm**, **brms**, **bayesplot**, **shinystan**,
  **loo** and others) use the
  [**testthat**](https://github.com/r-lib/testthat) package for this
  purpose, but if you prefer a different testing framework that’s fine.
  The [**covr**](https://github.com/r-lib/covr) package is useful for
  calculating the line coverage of your tests, and we recommend reaching
  a high level of coverage before releasing a package. Good line
  coverage does not guarantee high quality tests, but it’s a good first
  step. We also recommend setting up automatic testing of your package
  using GitHub Actions. See <https://github.com/r-lib/actions> for
  useful templates.

### Stan code

- All Stan code for estimating models should be included in pre-written
  static `.stan` files that are compiled when the package is built (see
  the Stan programs directory in the **rstanarm** repo for examples).
  You can also use subdirectories to include code chunks to be used in
  multiple `.stan` files (again see the **rstanarm** repo for examples).
  If you set up your package using `rstan_create_package` this structure
  will be created for you. This means that **your package should NOT
  write a Stan program when the user calls a model fitting function in
  your package**, but rather use only Stan programs you have written by
  hand in advance (if you are working on a model for which you don’t
  think this is possible please let us know). There are several reasons
  for this.

- Pre-compiled Stan programs can be run by users of Windows or Mac OSX
  without having to install a C++ compiler, which dramatically expands
  the universe of potential users for your package.

- Pre-compiled Stan programs will run immediately when called, avoiding
  compilation time.

- CRAN policy permits long installation times but imposes restrictions
  on the time consumed by examples and unit tests that are much shorter
  than the time that it takes to compile even a simple Stan program.
  Thus, it is only possible to adequately test your package if it has
  pre-compiled Stan programs.

- Pre-compiled Stan programs can use custom C++ functions.

To provide flexibility to users, your Stan programs can include
branching logic (conditional statements) so that even with a small
number of .stan files you can still allow for many different
specifications to made by the user (see the .stan files in **rstanarm**
for examples).

- Use best practices for Stan code. If the models you intend to
  implement are discussed in the Stan manual or on the Stan users forum
  then you should follow any recommendations that apply to your case. If
  you are unsure whether your Stan programs can be made more efficient
  or more numerically stable then please ask us on the Stan users forum.
  Especially ask us if you are unsure whether your Stan programs are
  indeed estimating the intended model.

- Relatedly, prioritize safety over speed in your Stan code and sampler
  settings. For example, if you can write a program that runs faster but
  is potentially less stable, then at a minimum you should make the more
  stable version the default. This also means that, with rare
  exceptions, you should not change our recommended MCMC defaults
  (e.g. 4 chains, 1000+1000 iterations, NUTS not static HMC), unless you
  are setting the defaults to something more conservative. **rstanarm**
  even goes one step further, making the default value of the
  `adapt_delta` tuning parameter at least 0.95 for all models (rather
  than **rstan**’s default of 0.8) in order to reduce the step size and
  therefore also limit the potential for divergences. This means that
  **rstanarm** models may often run a bit slower than they need to if
  the user doesn’t change the defaults, but it also means that users
  face fewer situations in which they need to know how to change the
  defaults and what the implications of changing the defaults really
  are.

### R code and documentation

- Functions/methods that provide useful post-estimation functionality
  should be given the same names as the corresponding functions in
  **rstanarm** (if applicable). For example,
  [`posterior_predict()`](https://mc-stan.org/rstantools/reference/posterior_predict.md)
  to draw from the posterior predictive distribution,
  [`posterior_interval()`](https://mc-stan.org/rstantools/reference/posterior_interval.md)
  for posterior uncertainty intervals, etc. To make this easier, these
  and similar **rstanarm** functions have been converted to S3 methods
  for the stanreg objects created by **rstanarm** and the S3 generic
  functions are included here in the **rstantools** package. Your
  package should import the generics from **rstantools** for whichever
  functions you want to include in your package and then provide methods
  for the fitted model objects returned by your model-fitting functions.
  For some other functions (e.g. `as.matrix`) the generics are already
  available in base R or core R packages. To be clear, we are not saying
  that the naming conventions used in **rstanarm**/**rstantools** are
  necessarily optimal. (If you think that one of our function names
  should be changed please let us know and suggest an alternative. If it
  is a substantial improvement we may consider renaming the function and
  deprecating the current version.) Rather, this guideline is intended
  to make function names consistent across Stan-based R packages, which
  will improve the user experience for those users who want to take
  advantage of a variety of these packages. It will be a mess if every R
  package using Stan has different names for the same functionality.

- The [**bayesplot**](https://mc-stan.org/bayesplot/) package serves as
  the back-end for plotting for **rstanarm** (see for example
  `pp_check.stanreg` and `plot.stanreg`), **brms**, and other packages,
  and we hope developers of other Stan-based R packages will also use
  it. You can see all the other R packages using **bayesplot** in the
  *Reverse dependencies* section of the **bayesplot** [CRAN
  page](https://CRAN.R-project.org/package=bayesplot). For any plot you
  intend to include in your package, if it is already available in
  **bayesplot** then we recommend using the available version or
  suggesting (or contributing) a better version. If it is not already
  available then there is a good chance we will be interested in
  including it in **bayesplot** if the plot would also be useful for
  other developers.

- The [**posterior**](https://mc-stan.org/posterior/) package (new
  in 2021) provides state of the art posterior inference diagnostics,
  various summaries of draws in convenient formats, and functionality
  for converting between (and manipulating) many different useful
  formats of draws from posterior or prior distributions. We recommend
  using this functionality in your package or recommending it to your
  users.

- Take documentation seriously. The documentation won’t be perfect (we
  constantly find holes in the doc for the R packages in the Stan
  ecosystem), but you should make every effort to provide clear and
  thorough documentation.

### Recommended resources

- Hadley Wickham and Jenny Bryan’s [book on R
  packages](https://r-pkgs.org/). If you are interested in developing an
  R package that interfaces with Stan but are not an experienced package
  developer, we recommend this book, which is free to read online. Even
  if you are an experienced developer of R packages, the book is still a
  great resource.

- If you need help setting up your package or have questions about these
  guidelines the best places to go are the [Stan
  Forums](https://discourse.mc-stan.org) and the [GitHub issue
  tracker](https://github.com/stan-dev/rstantools/issues) for the
  **rstantools** package.
