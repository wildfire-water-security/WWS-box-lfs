# Main Box LFS Functions (with Box Drive)

If you have [Box Drive](https://www.box.com/resources/downloads)
installed on your computer, **Box LFS** can automatically move files
between your local project repository and Box. This is highly
recommended as it will simplify the management of your large files.

**Not sure if you’ve got Box Drive installed?**

``` r
#remotes::install_github("r-box/boxrdrive")
library(boxrdrive)
dr_box_drive()
```

    #> ✔ Box Drive installation found.
    #> ✔ Box Drive directory available at 'C:/Users/jsmith/Box'.

> If it’s installed but not available, try running the Box Drive app
> from your start bar.

Below we’ll explore the main `blfs` functions that you will use to
maintain versioning and backups of your large files.

------------------------------------------------------------------------

## Start Tracking Large Files

If you already have a folder you want to turn into a GitHub repository
(repo) that uses Box for large files, start with:

``` r
  new_repo_blfs(dir = new_dir, size = 0.0001, box_dir = box_tmp_upld, boxdrive = TRUE) 
```

- `dir` is the folder you want to set up.

- `size` is the minimum size (in MB) that counts as a “large” file.
  Default is **10 MB**, but here we use a small number so our example
  files are included.

- If you don’t specify `box_dir`, you’ll be prompted for the **Box
  path** to the project folder this is the file path to the folder where
  you want your files stored.

  

### What you’ll see when you run `new_repo_blfs()`

1.  **Warning about large files**

        #> ℹ the following files will no longer be tracked by git:
        #> example-files/example-shp.*
        #> example-files/large-file1.txt
        #> example-files/large-file2.txt

    This is **expected** — these files are now tracked by Box, not
    GitHub.

2.  **Prompt asking for the Box file path**

        #> what is the Box path to the project folder?

    This will tell Box LFS where to upload your files to.

3.  **Message telling you your files are now backed up**

        #> ✔ Large files are now backed up in Box.

  

### File structure before running `new_repo_blfs()`

    #> ~/new_dir
    #> ├── README.md
    #> └── example-files
    #>     ├── example-shp.cpg
    #>     ├── example-shp.dbf
    #>     ├── example-shp.prj
    #>     ├── example-shp.shp
    #>     ├── example-shp.shx
    #>     ├── large-file1.txt
    #>     └── large-file2.txt

  

### File structure after running `new_repo_blfs()`

    #> ~/new_dir
    #> ├── README.md
    #> ├── box-lfs
    #> │   ├── 1678f723cb201eb3f9996c01a481dd0e.boxtracker
    #> │   ├── 3f80f3c380f48192c6fcd63a08813c49.boxtracker
    #> │   ├── 4fa7622e82d068a0a994eafb564e4f5d.boxtracker
    #> │   ├── path-hash.csv
    #> │   └── upload
    #> │       ├── 1678f723cb201eb3f9996c01a481dd0e.txt
    #> │       ├── 3f80f3c380f48192c6fcd63a08813c49.zip
    #> │       └── 4fa7622e82d068a0a994eafb564e4f5d.txt
    #> └── example-files
    #>     ├── example-shp.cpg
    #>     ├── example-shp.dbf
    #>     ├── example-shp.prj
    #>     ├── example-shp.shp
    #>     ├── example-shp.shx
    #>     ├── large-file1.txt
    #>     └── large-file2.txt

**What’s new?**

- There’s a new folder, `box-lfs` which contains:

  - `.boxtracker` pointer files (these replace the large files in
    GitHub).

  - An `upload` folder with the real large files, renamed to **hashes**
    (unique ID codes) so files with the same name don’t overwrite each
    other.

  - A `path-hash.csv` file that links the hash back to the original file
    name and location.

- There’s a new file, `README.md`, the landing page for the repository
  which alerts users that Box LFS is being used.

- One of the tracked files is a `.shp` file with multiple files, this
  gets stored on Box as a `.zip` since a change to any of these files
  could affect the `.shp` file.

------------------------------------------------------------------------

## Cloning a GitHub repository using Box LFS

When you clone a GitHub repo that uses **Box LFS**, you get the code and
`.boxtracker` pointer files — but not the big files themselves. To
download those files and put them in the right place, run:

``` r
clone_repo_blfs(dir=clone_dir, download=tempdir())
```

- `dir` is the folder with the cloned repository.

  

### What you’ll see when you run `clone_repo_blfs()`

1.  **Message telling you your large files have been fetched:**

        #> ✔ Large files have been fetched from Box and put in repository.

**With this, your cloned repo will have the correct large files in the
right locations.**

  

### Check if a repo uses Box LFS

You can check by running:

``` r
check_blfs(clone_dir)
#> [1] TRUE
```

If it says `TRUE`, the repo uses **Box LFS**.

  

### File structure before running `clone_repo_blfs()`

    #> ~/clone_dir
    #> ├── README.md
    #> └── box-lfs
    #>     ├── 1678f723cb201eb3f9996c01a481dd0e.boxtracker
    #>     ├── 3f80f3c380f48192c6fcd63a08813c49.boxtracker
    #>     ├── 4fa7622e82d068a0a994eafb564e4f5d.boxtracker
    #>     ├── path-hash.csv
    #>     └── upload
    #>         ├── 1678f723cb201eb3f9996c01a481dd0e.txt
    #>         ├── 3f80f3c380f48192c6fcd63a08813c49.zip
    #>         └── 4fa7622e82d068a0a994eafb564e4f5d.txt

  

### File structure after running `clone_repo_blfs()`

    #> ~/clone_dir
    #> ├── README.md
    #> ├── box-lfs
    #> │   ├── 1678f723cb201eb3f9996c01a481dd0e.boxtracker
    #> │   ├── 3f80f3c380f48192c6fcd63a08813c49.boxtracker
    #> │   ├── 4fa7622e82d068a0a994eafb564e4f5d.boxtracker
    #> │   ├── path-hash.csv
    #> │   └── upload
    #> │       ├── 1678f723cb201eb3f9996c01a481dd0e.txt
    #> │       ├── 3f80f3c380f48192c6fcd63a08813c49.zip
    #> │       └── 4fa7622e82d068a0a994eafb564e4f5d.txt
    #> └── example-files
    #>     ├── example-shp.cpg
    #>     ├── example-shp.dbf
    #>     ├── example-shp.shp
    #>     ├── example-shp.shx
    #>     ├── large-file1.txt
    #>     │   └── 1678f723cb201eb3f9996c01a481dd0e.txt
    #>     └── large-file2.txt
    #>         └── 4fa7622e82d068a0a994eafb564e4f5d.txt

------------------------------------------------------------------------

## Pushing a GitHub repository using Box LFS

**Before** you push changes to a repository that uses Box LFS, you need
to:

1.  Check if any **tracked files** have been updated.

2.  See if there are **new large files** that should be tracked.

You can do both with:

``` r
push_repo_blfs(dir=clone_dir, size=0.0001)
```

- `dir` is your local repository folder.
- `size` is the minimum file size (in MB) that counts as a “large” file.
  Default is **10 MB**.
- Here we use a smaller number so our example files are included.

  

### What you’ll see when you run `push_repo_blfs()`:

1.  **Message telling you files have been synced**

        #> ✔ Large files have been synced with Box.

    > If **new** files have been added since the last push, you’ll also
    > see a warning message similar to
    > [`new_repo_blfs()`](https://wildfire-water-security.github.io/WWS-box-lfs/reference/new_repo_blfs.md)
    > about files no longer being tracked with **Git**.

2.  **Do this next:**

    - Push your Git repository as normal.
      - The updated `.boxtracker` files will tell other users that
        there’s new files to grab from Box.

------------------------------------------------------------------------

## Pulling a GitHub repository using Box LFS

**After** you pull changes from a GitHub repository that uses Box LFS,
you need to:

1.  Check if any **tracked files** have been updated on Box.

2.  Check if any local tracked files should be pushed before downloading
    the updated files.

You can do both with:

``` r
pull_repo_blfs(dir=clone_dir, download=tempdir())
```

- `dir` is your local repository folder.
- `download` is the folder with the downloaded `.zip` file.

  

### What you’ll see when you run `pull_repo_blfs()`:

1.  **Message telling you your large files have been fetched:**

        #> ✔ Large files have been fetched from Box and put in repository.
        #> ✔ Large files have been synced with Box.

> This function is uploading any new versions of tracked files to make
> sure you don’t lose your work, and then it will get the newest version
> of any files.
