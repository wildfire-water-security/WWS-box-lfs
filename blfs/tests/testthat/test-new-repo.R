test_that("repo gets set up", {
  tmp <- withr::local_tempdir()
  data_path <- file.path(test_path(), "testdata/example-files")

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  #run looking for large files (expect file structure but that's it)
  expect_warning(new_repo_blfs(dir = tmp))
  expect_equal(list.files(tmp), c("box-lfs", "example-files"))

  #run looking for example files
  expect_warning(new_repo_blfs(dir = tmp, size=0.0002), regexp="example-files")
  expect_equal(list.files(tmp), c("box-lfs", "example-files"))
  expect_equal(list.files(file.path(tmp, "box-lfs")), c("large-file1.boxtracker", "large-file2.boxtracker", "upload"))
  expect_equal(list.files(file.path(tmp, "box-lfs/upload")), c("large-file1.txt", "large-file2.txt"))

})
