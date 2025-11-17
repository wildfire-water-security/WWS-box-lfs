# Get file location or other data from boxtracker

The .boxtracker files stores the relative location of the file, the box
link, and file info (size, dates last modified and changed). This
function is used to easily read and extract data from those files.

## Usage

``` r
read.boxtracker(tracker, dir = NULL, return = "all")
```

## Arguments

- tracker:

  the name of the file with the .boxtracker extension (should be a hash)

- dir:

  the file path to the file directory

- return:

  the column to return. options are: file_path, box_link, size_MB,
  last_modified, last_changed

## Value

- if `return` is "all" will return a data.frame

- otherwise will return a vector of length one with the column value

## Examples

``` r
read.boxtracker("1678f723cb201eb3f9996c01a481dd0e",
fs::path_package("extdata", package = "blfs"))
#>                       file_path
#> 1 example-files/large-file1.txt
#>                                                         box_link
#> 1 https://oregonstate.box.com/s/h9g8q6n8lj3u2bwhaalepb0lc28te4n5
#>                                                                             box_path
#> 1 /Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects/data-management/box-lfs
#>    size_MB       last_modified        last_changed
#> 1 0.000201 2025-08-02 10:12:32 2025-08-07 17:18:26
read.boxtracker("1678f723cb201eb3f9996c01a481dd0e",
fs::path_package("extdata", package = "blfs"), return = "size_MB")
#> [1] 0.000201
```
