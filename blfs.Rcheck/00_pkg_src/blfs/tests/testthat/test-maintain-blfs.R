test_that("files are identified", {
  dir <- file.path(test_path(), "testdata", "test-folder")
  dir.create(dir)

  #initialize
  init_blfs(dir)

  #move a file in to track
  dir.create(file.path(dir, "subfolder"))
  move <- file.copy(file.path(test_path(), "testdata/subfolder/large-file1.txt"), file.path(dir, "subfolder"))

  expect_length(check_files_blfs(dir=dir), 0)
  expect_equal(check_files_blfs(dir=dir, size=0.0002), "subfolder/large-file1.txt")
  expect_equal(check_files_blfs(dir=dir, size=0.0002, new=TRUE), "subfolder/large-file1.txt")

  #start tracking
  track_blfs("subfolder/large-file1.txt", dir=dir)

  #recheck
  expect_equal(check_files_blfs(dir=dir, size=0.0002), "subfolder/large-file1.txt")
  expect_length(check_files_blfs(dir=dir, size=0.0002, new=TRUE), 0)

  #once checked remove folder
  unlink(dir, recursive = TRUE)
})

test_that("files are moved", {
  dir <- file.path(test_path(), "testdata", "test-folder")
  dir.create(dir)

  #initialize
  init_blfs(dir)

  #create file structure and move boxtracker
  dir.create(file.path(dir, "subfolder"))
  file.copy(file.path(test_path(), "testdata/box-lfs"), dir, recursive = TRUE)

  #try copying over files
  expect_true(move_file_blfs("large-file1.txt", dir=dir, download=file.path(test_path(), "testdata/subfolder")))
  expect_true(move_file_blfs("subfolder/large-file2.txt", dir=dir, download=file.path(test_path(), "testdata/subfolder")))

  #once checked remove folder
  unlink(dir, recursive = TRUE)
})


test_that("files are flagged when updated", {
  dir <- file.path(test_path(), "testdata", "test-folder")
  dir.create(dir)

  #initialize
  init_blfs(dir)

  #move files and start tracking
  file.copy(file.path(test_path(), "testdata/subfolder"), dir, recursive = TRUE)
  track_blfs("subfolder/large-file2.txt", dir)
  track_blfs("subfolder/large-file1.txt", dir)

  #check if need to be updated
    #change date on boxtracker
    tracker <- read.boxtracker("large-file2.boxtracker", dir=dir)
    tracker$last_modified <- Sys.time() - 6000
    write.csv(tracker, file.path(dir, "box-lfs/large-file2.boxtracker"), row.names=FALSE, quote=FALSE)

    #update file (if we run twice it will return null on second because now boxtracker is updated)
    expect_equal(update_blfs("subfolder/large-file2.txt", dir), "upload") #now need to upload
    expect_equal(update_blfs("subfolder/large-file2.txt", dir), NULL) #boxtracker is resynced

  #change date on boxtracker
  tracker <- read.boxtracker("large-file2.boxtracker", dir=dir)
  tracker$last_modified <- Sys.time() + 6000
  write.csv(tracker, file.path(dir, "box-lfs/large-file2.boxtracker"), row.names=FALSE, quote=FALSE)
  expect_equal(update_blfs("subfolder/large-file2.txt", dir), "download") #now need to download

  #once checked remove folder
  unlink(dir, recursive = TRUE)
})
