# Check for updated Box LFS files when pulling a GitHub repository

Run AFTER pulling files from GitHub.

## Usage

``` r
pull_repo_blfs(dir = NULL, download = NULL, boxdrive = TRUE)
```

## Arguments

- dir:

  the file path to the file directory

- download:

  the file path to the download directory (if NULL will default to the
  Box Drive path)

- boxdrive:

  logical, should Box drive be used?

## Value

Checks for:

- tracked files in the local directory that are newer than the tracker
  and prompts upload

- tracked files that are new or newer on Box than the local directory
  and prompts download

## Details

When you pull the updates from a GitHub repository that has large files
tracked with Box LFS you also may need to update those files. This
function will check the status of the tracked files in your local
repository and determine if there are any files that uploaded or
downloaded to maintain the current version.

## Examples

``` r
 #create temp dir to modify files cleanly
  tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = FALSE,
  source_dir = system.file("extdata", package = "blfs"))

  box_tmp <- blfs:::create_test_boxdrive(source_dir = system.file("extdata", package = "blfs"))

  #put in new file path to "box"
   blfs:::add_box_loc(box_tmp, dir=tmp, type="path")

pull_repo_blfs(dir=tmp, download=box_tmp)
#> ✔ Large files have been fetched from Box and put in repository.
#> ✔ Large files have been synced with Box.

 unlink(box_tmp, recursive = TRUE)
 unlink(tmp, recursive = TRUE)
```
