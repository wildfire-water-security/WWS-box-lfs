test_that("repo gets set up with box drive", {
  #create temp dir to modify files cleanly
    tmp <- create_test_repo(box_lfs=TRUE)
    withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

    box_tmp <- create_test_boxdrive(files=FALSE)
    withr::defer(unlink(box_tmp, recursive = TRUE), envir = parent.frame())

  #run looking for large files (expect file structure but that's it)
    expect_message(new_repo_blfs(dir = tmp,box_dir=box_tmp), "No large files found.")
    expect_true(setequal(list.files(tmp), c("README.md", "box-lfs", "example-files")))
    expect_length(list.files(box_tmp, recursive = TRUE), 0)

    with_mocked_bindings(
      get_box_drive = function() box_tmp,
      {
        #run looking for example files
          msg_match <- expect_cli_msg(code=new_repo_blfs(dir = tmp, size=0.0002,box_dir=box_tmp),
                                      msg = c("the following files will no longer be tracked",
                                              "Large files are now backed up"))
          expect_true(msg_match)

        #check it does as expected
          hashes <- c("1678f723cb201eb3f9996c01a481dd0e", "4fa7622e82d068a0a994eafb564e4f5d")
          expect_true(setequal(list.files(tmp), c("README.md", "box-lfs", "example-files")))
          expect_equal(list.files(file.path(tmp, "box-lfs")), c(paste0(hashes, ".boxtracker"),
                                                                "path-hash.csv", "upload"))
          expect_equal(list.files(file.path(tmp, "box-lfs/upload")), paste0(hashes, ".txt"))

          #ensure files get copied to box
          expect_equal(list.files(file.path(box_tmp, "box-lfs")), paste0(hashes, ".txt"))

      })

})


test_that("repo gets set up manually", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  #run looking for large files (expect file structure but that's it)
  expect_message(new_repo_blfs(dir = tmp), "No large files found.")
  expect_true(setequal(list.files(tmp), c("README.md", "box-lfs", "example-files")))

  with_mocked_bindings(
    get_box_drive = function() FALSE,
    {
      #run looking for example files
      msg_match <- expect_cli_msg(code=new_repo_blfs(dir = tmp, size=0.0002,box_dir=box_tmp),
                                  msg = c("the following files will no longer be tracked",
                                          "Please upload files from",
                                          "Large files are now backed up"))
      expect_true(msg_match)

      #check it does as expected
      hashes <- c("1678f723cb201eb3f9996c01a481dd0e", "4fa7622e82d068a0a994eafb564e4f5d")
      expect_true(setequal(list.files(tmp), c("README.md", "box-lfs", "example-files")))
      expect_equal(list.files(file.path(tmp, "box-lfs")), c(paste0(hashes, ".boxtracker"),
                                                            "path-hash.csv", "upload"))
      expect_equal(list.files(file.path(tmp, "box-lfs/upload")), paste0(hashes, ".txt"))


    })

})
