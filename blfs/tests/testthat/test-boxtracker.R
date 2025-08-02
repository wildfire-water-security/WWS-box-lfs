test_that("reading boxtracker gives data", {
  tracker <- read.boxtracker("large-file1", dir="data-raw")
  expect_s3_class(tracker, "data.frame")
  expect_equal(ncol(tracker), 5)
  expect_equal(nrow(tracker), 1)

  #check values
  expect_equal(read.boxtracker("large-file1", dir="data-raw", return="file_path"), "subfolder/large-file1.txt")
  expect_equal(read.boxtracker("large-file1", dir="data-raw", return="box_path"), NA)
  expect_equal(read.boxtracker("large-file1", dir="data-raw", return="size_MB"), "21.570502")
  expect_equal(read.boxtracker("large-file1", dir="data-raw", return="last_modified"), "2025-07-23 11:38:45")
  expect_equal(read.boxtracker("large-file1", dir="data-raw", return="last_changed"), "2025-07-31 14:34:59")

  #check that works with and without .boxtracker
  expect_no_failure(tracker<- read.boxtracker("large-file1", dir="data-raw"))
  expect_no_failure(tracker<- read.boxtracker("large-file1.boxtracker", dir="data-raw"))

})
