test_that("functions work in pkgdown", {
  new_dir <- blfs:::create_test_repo(box_lfs=FALSE, examples = TRUE)
  withr::defer(unlink(new_dir, recursive = TRUE), envir = parent.frame())
  
  box_tmp_upld <- blfs:::create_test_boxdrive(files=FALSE)
  withr::defer(unlink(box_tmp_upld, recursive = TRUE), envir = parent.frame())
  
  with_mocked_bindings(
    get_box_drive = function() tempdir(),
    {
      expect_no_error(expect_message(expect_message(new_repo_blfs(dir = new_dir, size = 0.0001, box_dir = box_tmp_upld, boxdrive = TRUE))))
      
    })
})
