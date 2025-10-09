test_that("files are identified", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo()
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  #initialize
  init_blfs(tmp)

  expect_length(check_files_blfs(dir=tmp), 0) #expect no large files
  expect_equal(check_files_blfs(dir=tmp, size=0.0002), c("example-files/example-shp", "example-files/large-file1.txt", "example-files/large-file2.txt"))
  expect_equal(check_files_blfs(dir=tmp, size=0.0002, new=TRUE), c("example-files/example-shp", "example-files/large-file1.txt", "example-files/large-file2.txt"))

  #start tracking
  track_blfs("example-files/large-file1.txt", dir=tmp)

  #recheck
  expect_equal(check_files_blfs(dir=tmp, size=0.0002), c("example-files/example-shp", "example-files/large-file1.txt", "example-files/large-file2.txt"))
  expect_equal(check_files_blfs(dir=tmp, size=0.0002, new=TRUE),c("example-files/example-shp","example-files/large-file2.txt"))

})

test_that("files are moved", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE, examples = FALSE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  #create boxdrive to move file from
  drive <- create_test_boxdrive()
  withr::defer(unlink(drive, recursive = TRUE), envir = parent.frame())

  #initialize
  init_blfs(tmp)

  #try copying over files
  file <- "example-files/large-file1.txt"
  expect_true(move_file_blfs(get_tracker_name(file, ext=TRUE),
                             dir=tmp,
                             download=drive))
  expect_true(file.exists(file.path(tmp, file)))

  file <- "example-files/example-shp.shp"
  hash <- "3f80f3c380f48192c6fcd63a08813c49.zip"
  expect_true(all(move_file_blfs(hash,
                             dir=tmp,
                             download=drive)))
  expect_true(file.exists(file.path(tmp, file)))

})


test_that("files are flagged when updated", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo()
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  #initialize
  init_blfs(tmp)

  #move files and start tracking
  file.copy(file.path(test_path(), "testdata/example-files"), tmp, recursive = TRUE)
  track_blfs("example-files/large-file2.txt", tmp)
  track_blfs("example-files/large-file1.txt", tmp)

  #check if need to be updated
    #change date on boxtracker
    name <- "example-files/large-file2.txt"
    create_updated_file(name, tmp)

    #update file (if we run twice it will return null on second because now boxtracker is updated)
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), "upload") #now need to upload
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), NA) #boxtracker is resynced

  #change date on boxtracker
    create_download_file(name, tmp)
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), "download") #now need to download

})
