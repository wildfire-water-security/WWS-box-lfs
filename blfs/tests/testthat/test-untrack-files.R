test_that("tracking is removed", {
  #create example repo
    tmp <- create_test_repo(box_lfs=TRUE, examples = TRUE)
    withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

    git_ignore <- file.path(tmp, ".gitignore")
    blfs_ignore <- file.path(tmp, ".blfsignore")
    path_hash <- file.path(tmp, "box-lfs/path-hash.csv")

  #remove regular file
    file <- "example-files/large-file1.txt"
    expect_message(rm_tracking(tmp, file), "been successfully untracked with Box-LFS")

    #make sure it does what we expect
      expect_false(file.exists(file.path(tmp, "box-lfs", get_tracker_name(file))))
      expect_false(file %in% readLines(git_ignore, warn=FALSE))
      expect_true(file %in% readLines(blfs_ignore, warn=FALSE))
      expect_false(file %in% read.csv(path_hash)$path)

  #remove multifile
      file <- "example-files/example-shp.shp"
      expect_message(rm_tracking(tmp, file), "been successfully untracked with Box-LFS")

      file <- "example-files/example-shp"
    #make sure it does what we expect
      expect_false(file.exists(file.path(tmp, "box-lfs", get_tracker_name(file))))
      expect_false(paste0(file, ".*") %in% readLines(git_ignore, warn=FALSE))
      expect_true(file %in% readLines(blfs_ignore, warn=FALSE))
      expect_false(file %in% read.csv(path_hash)$path)

  #try without adding back to git
      file <- "example-files/large-file2.txt"

      msg_match <- expect_cli_msg(code=rm_tracking(tmp, file, git=FALSE),
                                  msg = c("no longer be tracked by Git or Box-LFS",
                                          "been successfully untracked with Box-LFS"))
      expect_true(msg_match)

      #make sure it does what we expect
      expect_false(file.exists(file.path(tmp, "box-lfs", get_tracker_name(file))))
      expect_true(file %in% readLines(git_ignore, warn=FALSE))
      expect_true(file %in% readLines(blfs_ignore, warn=FALSE))
      expect_false(file %in% read.csv(path_hash)$path)

})
