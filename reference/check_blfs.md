# Check if Box LFS is being used on the project directory

Check if Box LFS is being used on the project directory

## Usage

``` r
check_blfs(dir = NULL)
```

## Arguments

- dir:

  the file path to the file directory

## Value

A value of TRUE if Box LFS is being used or FALSE if it is not

## Examples

``` r
check_blfs(fs::path_package("extdata", package = "blfs"))
#> [1] TRUE
```
