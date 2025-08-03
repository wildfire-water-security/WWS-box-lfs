test_that("link gets added", {
  dir <- file.path(test_path(), "testdata")

  random_link <- paste0("https://oregonstate.box.com/s/h", paste(sample(1:10000, size=4), collapse=""))
  add_box_loc(random_link, dir=dir)

  tracker <- read.boxtracker("large-file1", dir=dir)
  expect_equal(tracker$box_link, random_link)

  #set link back to original for other tests
  add_box_loc("https://oregonstate.box.com/s/h9g8q6n8lj3u2bwhaalepb0lc28te4n5", dir=dir)
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
