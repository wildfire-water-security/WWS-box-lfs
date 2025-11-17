# Determines if a file is a multifile

Determines if a file is a multifile

## Usage

``` r
is.multifile(file, names = FALSE)
```

## Arguments

- file:

  the path to the multifile

- names:

  if TRUE, provides names and ext of the files within multifile

## Value

TRUE if multifile, otherwise FALSE

## Examples

``` r
file <- "inst/extdata/example-files/example-shp.shp"
blfs:::is.multifile(file)
#> [1] FALSE

file <- "inst/extdata/example-files/large-file1.txt"
blfs:::is.multifile(file)
#> [1] FALSE
```
