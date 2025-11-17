# Get and format info for boxtracker file

Pulls and formats the data from a file for the boxtracker file, but does
not write to the file (see
[write.boxtracker](https://wildfire-water-security.github.io/WWS-box-lfs/reference/write.boxtracker.md))

## Usage

``` r
get.boxtracker(file, dir = NULL)
```

## Arguments

- file:

  the relative path to the file to track

- dir:

  the file path to the file directory

## Value

a data.frame with 1 row and 5 columns:

- file_path: the relative path to the file being tracked, if it's a
  multifile it will no include an extension

- box_link: the web link to the folder containing the file

- box_path: the box drive path to the folder containing the file

- size_MB: the size of the file in megabytes

- last_modified: the date and time the file was last modified

- last_changed: the date and time the file was last changed

## Examples

``` r
get.boxtracker("example-files/large-file1.txt", fs::path_package("extdata", package = "blfs"))
#>                       file_path box_link box_path  size_MB       last_modified
#> 1 example-files/large-file1.txt       NA       NA 0.000199 2025-11-17 22:38:45
#>          last_changed
#> 1 2025-11-17 22:38:47
get.boxtracker("example-files/example-shp.shp", fs::path_package("extdata", package = "blfs"))
#>                   file_path box_link box_path  size_MB       last_modified
#> 1 example-files/example-shp       NA       NA 0.000858 2025-11-17 22:38:45
#>          last_changed
#> 1 2025-11-17 22:38:47
get.boxtracker("fake-file", fs::path_package("extdata", package = "blfs"))
#>   file_path box_link box_path size_MB last_modified last_changed
#> 1 fake-file       NA       NA       0    1900-01-01   1900-01-01
```
