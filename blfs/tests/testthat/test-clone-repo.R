test_that("cloning works automatically", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"))

  box_tmp <- withr::local_tempdir()
  box_files <- list.files(file.path(test_path(), "testdata/box-lfs/upload"), full.names = TRUE)

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))
  file.copy(box_files, file.path(box_tmp))

  #put in new file path to "box"
  add_box_loc(box_tmp, dir=tmp, type="path")

  #test cloning repo
  expect_no_error(clone_repo_blfs(tmp))

  #make sure files are there
  expect_equal(list.files(file.path(tmp, "example-files")), c("large-file1.txt", "large-file2.txt"))

})

test_that("cloning works manually", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))

  #test cloning repo
  with_mocked_bindings(
    get_box_drive = function() FALSE,
    {
      expect_no_error(expect_message(clone_repo_blfs(tmp, download = tmp)))
    }
  )

  #make sure files are there
  expect_equal(list.files(file.path(tmp, "example-files")), c("large-file1.txt", "large-file2.txt"))

})
