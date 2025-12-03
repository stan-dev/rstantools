# Helper function for loading code in roxygenise

Adapted from the `sourceDir` function defined by `example(source)`.

## Usage

``` r
rstantools_load_code(path, trace = TRUE, ...)
```

## Arguments

- path:

  Path to directory containing code to load

- trace:

  Whether to print file names as they are loaded

- ...:

  Additional arguments passed to
  [`source`](https://rdrr.io/r/base/source.html)

## Value

`NULL`
