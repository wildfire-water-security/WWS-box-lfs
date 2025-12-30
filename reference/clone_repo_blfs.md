# Get files after cloning a repo that uses Box LFS

If you want to clone a Github repository that uses Box LFS, you'll need
to manually download the tracked files from Box so you have them in your
repository. This code will prompt you to download the Box files, then
place them in the correct files in your repository using the .boxtracker
files.

## Usage

``` r
clone_repo_blfs(dir = NULL, download = NULL, boxdrive = TRUE)
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

Prompts user to download the files from Box and then places them in the
correct location in the `dir` folder

## Examples

``` r
 #create temp dir to modify files cleanly
  tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = FALSE,
  source_dir = system.file("extdata", package = "blfs"))

  box_tmp <- blfs:::create_test_boxdrive(source_dir = system.file("extdata", package = "blfs"))

  #put in new file path to "box"
   blfs:::add_box_loc(box_tmp, dir=tmp, type="path")

  clone_repo_blfs(dir=tmp, download=box_tmp)
#> ℹ Copying files from Box to the correct file locations...
#> ℹ No large files were found to move to repository.

  #remove temp dirs
  unlink(box_tmp, recursive = TRUE)
  unlink(tmp, recursive = TRUE)
```
