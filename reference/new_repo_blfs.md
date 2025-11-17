# Start using Box LFS on a new project

Use if you have an existing directory that you want to start tracking
with git and put on GitHub. It will set up the file structure, identify
files that should be tracked, and prompt user to upload those files to
Box.

## Usage

``` r
new_repo_blfs(dir = NULL, size = 10, box_dir = NULL, boxdrive = TRUE)
```

## Arguments

- dir:

  the file path to the file directory

- size:

  the minimum file size in megabytes to track

- box_dir:

  the file path to the project within Box

- boxdrive:

  logical, should Box drive be used?

## Value

Creates the following files in `dir`:

- box-lfs: to store the .boxtracker files

- upload: put copies of tracked files for easy uploading to Box

- \*.boxtracker: the tracker files for each large file

Also adds the tracked files and the /box-lfs/upload file to .gitignore.

## Details

Box LFS works similar to git lfs where large files are tracked using a
tracking file (.boxtracker) which keeps track of the file location and
it's version. Any files larger than the specified size (default is 10
MB) will be added to .gitignore and the user will be prompted to upload
those files to Box and supply the Box link to those files.

## Examples

``` r
tmp <- withr::local_tempdir()
new_repo_blfs(tmp)
#> Error in dir_check(dir): dir.exists(dir) is not TRUE
```
