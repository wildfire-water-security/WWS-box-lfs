
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

The functions in this package are designed to accompany git commands
(ie. init, clone, pull, push) to perform the necessary steps to keep the
Box files synced.

## Installation

You can install `blfs` from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("wildfire-water-security/WWS-box-lfs", subdir="blfs")
library(blfs)
```

## Creating a new git repository

If you have an existing directory you’d like to turn into a Git
repository stored on GitHub, start by running `new_repo_blfs()`. This
function sets up the necessary file structure for Box LFS and begins
tracking large files.

Here’s what the file structure of this directory looks like **before**
we run `new_repo_blfs()`. We can see two files in a sub-directory
(example-files).

    #> ~/new_dir
    #> └── example-files
    #>     ├── large-file1.txt
    #>     └── large-file2.txt

The `size` argument sets the minimum file size (in MB) for a file to be
tracked as “large”; the default is 10 MB. In this example, we’ll use a
lower threshold (`size = 0.0001`) because our example “large” files are
much smaller than 10 MB.

``` r
#start using box-lfs
  new_repo_blfs(dir = new_dir, size = 0.0001) 
```

Here’s what the file structure of this directory looks like **after** we
run `new_repo_blfs()`:

    #> ~/new_dir
    #> ├── box-lfs
    #> │   ├── 1678f723cb201eb3f9996c01a481dd0e.boxtracker
    #> │   ├── 4fa7622e82d068a0a994eafb564e4f5d.boxtracker
    #> │   ├── path-hash.csv
    #> │   └── upload
    #> │       ├── 1678f723cb201eb3f9996c01a481dd0e.txt
    #> │       └── 4fa7622e82d068a0a994eafb564e4f5d.txt
    #> ├── example-files
    #> │   ├── large-file1.txt
    #> │   └── large-file2.txt
    #> └── README.md

Notice we now have a box-lfs folder which now has tracker files
(`.boxtracker`) and files ready to upload in the upload folder. You may
also notice that the files have these long strings of numbers and letter
instead of the nice text names. These are called **hashes** and are used
to uniquely identify each file to prevent overwriting files with the
same name that are in different folders or have different extensions.

### Outputs from `new_repo_blfs`

Running `new_repo_blfs` produces several informative outputs:

1.  **Warning: large files are no longer tracked by Git**

        #> Warning in new_repo_blfs(dir = new_dir, size = 2e-04): the following files will no longer be tracked by git:
        #>     example-files/large-file1.txt
        #>     example-files/large-file2.txt

    You’ll see a warning that `large-file1.txt` and `large-file2.txt`
    are no longer tracked by Git. This is expected: these files are now
    tracked by Box via a lightweight pointer system. The warning ensures
    you’re aware that version control for these files now relies on
    **this package**, not Git

2.  **Message: upload files to Box**

        #> Please upload files from 'example-repo-abc123/box-lfs/upload' to Box here:
        #> 'Wildfire_Water_Security/02_Nodes/your node/Projects/example-repo-abc123/box-lfs'

    The function copies large files into a new folder at:
    `project/box-lfs/upload/`. This is where you’ll find the files ready
    for manual upload. The message will also tell you exactly where to
    upload these files on Box:

    - Navigate to your appropriate **node folder** on Box within the WWS
      directory.

    - Inside its `projects` folder, create (if it doesn’t already exist)
      a folder with your project name (e.g., `example-repo-*`).

    - Inside your project folder, create a folder named **box-lfs**.

    - Upload the files from `upload/` into this **box-lfs** folder.

3.  **Prompt: link your Box folder**

        #> what is the box link to the folder where the data is now backed up?

    If you’re running the code interactively, the function will prompt
    you for the **Box link** to the folder where you’ve uploaded your
    files (e.g.,
    [`https://oregonstate.app.box.com/folder/334380637898`](https://oregonstate.app.box.com/folder/334380637898)).
    This link will be stored in the tracker file, allowing the package
    to locate and fetch files as needed in the future.

## Cloning a GitHub repository using Box LFS

If you clone a GitHub repository that’s using Box LFS to track it’s
large files, you’ll need to download those files manually from Box and
get them in the correct file location. This can be achieved using
`clone_repo_blfs()`.

**Not sure if a repo is using Box LFS?**

It should be noted in the `README.md` for the repository or you can also
run the function `check_blfs()`. For instance we can check on our
example directory

``` r
check_blfs(clone_dir)
#> [1] TRUE
```

Once we know Box LFS is being used we can run `clone_repo_blfs()`. But
first lets have a look at what the cloned directory looks like
**before** we run `clone_repo_blfs()`:

    #> ~/clone_dir
    #> └── box-lfs
    #>     ├── 1678f723cb201eb3f9996c01a481dd0e.boxtracker
    #>     ├── 4fa7622e82d068a0a994eafb564e4f5d.boxtracker
    #>     └── path-hash.csv

You can see we only have the box-lfs folder with our `.boxtracker` files
and a `.csv` which links the hash names to file paths. Now lets run
`clone_repo_blfs()` to get the tracked files into our clone repository.

``` r
clone_repo_blfs(dir=clone_dir, download=dwd)
```

Now we can look at what the cloned directory looks like **after** we run
`clone_repo_blfs()`:

    #> ~/clone_dir
    #> ├── box-lfs
    #> │   ├── 1678f723cb201eb3f9996c01a481dd0e.boxtracker
    #> │   ├── 4fa7622e82d068a0a994eafb564e4f5d.boxtracker
    #> │   └── path-hash.csv
    #> └── example-files
    #>     ├── large-file1.txt
    #>     └── large-file2.txt

Now we have a new folder: example-files which has the tracked files. So
the function successfully grabbed the files from the `.zip` file and put
them in the correct file location.

### Outputs from `clone_repo_blfs`

Running `clone_repo_blfs` produces several informative outputs:

1.  **Message: download files from Box**

        #> Please download files from Box here:
        #> 'Wildfire_Water_Security/02_Nodes/your node/Projects/example-repo-abc123/box-lfs'
        #> they will be automatically moved to the correct locations from your downloads folder

    This tells you where the tracked files should be located on Box. If
    a Box link was stored in the `.boxtracker` files, it will provide
    that instead.

        #> Please download files from Box here:
        #> https://oregonstate.app.box.com/folder/334380637898
        #> they will be automatically moved to the correct locations from your downloads folder

    At this point, the user needs to go to Box, located the folder and
    download it. Box will download the folder as a `.zip` file, this
    folder can be downloaded to the default downloads folder, as this is
    where the function expects it to be.

2.  **Prompt: once files are downloaded**

        #> hit any key once files have been downloaded to continue setting up the repo

    This prompt simply serves to pause the script from continuing to run
    until the files have been downloaded.

3.  **Prompt: check download file path**

        #> Zip file for downloaded data appears to be: ~/Downloads/box-lfs-zip.zip
        #> Press enter to use this file or provide a different file path.

    This prompt tells the user where the script thinks the downloaded
    files are located, and allows the user to correct it if needed. If
    the location is correct, the user can just hit enter and the script
    will finish running.
