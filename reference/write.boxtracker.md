# Write boxtracker file

Creates the boxtracker file with a .boxtracker extension to track a file
with blfs. If the file is being created for the first time, it will
create a new line in the path-hash.csv file which links the hash names
to the file paths.

## Usage

``` r
write.boxtracker(file, dir = NULL)
```

## Arguments

- file:

  the relative path to the file to track

- dir:

  the file path to the file directory

## Value

Saves a boxtracker file to dir/box-lfs with the form file.boxtracker.
See
[get.boxtracker](https://wildfire-water-security.github.io/WWS-box-lfs/reference/get.boxtracker.md)
for details on the file structure.

## Examples

``` r
write.boxtracker("example-files/large-file1.txt", fs::path_package("extdata", package = "blfs"))
write.boxtracker("example-files/example-shp.shp", fs::path_package("extdata", package = "blfs"))
```
