test_that("runs silently", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/example-files"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))

  #test pull, expect files will look newer than boxtracker because copied -> test for local files newer
  msg <- capture_messages(pull_repo_blfs(tmp))
  expect_equal(msg[2], "v Large files have been synced with Box.\n")
  expect_equal(msg[1],"v Large files are now backed up in Box.\n" )

  #test pull, files should be updated and not give message
  msg <- capture_messages(pull_repo_blfs(tmp))
  expect_equal(msg,"v Large files have been synced with Box.\n" )

  })

test_that("updated files are prompted to upload", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/example-files"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))


  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  #test pull, expect files will look newer than boxtracker because copied -> test for local files newer
  msg <- capture_messages(pull_repo_blfs(tmp))
  expect_equal(msg[2], "v Large files have been synced with Box.\n")
  expect_equal(msg[1],"v Large files are now backed up in Box.\n" )

  #test pull, with an updated local file -> prompts upload
  name <- get_tracker_name("example-files/large-file2.txt")
  tracker <- read.boxtracker(name, dir=tmp)
  tracker$last_modified <- Sys.time() - 6000
  write.csv(tracker, file.path(tmp, "box-lfs", get_tracker_name("example-files/large-file2.txt")), row.names=FALSE, quote=FALSE)
  msg <- capture_messages(pull_repo_blfs(tmp))
  expect_equal(msg[2], "v Large files have been synced with Box.\n")
  expect_equal(msg[1],"v Large files are now backed up in Box.\n" )

})

test_that("new files are box are downloaded", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/example-files"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))

  #set up box repo
  box_tmp <- withr::local_tempdir()
  box_files <- list.files(file.path(test_path(), "testdata/box-lfs/upload"), full.names = TRUE)

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))
  file.copy(box_files, file.path(box_tmp))

  #test pull, expect files will look newer than boxtracker because copied -> test for local files newer
  msg <- capture_messages(pull_repo_blfs(tmp))
  expect_equal(msg[2], "v Large files have been synced with Box.\n")
  expect_equal(msg[1],"v Large files are now backed up in Box.\n" )

  #test pull, with an updated box file (boxtracker shows newer)
  name <- get_tracker_name("example-files/large-file2.txt")
  tracker <- read.boxtracker(name, dir=tmp)
  tracker$last_modified <- Sys.time() + 6000
  write.csv(tracker, file.path(tmp, "box-lfs", get_tracker_name("example-files/large-file2.txt")), row.names=FALSE, quote=FALSE)

  #put in new file path to "box"
  add_box_loc(box_tmp, dir=tmp, type="path")

  msg <- capture_messages(pull_repo_blfs(tmp))
  expect_equal(msg[2], "v Large files have been synced with Box.\n")
  expect_equal(msg[1],"v Large files have been fetched from Box and put in repository.\n" )

})
