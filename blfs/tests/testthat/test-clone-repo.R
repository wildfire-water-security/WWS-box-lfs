test_that("cloning works", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))


  #test cloning repo
  expect_no_error(expect_message(clone_repo_blfs(tmp, download = tmp)))

  #make sure files are there
  expect_equal(list.files(file.path(tmp, "example-files")), c("large-file1.txt", "large-file2.txt"))

})
