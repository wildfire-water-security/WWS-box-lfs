test_that("runs silently", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/.gitignore"),
                 file.path(test_path(), "testdata/example-files"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  #test pull, expect files will look newer than boxtracker because copied -> test for local files newer
  expect_message(pull_repo_blfs(tmp),  regexp= "Please upload files")

  #test pull, files should be updated and not give message
  expect_no_message(pull_repo_blfs(tmp))

  })

test_that("updated files are prompted to upload", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/.gitignore"),
                 file.path(test_path(), "testdata/example-files"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  #test pull, expect files will look newer than boxtracker because copied -> test for local files newer
  expect_message(pull_repo_blfs(tmp),  regexp= "Please upload files")

  #test pull, files should be updated and not give message
  expect_no_message(pull_repo_blfs(tmp))

  #test pull, with an updated local file -> prompts upload
  tracker <- read.boxtracker("large-file2.boxtracker", dir=tmp)
  tracker$last_modified <- Sys.time() - 6000
  write.csv(tracker, file.path(tmp, "box-lfs/large-file2.boxtracker"), row.names=FALSE, quote=FALSE)
  expect_message(pull_repo_blfs(tmp),  regexp= "Please upload files")

})

test_that("new files are box are downloaded", {
  #create repo without tracked files
  tmp <- withr::local_tempdir()
  data_path <- c(file.path(test_path(), "testdata/box-lfs"),
                 file.path(test_path(), "testdata/.gitignore"),
                 file.path(test_path(), "testdata/example-files"),
                 file.path(test_path(), "testdata/box-lfs-zip.zip"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)

  #test pull, expect files will look newer than boxtracker because copied -> test for local files newer
  expect_message(pull_repo_blfs(tmp),  regexp= "Please upload files")


  #test pull, with an updated box file (boxtracker shows newer)
  tracker <- read.boxtracker("large-file2.boxtracker", dir=tmp)
  tracker$last_modified <- Sys.time() + 6000
  write.csv(tracker, file.path(tmp, "box-lfs/large-file2.boxtracker"), row.names=FALSE, quote=FALSE)
  expect_message(pull_repo_blfs(tmp, download=tmp),  regexp= "there are large files in this repository")


})
