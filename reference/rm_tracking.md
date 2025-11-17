# Stop tracking a file with Box LFS

Removes the boxtracker file, adds to .blfsignore, and optionally removes
it from .gitignore so that git will start tracking it again.

## Usage

``` r
rm_tracking(dir, file, git = TRUE, box = FALSE)
```

## Arguments

- dir:

  the file path to the file directory

- file:

  the relative file path to the file to stop tracking

- git:

  logical, should the file be tracked by git again?

- box:

  logical, should the file be removed from Box?

## Value

a message indicating that the file has been successfully untracked

## Examples

``` r
#create temp dir to modify files cleanly
  tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = TRUE,
  source_dir = system.file("extdata", package = "blfs"))

  rm_tracking(tmp, "example-files/large-file1.txt")
#> ✔ example-files/large-file1.txt has been successfully untracked with Box-LFS
  rm_tracking(tmp, "example-files/example-shp.shp", git=FALSE)
#> ! example-files/example-shp will no longer be tracked by Git or Box-LFS
#> ✔ example-files/example-shp has been successfully untracked with Box-LFS

  #remove temp dirs
  unlink(tmp, recursive = TRUE)
```
