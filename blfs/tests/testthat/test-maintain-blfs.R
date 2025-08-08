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

  #try copying over files
  expect_true(move_file_blfs("1678f723cb201eb3f9996c01a481dd0e.txt", dir=tmp, download=file.path(test_path(), "testdata/box-lfs/upload")))

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
    name <- get_tracker_name("example-files/large-file2.txt")
    tracker <- read.boxtracker(name, dir=tmp)
    tracker$last_modified <- Sys.time() - 6000
    write.csv(tracker, file.path(tmp, "box-lfs", get_tracker_name("example-files/large-file2.txt")), row.names=FALSE, quote=FALSE)

    #update file (if we run twice it will return null on second because now boxtracker is updated)
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), "upload") #now need to upload
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), NA) #boxtracker is resynced

  #change date on boxtracker
    name <- get_tracker_name("example-files/large-file2.txt")
    tracker <- read.boxtracker(name, dir=tmp)
    tracker$last_modified <- Sys.time() + 6000
    write.csv(tracker, file.path(tmp, "box-lfs", get_tracker_name("example-files/large-file2.txt")), row.names=FALSE, quote=FALSE)
    expect_equal(update_blfs("example-files/large-file2.txt", tmp), "download") #now need to download

})
