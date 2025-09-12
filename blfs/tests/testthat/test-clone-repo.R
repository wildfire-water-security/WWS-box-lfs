test_that("cloning works automatically", {
  #create temp dir to modify files cleanly
    tmp <- create_test_repo(box_lfs=TRUE, examples = FALSE)
    withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

    box_tmp <- create_test_boxdrive()
    withr::defer(unlink(box_tmp, recursive = TRUE), envir = parent.frame())

  #put in new file path to "box"
    add_box_loc(box_tmp, dir=tmp, type="path")

    with_mocked_bindings(
      get_box_drive = function() box_tmp,
      {
        #test cloning repo
        expect_message(clone_repo_blfs(tmp), "Large files have been fetched from Box and put in repository")
      })

  #make sure files are there
    expect_equal(list.files(file.path(tmp, "example-files")), c(paste0("example-shp.", c("cpg", "dbf", "shp", "shx")), "large-file1.txt", "large-file2.txt"))

})

test_that("cloning works manually", {
  #create temp dir to modify files cleanly
    tmp <- create_test_repo(box_lfs=TRUE, examples = FALSE)
    withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

    dwd_tmp <- create_test_download()
    withr::defer(unlink(dwd_tmp, recursive = TRUE), envir = parent.frame())

  #test cloning repo
  with_mocked_bindings(
    get_box_drive = function() FALSE,
    {
      #run looking for example files
      msg_match <- expect_cli_msg(clone_repo_blfs(tmp, download = dwd_tmp),
                                  msg = c("Please download files from Box",
                                          "Large files have been fetched from Box and put in repository"))
      expect_true(msg_match)

    }
  )

  #make sure files are there
  expect_equal(list.files(file.path(tmp, "example-files")), c(paste0("example-shp.", c("cpg", "dbf", "shp", "shx")), "large-file1.txt", "large-file2.txt"))

})
