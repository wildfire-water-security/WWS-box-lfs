test_that("start up box works", {
  #create directory to init in
  dir <- file.path(test_path(), "testdata", "test-folder")
  dir.create(dir)

  #initialize
  init_blfs(dir)

  #check files and folders
  expect_true(dir.exists(file.path(dir, "box-lfs")))
  expect_true(dir.exists(file.path(dir, "box-lfs/upload")))

  expect_true(file.exists(file.path(dir, ".gitignore")))

  #move a file in to track
  dir.create(file.path(dir, "subfolder"))
  move <- file.copy(file.path(test_path(), "testdata/subfolder/large-file1.txt"), file.path(dir, "subfolder"))

  #start tracking
  name <- track_blfs(file= "subfolder/large-file1.txt", dir=dir)

  #ensure tracker created and added to gitignore and copied to upload
  expect_true(file.exists(file.path(dir, "box-lfs/large-file1.boxtracker")))
  expect_true(file.exists(file.path(dir, "box-lfs/upload/large-file1.txt")))


  expect_warning(ignore <- read.table(file.path(dir, ".gitignore")))
  expect_equal(ignore[1,1], "box-lfs/upload")
  expect_equal(ignore[2,1], "subfolder/large-file1.txt")

  #once checked remove folder
  unlink(dir, recursive = TRUE)
})


