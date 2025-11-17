# Package index

## Main Functions

Main functions for maintaing large files with Box LFS.

- [`new_repo_blfs()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/new_repo_blfs.md)
  : Start using Box LFS on a new project
- [`clone_repo_blfs()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/clone_repo_blfs.md)
  : Get files after cloning a repo that uses Box LFS
- [`pull_repo_blfs()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/pull_repo_blfs.md)
  : Check for updated Box LFS files when pulling a GitHub repository
- [`push_repo_blfs()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/push_repo_blfs.md)
  : Check for large files before pushing a Git repository

## Working with .boxtracker files

Functions to access, write, and read .boxtracker files.

- [`read.boxtracker()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/read.boxtracker.md)
  : Get file location or other data from boxtracker
- [`write.boxtracker()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/write.boxtracker.md)
  : Write boxtracker file
- [`get.boxtracker()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/get.boxtracker.md)
  : Get and format info for boxtracker file

## Utilities

Helper functions and internal utilities.

- [`check_blfs()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/check_blfs.md)
  : Check if Box LFS is being used on the project directory
- [`rm_tracking()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/rm_tracking.md)
  : Stop tracking a file with Box LFS
- [`is.multifile()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/is.multifile.md)
  : Determines if a file is a multifile
