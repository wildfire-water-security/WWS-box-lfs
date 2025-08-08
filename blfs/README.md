
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Box Large File Storage

<!-- badges: start -->

<!-- badges: end -->

`blfs` (Box Large File Storage) is an R package designed to simplify
working with large files in GitHub repositories. By default, GitHub does
not support uploading files larger than 100 MB. While Git LFS extends
this limit to 2 GB, it has its own limitations—storage is capped for
free accounts, and even deleted files remain permanently tied to the
repository’s history. Fully removing them often requires recreating the
repository, which means losing commit history.

For the Wildfire and Water Security (WWS) project, we have access to
unlimited storage on Box within the shared directory. `blfs` allows us
to leverage this storage while retaining the version control and
collaboration benefits of Git and GitHub.

Like Git LFS, `blfs` uses lightweight **pointer files** to track large
files. These `.boxtracker` files are version-controlled in GitHub and
contain metadata that points to the actual file stored in Box.

Due to current organizational limitations, full automation of syncing
between GitHub, the local repository, and Box isn’t possible. However,
this package provides tools to make the process as streamlined and
user-friendly as possible.

## Installation

You can install `blfs` from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("wildfire-water-security/WWS-box-lfs", subdir="blfs")
#> Using GitHub PAT from the git credential store.
#> Downloading GitHub repo wildfire-water-security/WWS-box-lfs@HEAD
#> 
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>          checking for file 'C:\Users\wampleka\AppData\Local\Temp\RtmpSkoIgl\remotesa3005d82c55\wildfire-water-security-WWS-box-lfs-5b046be\blfs/DESCRIPTION' ...  ✔  checking for file 'C:\Users\wampleka\AppData\Local\Temp\RtmpSkoIgl\remotesa3005d82c55\wildfire-water-security-WWS-box-lfs-5b046be\blfs/DESCRIPTION'
#>       ─  preparing 'blfs':
#>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#>       ─  checking for empty or unneeded directories
#>      Omitted 'LazyData' from DESCRIPTION
#>       ─  building 'blfs_0.1.0.tar.gz'
#>      
#> 
#> Installing package into 'C:/Users/wampleka/AppData/Local/Temp/RtmpchXGsM/temp_libpathac18ed6191'
#> (as 'lib' is unspecified)
library(blfs)
```

## How to Use box-lfs

The functions in this package are designed to accompany git commands
(ie. init, clone, pull, push) to perform the necessary steps to keep the
Box files synced.

### Creating a new git repository

If you have an existing directory that you would like to turn into a git
repository stored on GitHub, you’ll first want to run `new_repo_blfs`
which will create the necessary file structure for box-lfs and start
tracking any large files. The argument `size` determines the minimum
file size to track. The default is 10 MB. For this example we’ll use
0.0002 MB because our example “large” files are much smaller than 20 MB.

``` r
#setting up clean stucture for running example 
    #create temp dir so files don't get cluttered
      tmp <- withr::local_tempdir(pattern = "example-repo-")
  
    #copy files to repo (example files that live in repo we want to track)
    data_path <- file.path(fs::path_package("extdata", package = "blfs"), "example-files")
    copy <- file.copy(data_path, tmp, recursive = TRUE)

#start using box-lfs
  new_repo_blfs(dir = tmp, size = 0.0002)
#> Warning in new_repo_blfs(dir = tmp, size = 2e-04): the following files will no longer be tracked by git:
#> Please upload files from 'example-repo-a300198e3a5a/box-lfs/upload' to Box here:
#> 'Wildfire_Water_Security/02_Nodes/your node/Projects/example-repo-a300198e3a5a/box-lfs'
```

We get several outputs from running this function:

1.  **We get a warning that large-file1.txt and large-file2.txt will no
    longer be tracked by git.**

- That’s because we’re now going to be tracking them with the pointer
  file and Box. This is just to make sure the user knows that they now
  need to use this package to maintain version history instead of git.

2.  **We get a message to upload files.**

- The message tells the user to look in the project directory for files
  in project/box-lfs/upload. The function copies the files that will be
  tracked here, so the user can upload them to Box.
- The message also tells the user where to put these files on Box. These
  files should live within the projects folder of the appropriate node
  folder.
- Specifically, inside the project folders, if it doesn’t already exist,
  create a folder with your project name (in this case it’s the name of
  the temporary folder we created, example-repo-\*). Then create a
  folder called **box-lfs**. The tracked files should be uploaded here.

If you run the the code interactively, the function will prompt you for
the box link to the folder where you uploaded your tracked files to.
Providing this link (ie.
<https://oregonstate.app.box.com/folder/334380637898>) will update the
tracker files so we know where to find the file on Box.
