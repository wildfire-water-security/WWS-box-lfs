test_that("files are identified", {
  #create temp dir for test
  tmp <- withr::local_tempdir()

  #initialize
  init_blfs(tmp)

  #copy files to repo
  data_path <- c(file.path(test_path(), "testdata/example-files"))
  file.copy(data_path, tmp, recursive = TRUE)

  expect_length(check_files_blfs(dir=tmp), 0) #expect no large files
  expect_equal(check_files_blfs(dir=tmp, size=0.0002), c("example-files/large-file1.txt", "example-files/large-file2.txt"))
  expect_equal(check_files_blfs(dir=tmp, size=0.0002, new=TRUE), c("example-files/large-file1.txt", "example-files/large-file2.txt"))

  #start tracking
  track_blfs("example-files/large-file1.txt", dir=tmp)

  #recheck
  expect_equal(check_files_blfs(dir=tmp, size=0.0002), c("example-files/large-file1.txt", "example-files/large-file2.txt"))
  expect_equal(check_files_blfs(dir=tmp, size=0.0002, new=TRUE),"example-files/large-file2.txt")

})

test_that("files are moved", {
  #create temp dir for test
  tmp <- withr::local_tempdir()

  #initialize
  init_blfs(tmp)

  #copy tracker files to repo
  data_path <- c(file.path(test_path(), "testdata/box-lfs"))
  file.copy(data_path, tmp, recursive = TRUE)

  #create file structure for files
  file.copy(file.path(test_path(), "testdata/box-lfs"), tmp, recursive = TRUE)

  #try copying over files
  expect_true(move_file_blfs("large-file1.txt", dir=tmp, download=file.path(test_path(), "testdata/example-files")))

})


test_that("files are flagged when updated", {
  #create temp dir for test
  tmp <- withr::local_tempdir()

  #initialize
  init_blfs(tmp)

  #move files and start tracking
  file.copy(file.path(test_path(), "testdata/example-files"), tmp, recursive = TRUE)
  track_blfs("example-files/large-file2.txt", tmp)
  track_blfs("example-files/large-file1.txt", tmp)

  #check if need to be updated
    #change date on boxtracker
    tracker <- read.boxtracker("large-file2.boxtracker", dir=tmp)
    tracker$last_modified <- Sys.time() - 6000
    write.csv(tracker, file.path(tmp, "box-lfs/large-file2.boxtracker"), row.names=FALSE, quote=FALSE)

    #update file (if we run twice it will return null on second because now boxtracker is updated)
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), "upload") #now need to upload
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), NA) #boxtracker is resynced

  #change date on boxtracker
  tracker <- read.boxtracker("large-file2.boxtracker", dir=tmp)
  tracker$last_modified <- Sys.time() + 6000
  write.csv(tracker, file.path(tmp, "box-lfs/large-file2.boxtracker"), row.names=FALSE, quote=FALSE)
  expect_equal(update_blfs("example-files/large-file2.txt", tmp), "download") #now need to download

})
