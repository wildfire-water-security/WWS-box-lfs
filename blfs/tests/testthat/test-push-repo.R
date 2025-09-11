test_that("adding a new file works manually", {
  #create repo
    tmp <- withr::local_tempdir()
    git2r::init(tmp)

    data_path <- c(file.path(test_path(), "testdata/example-files"), file.path(test_path(), "testdata/box-lfs"))

    #copy files to repo
    file.copy(data_path, tmp, recursive = TRUE)
    file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))


    #check push repo (the first time we do see the files are "modified")
    with_mocked_bindings(
      get_box_drive = function() FALSE,
      {
        msg <- capture_messages(push_repo_blfs(tmp, size=0.0002))
        expect_true(grepl("i Please upload files from", msg[1]))
        expect_equal(msg[2], "v Large files have been synced with Box.\n")

        #expect_message(push_repo_blfs(tmp, size=0.0002), regexp="Please upload files from")
        #expect_no_message(push_repo_blfs(tmp, size=0.0002))
        msg <- capture_messages(push_repo_blfs(tmp, size=0.0002))
        expect_equal(msg, "v Large files have been synced with Box.\n")

        #add a file
        write.table("testing out adding a new file", file.path(tmp, "example-files/large-file3.txt"))

        #see if it gets flagged
        msg <- capture_messages(push_repo_blfs(tmp, size=0.00002))
        expect_equal(msg[1], "i the following files will no longer be tracked by git:\nexample-files/large-file3.txt\n")
        expect_true(grepl("i Please upload files from", msg[2]))
        expect_equal(msg[3], "v Large files have been synced with Box.\n")

        #expect_message(expect_warning(push_repo_blfs(tmp, size=0.00002), regexp="large-file3"))
        expect_true(file.exists(file.path(tmp, "box-lfs/7338d121d05a8a1a27dac34bd7c56fc0.boxtracker")))

        }
    )

})


test_that("modifying a files works automatically", {
  #create repo
  tmp <- withr::local_tempdir()
  git2r::init(tmp)

  #make box folder
  box_tmp <- file.path(withr::local_tempdir(), "box-lfs")
  dir.create(box_tmp)

  data_path <- c(file.path(test_path(), "testdata/example-files"), file.path(test_path(), "testdata/box-lfs"))

  #copy files to repo
  file.copy(data_path, tmp, recursive = TRUE)
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))

  #put in new file path to "box"
  add_box_loc(box_tmp, dir=tmp, type="path")

  #check push repo (the first time we do see the files are "modified")
  msg <- capture_messages(push_repo_blfs(tmp, size=0.0002))
  expect_equal(msg, "v Large files have been synced with Box.\n")

  #modify file
  #change date on boxtracker
  name <- get_tracker_name("example-files/large-file2.txt")
  tracker <- read.boxtracker(name, dir=tmp)
  tracker$last_modified <- Sys.time() - 6000
  write.csv(tracker, file.path(tmp, "box-lfs", get_tracker_name("example-files/large-file2.txt")), row.names=FALSE, quote=FALSE)

  old <- file.info(file.path(tmp, "box-lfs/upload/4fa7622e82d068a0a994eafb564e4f5d.txt"))

  #see if it gets flagged
  msg <- capture_messages(push_repo_blfs(tmp, size=0.0002))
  expect_equal(msg, "v Large files have been synced with Box.\n")

  new <- file.info(file.path(tmp, "box-lfs/upload/4fa7622e82d068a0a994eafb564e4f5d.txt"))

  expect_true(new$mtime > old$mtime)
})

