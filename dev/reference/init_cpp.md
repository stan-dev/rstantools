# Register functions implemented in C++

If you set up your package using
[`rstan_package_skeleton()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
before version `1.2.1` of rstantools it may be necessary for you to call
this function yourself in order to pass `R CMD check` in R `>= 3.4`. If
you used
[`rstan_package_skeleton()`](https://mc-stan.org/rstantools/dev/reference/rstan_create_package.md)
in rstantools version `1.2.1` or later then this has already been done
automatically.

## Usage

``` r
init_cpp(name, path)
```

## Arguments

- name:

  The name of your package as a string.

- path:

  The path to the root directory for your package as a string. If not
  specified it is assumed that this is already the current working
  directory.

## Value

This function is only called for its side effect of writing the
necessary `init.cpp` file to the package's `src/` directory.
