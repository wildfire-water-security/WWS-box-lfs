test_that("reading boxtracker gives data", {
  dir <- file.path(test_path(), "testdata")

  name <- "1678f723cb201eb3f9996c01a481dd0e"
  tracker <- read.boxtracker(name, dir=dir)
  expect_s3_class(tracker, "data.frame")
  expect_equal(ncol(tracker), 5)
  expect_equal(nrow(tracker), 1)

  #check values
  expect_equal(read.boxtracker(name, dir=dir, return="file_path"), "example-files/large-file1.txt")
  expect_equal(read.boxtracker(name,dir=dir, return="box_link"), "https://oregonstate.box.com/s/h9g8q6n8lj3u2bwhaalepb0lc28te4n5")
  expect_equal(class(read.boxtracker(name, dir=dir, return="size_MB")), "numeric")
  expect_s3_class(as.POSIXct(read.boxtracker(name, dir=dir, return="last_modified")), "POSIXct")
  expect_s3_class(as.POSIXct(read.boxtracker(name, dir=dir, return="last_changed")), "POSIXct")

  #check that works with and without .boxtracker
  expect_no_failure(tracker<- read.boxtracker(name, dir=dir))
  expect_no_failure(tracker<- read.boxtracker("1678f723cb201eb3f9996c01a481dd0e.boxtracker", dir=dir))

})

test_that("boxtracker data is grabbed",{

  dir <- file.path(test_path(), "testdata")
  expect_no_failure(write.boxtracker("example-files/large-file1.txt", dir=dir))

  tracker <- read.boxtracker("1678f723cb201eb3f9996c01a481dd0e", dir=dir)
  expect_s3_class(tracker, "data.frame")
  expect_equal(ncol(tracker), 5)
  expect_equal(nrow(tracker), 1)

  #check that it was saved recently
  info <- file.info(file.path(test_path(), "testdata/box-lfs/1678f723cb201eb3f9996c01a481dd0e.boxtracker"))
  expect_true(as.numeric(Sys.time()-info$mtime) < 1)

})
