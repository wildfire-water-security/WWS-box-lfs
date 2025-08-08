test_that("adding a new file works", {
  #create repo
    tmp <- withr::local_tempdir()
    data_path <- c(file.path(test_path(), "testdata/example-files"), file.path(test_path(), "testdata/box-lfs"),
                   file.path(test_path(), "testdata/.gitignore"))

    #copy files to repo
    file.copy(data_path, tmp, recursive = TRUE)

    #check push repo (the first time we do see the files are "modified")
    expect_message(push_repo_blfs(tmp, size=0.0002), regexp="Please upload files from")
    expect_no_message(push_repo_blfs(tmp, size=0.0002))

    #add a file
    write.table("testing out adding a new file", file.path(tmp, "example-files/large-file3.txt"))

    #see if it gets flagged
    expect_message(expect_warning(push_repo_blfs(tmp, size=0.00002), regexp="large-file3"))
    expect_true(file.exists(file.path(tmp, "box-lfs/7338d121d05a8a1a27dac34bd7c56fc0.boxtracker")))
})

test_that("modifying a files works", {
  #create repo
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/example-files"), file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/.gitignore"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  #check push repo (the first time we do see the files are "modified")
  expect_message(push_repo_blfs(tmp, size=0.0002), regexp="Please upload files from")
  expect_no_message(push_repo_blfs(tmp, size=0.0002))

  #modify file
  #change date on boxtracker
  name <- get_tracker_name("example-files/large-file2.txt")
  tracker <- read.boxtracker(name, dir=tmp)
  tracker$last_modified <- Sys.time() - 6000
  write.csv(tracker, file.path(tmp, "box-lfs", get_tracker_name("example-files/large-file2.txt")), row.names=FALSE, quote=FALSE)

  #see if it gets flagged
  expect_message(push_repo_blfs(tmp, size=0.0002), regexp="box-lfs/upload")
})
