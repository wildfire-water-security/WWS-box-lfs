test_that("reading boxtracker gives data", {
  dir <- file.path(test_path(), "testdata")

  name <- "1678f723cb201eb3f9996c01a481dd0e"
  tracker <- read.boxtracker(name, dir=dir)
  expect_s3_class(tracker, "data.frame")
  expect_equal(ncol(tracker), 6)
  expect_equal(nrow(tracker), 1)

  #check values
  expect_equal(read.boxtracker(name, dir=dir, return="file_path"), "example-files/large-file1.txt")
  expect_equal(read.boxtracker(name,dir=dir, return="box_link"), "https://oregonstate.box.com/s/h9g8q6n8lj3u2bwhaalepb0lc28te4n5")
  expect_equal(read.boxtracker(name,dir=dir, return="box_path"), "/Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects/data-management/box-lfs")
  expect_equal(class(read.boxtracker(name, dir=dir, return="size_MB")), "numeric")
  expect_s3_class(as.POSIXct(read.boxtracker(name, dir=dir, return="last_modified")), "POSIXct")
  expect_s3_class(as.POSIXct(read.boxtracker(name, dir=dir, return="last_changed")), "POSIXct")

  #check that works with and without .boxtracker
  expect_no_error(tracker<- read.boxtracker(name, dir=dir))
  expect_no_error(tracker<- read.boxtracker("1678f723cb201eb3f9996c01a481dd0e.boxtracker", dir=dir))

})

test_that("boxtracker data is grabbed",{
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())
  
  expect_no_error(write.boxtracker("example-files/large-file1.txt", dir=tmp))

  tracker <- read.boxtracker("1678f723cb201eb3f9996c01a481dd0e", dir=tmp)
  expect_s3_class(tracker, "data.frame")
  expect_equal(ncol(tracker), 6)
  expect_equal(nrow(tracker), 1)

  #check that it was saved recently
  info <- file.info(file.path(tmp, "box-lfs/1678f723cb201eb3f9996c01a481dd0e.boxtracker"))
  expect_true(as.numeric(Sys.time()-info$mtime) < 1)

})


test_that("path for multifile is done without extension",{
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=TRUE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())
  
  file <- "example-files/example-shp"
  dir <- file.path(test_path(), "testdata")
  expect_no_error(write.boxtracker(file, dir=tmp))

  tracker <- read.boxtracker(get_tracker_name(file), dir=tmp)
  expect_equal(tools::file_ext(tracker$file_path), "")
  
  #ensure path-hash is written

})
