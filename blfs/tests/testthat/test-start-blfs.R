test_that("start up box works", {
  #create temp repo
  tmp <- withr::local_tempdir()
  git2r::init(tmp)

  #initialize
  init_blfs(tmp)

  #check files and folders
  expect_true(dir.exists(file.path(tmp, "box-lfs")))
  expect_true(dir.exists(file.path(tmp, "box-lfs/upload")))
  expect_true(file.exists(file.path(tmp, "box-lfs/path-hash.csv")))
  expect_true(file.exists(file.path(tmp, ".gitignore")))

  #move a file in to track
  data_path <- file.path(test_path(), "testdata/example-files")
  file.copy(data_path, tmp, recursive = TRUE)

  #start tracking
  name <- track_blfs(file= "example-files/large-file1.txt", dir=tmp)

  #ensure tracker created and added to gitignore and copied to upload
  expect_true(file.exists(file.path(tmp, "box-lfs/1678f723cb201eb3f9996c01a481dd0e.boxtracker")))
  expect_true(file.exists(file.path(tmp, "box-lfs/upload/1678f723cb201eb3f9996c01a481dd0e.txt")))


  expect_warning(ignore <- read.table(file.path(tmp, ".gitignore")))
  expect_equal(ignore[1,1], "box-lfs/upload")
  expect_equal(ignore[2,1], "example-files/large-file1.txt")

})


