test_that("start up box works", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo()
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  #initialize
  init_blfs(tmp)

  #check files and folders
  expect_true(dir.exists(file.path(tmp, "box-lfs")))
  expect_true(dir.exists(file.path(tmp, "box-lfs/upload")))
  expect_true(file.exists(file.path(tmp, "box-lfs/path-hash.csv")))
  expect_true(file.exists(file.path(tmp, ".gitignore")))

  #start tracking a file
    name <- "example-files/large-file1.txt"
    hold <- track_blfs(file= name, dir=tmp)

    expect_equal(hold, name)

    #ensure tracker created and added to gitignore and copied to upload
    expect_true(file.exists(file.path(tmp, file.path("box-lfs", get_tracker_name(name)))))
    expect_true(file.exists(file.path(tmp, file.path("box-lfs/upload/", get_tracker_name(name, ext=TRUE)))))

      expect_warning(ignore <- read.table(file.path(tmp, ".gitignore")))
      expect_equal(ignore[1,1], "box-lfs/upload")
      expect_equal(ignore[2,1], name)

  #test with shapefile
    name <- "example-files/example-shp.shp"
    hold <- track_blfs(file= name, dir=tmp)

    hash_name <- tools::file_path_sans_ext(name)
    save_name <- paste0(hash_name, ".*")
    expect_equal(hold, save_name)

    #ensure tracker created and added to gitignore and copied to upload
    expect_true(file.exists(file.path(tmp, file.path("box-lfs", get_tracker_name(hash_name)))))
    expect_true(file.exists(file.path(tmp, file.path("box-lfs/upload/", paste0(get_tracker_name(hash_name, ext=TRUE), "zip")))))

    expect_warning(ignore <- read.table(file.path(tmp, ".gitignore")))
    expect_equal(ignore[4,1], "example-files/example-shp.*")

})


