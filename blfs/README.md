
<!-- README.md is generated from README.Rmd. Please edit that file -->

# blfs

<!-- badges: start -->

[![R-CMD-check](https://github.com/wildfire-water-security/WWS-box-lfs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/wildfire-water-security/WWS-box-lfs/actions/workflows/R-CMD-check.yaml)

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

You can install the development version of blfs from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("wildfire-water-security/WWS-box-lfs", subdir="blfs")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(blfs)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
