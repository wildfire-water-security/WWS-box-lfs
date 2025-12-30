test_that("updated files are prompted to upload automatically", {
  #create temp dir to modify files cleanly
    tmp <- create_test_repo(box_lfs=TRUE)
    withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

    box_tmp <- create_test_boxdrive(files=FALSE)
    withr::defer(unlink(box_tmp, recursive = TRUE), envir = parent.frame())

    with_mocked_bindings(
      get_box_drive = function() box_tmp,
      {
        #test pull, expect files will look the same because they're exactly the same size
          msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                      msg = c("Checking for large files that need",
                                              "Large files are already synced with Box"))
          expect_true(msg_match)

        #test pull, with an updated local file -> prompts upload
          name <- "example-files/large-file2.txt"
          create_updated_file(name, tmp)

          msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                      msg = c("Checking for large files that need", 
                                              "Copying updated files to Box",
                                              "Large files are now backed up in Box",
                                              "Large files have been synced with Box"))
          expect_true(msg_match)

      })

})

test_that("updated files are prompted to upload manually", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  with_mocked_bindings(
    get_box_drive = function() FALSE,
    {
      #test pull, expect files will look the same because they're exactly the same size
      msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                  msg = c("Checking for large files that need",
                                          "Large files are already synced with Box"))
      expect_true(msg_match)

      #test pull, with an updated local file -> prompts upload
      name <- "example-files/large-file2.txt"
      create_updated_file(name, tmp)

      msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                  msg = c("Checking for large files that need",
                                          "Please upload files from",
                                          "Large files are now backed up",
                                          "Large files have been synced with Box"))
      expect_true(msg_match)

    })

})

test_that("new files are box are downloaded automatically", {

  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  box_tmp <- create_test_boxdrive(files=FALSE)
  withr::defer(unlink(box_tmp, recursive = TRUE), envir = parent.frame())

  with_mocked_bindings(
    get_box_drive = function() box_tmp,
    {
      #test pull, expect files will look the same because they're exactly the same size
      msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                  msg = c("Checking for large files that need", 
                                          "Large files have been synced with Box"))
     # expect_true(msg_match)

      #test pull, with an updated local file -> prompts upload
      name <- "example-files/example-shp"
      hash <- "3f80f3c380f48192c6fcd63a08813c49.zip"
      create_download_file(name, tmp)

      #put in new file path to "box"
      add_box_loc(box_tmp, dir=tmp, type="path")

      msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                  msg = c("Checking for large files that need", 
                                          "Downloading files from Box",
                                          "Large files have been fetched from Box",
                                          "Large files have been synced with Box"))
      expect_true(msg_match)

      #make sure all files are there
      expect_length(list.files(file.path(tmp, "example-files"), "example-shp"), 5)

    })

})

test_that("updated files are downloaded manually", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  with_mocked_bindings(
    get_box_drive = function() FALSE,
    {
      #test pull, expect files will look the same because they're exactly the same size
      msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                  msg = c("Checking for large files that need",
                                          "Large files are already synced with Box"))
      expect_true(msg_match)

      #test pull, with an updated local file -> prompts upload
      name <- "example-files/large-file2.txt"
      create_download_file(name, tmp)
      msg_match <- expect_cli_msg(code=pull_repo_blfs(tmp),
                                  msg = c("Checking for large files that need", 
                                          "Please download files from Box here",
                                          "Downloading files from Box",
                                          "Large files have been fetched from Box",
                                          "Large files have been synced with Box"))
      expect_true(msg_match)

    })

})

