test_that("adding a new file works manually", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

    #check push repo (the first time we do see the files are "modified")
    with_mocked_bindings(
      get_box_drive = function() FALSE,
      {
        #run first time, files are exactly the same size, so shouldn't provide message
          msg_match <- expect_cli_msg(code=push_repo_blfs(tmp, size=0.0002),
                                      msg = c("Checking for large files that need",
                                              "Large files are already synced with Box"))
          expect_true(msg_match)
        
        #add a file
          new_file <- "example-files/large-file3.txt"
          file_txt <- paste0(sample(1:10000, size=1000), collapse = "")
          write.table(file_txt, file.path(tmp, new_file))

        #see if it gets flagged
          msg_match <- expect_cli_msg(code=push_repo_blfs(tmp, size=0.0002),
                                      msg = c("Checking for large files", "large-file3",
                                              "Please upload files from",
                                              "Large files have been synced with Box."))
          expect_true(msg_match)


        #make sure a box.tracker is written
          tracker <- get_tracker_name(new_file)
          expect_true(file.exists(file.path(tmp, "box-lfs", tracker)))

        })
})


test_that("modifying a files works automatically", {
  #create temp dir to modify files cleanly
    tmp <- create_test_repo(box_lfs=TRUE)
    withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

    box_tmp <- create_test_boxdrive(files=FALSE)
    withr::defer(unlink(box_tmp, recursive = TRUE), envir = parent.frame())

  #put in new file path to "box"
    add_box_loc(basename(box_tmp), dir=tmp, type="path")

    with_mocked_bindings(
      get_box_drive = function() dirname(box_tmp),
      {
        name <- "example-files/example-shp"
        hash <- "3f80f3c380f48192c6fcd63a08813c49.zip"

        old <- file.info(file.path(tmp, "box-lfs/upload/", hash))

        #check push repo, should check but not see any differences
          msg_match <- expect_cli_msg(code=push_repo_blfs(tmp, size=0.0002),
                                      msg = c("Checking for large files that need",
                                              "Large files are already synced with Box"))
          expect_true(msg_match)
        
        #modify file
        create_updated_file(name, tmp)
        add_box_loc(basename(box_tmp), dir=tmp, type="path") #make basename path

        #see if it gets flagged
        msg_match <- expect_cli_msg(code=push_repo_blfs(tmp, size=0.0002),
                                    msg = c("Checking for large files that need",
                                            "Copying files to Box",
                                            "Large files have been synced with Box."))
        expect_true(msg_match)
        
        new <- file.info(file.path(tmp, "box-lfs/upload/", hash))

        #check if new file has been added to upload
        expect_true(new$mtime > old$mtime)
      })

})

