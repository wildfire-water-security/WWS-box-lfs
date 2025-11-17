# Check for large files before pushing a Git repository

Run BEFORE pushing to GitHub.

## Usage

``` r
push_repo_blfs(dir = NULL, size = 10, boxdrive = TRUE)
```

## Arguments

- dir:

  the file path to the file directory

- size:

  the minimum file size in megabytes to track

- boxdrive:

  logical, should Box drive be used?

## Value

Identifies any new or modified files, updates the .boxtracker file and
prompts user to upload to Box

## Details

If you try to push files larger than 100 MB to GitHub you will receive
an error. This function will identify files above the size threshold. If
they are already tracked, they will be checked for updates. If there are
new files they will be tracked and the user prompted to upload to Box.

## Examples

``` r
#create temp dir to modify files cleanly
  tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = FALSE,
  source_dir = system.file("extdata", package = "blfs"))

push_repo_blfs(tmp)
#> ℹ Checking for large files that need to be updated by Box-LFS...
#> ✔ Large files have been synced with Box.

unlink(tmp, recursive = TRUE)
```
