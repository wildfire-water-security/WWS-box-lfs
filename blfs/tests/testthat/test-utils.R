test_that("link gets added", {
  #create temp dir to modify files cleanly
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  random_link <- paste0("https://oregonstate.box.com/s/h", paste(sample(1:10000, size=4), collapse=""))
  add_box_loc(random_link, dir=tmp)

  tracker <- read.boxtracker("4fa7622e82d068a0a994eafb564e4f5d", dir=tmp)
  expect_equal(tracker$box_link, random_link)

  })

test_that("directory check works", {
  expect_equal(dir_check(), getwd())

  expect_error(dir_check("wrong/path"))
})

test_that("messages print", {
  dir <- file.path(test_path(), "testdata")

  expect_message(upld_message(dir))
  expect_message(dwld_message(dir))

})

test_that("check blfs works",{
  dir <- file.path(test_path(), "testdata")

  expect_true(check_blfs(dir))
  expect_false(check_blfs(test_path()))

})

test_that("hashes work", {
  hash1 <- get_tracker_name("test1")
  hash2 <- get_tracker_name("test1")

  expect_equal(hash1, hash2)

  hash1 <- get_tracker_name("test1")
  hash2 <- get_tracker_name("test2")
  expect_false(hash1 == hash2)
})
