test_that("repo gets set up", {
  tmp <- withr::local_tempdir()
  git2r::init(tmp)

  box_tmp <- file.path(withr::local_tempdir(), "box-lfs")

  data_path <- file.path(test_path(), "testdata/example-files")

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  #run looking for large files (expect file structure but that's it)
  expect_warning(new_repo_blfs(dir = tmp,box_dir=box_tmp))
  expect_true(setequal(list.files(tmp), c("README.md", "box-lfs", "example-files")))
  expect_length(list.files(box_tmp, recursive = TRUE), 0)

  #run looking for example files
  expect_warning(new_repo_blfs(dir = tmp, size=0.0002,box_dir=box_tmp), regexp="example-files")
  expect_true(setequal(list.files(tmp), c("README.md", "box-lfs", "example-files")))
  expect_equal(list.files(file.path(tmp, "box-lfs")), c("1678f723cb201eb3f9996c01a481dd0e.boxtracker",
                                                        "4fa7622e82d068a0a994eafb564e4f5d.boxtracker",
                                                        "path-hash.csv", "upload"))
  expect_equal(list.files(file.path(tmp, "box-lfs/upload")), c("1678f723cb201eb3f9996c01a481dd0e.txt",
                                                               "4fa7622e82d068a0a994eafb564e4f5d.txt"))

  #ensure files get copied to box
  expect_equal(list.files(box_tmp), c("1678f723cb201eb3f9996c01a481dd0e.txt",
                                                               "4fa7622e82d068a0a994eafb564e4f5d.txt"))

})
