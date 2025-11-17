test_that("link gets added", {
  #create temp dir to modify files cleanly
    tmp <- create_test_repo(git=FALSE, examples=FALSE, box_lfs=TRUE)
    withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())

  #add random link
    random_link <- paste0("https://oregonstate.box.com/s/h", paste(sample(1:10000, size=4), collapse=""))
    add_box_loc(random_link, dir=tmp, type="link")

  #check for link
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

test_that("a missing path gets asked for", {
  #create temp dir to modify files cleanly
  tmp <- create_test_repo(box_lfs=FALSE)
  withr::defer(unlink(tmp, recursive = TRUE), envir = parent.frame())
  
  box_tmp <- create_test_boxdrive(files=FALSE)
  withr::defer(unlink(box_tmp, recursive = TRUE), envir = parent.frame())
  
  #manually set up repo (no path)
    with_mocked_bindings(
      get_box_drive = function() FALSE,
      {
        silent <- testthat::capture_messages(new_repo_blfs(dir = tmp, size=0.0002,boxdrive=FALSE))
        
        
      })
    
  #try pushing automatically 
    with_mocked_bindings(
      get_box_drive = function() dirname(box_tmp),
      {
        name <- "example-files/example-shp"
      
        #modify file
        create_updated_file(name, tmp)

        with_mocked_bindings(
          readline = function(msg) box_tmp,
          {
            silent <- testthat::capture_messages(push_repo_blfs(tmp, size=0.0002))      
      })  }) 
    
  #check to make sure path is added and correct 
   path <- read.boxtracker("3f80f3c380f48192c6fcd63a08813c49", tmp, return="box_path")
   
   path <- gsub("^/", "", path)
   expect_equal(path, file.path(basename(box_tmp), "box-lfs"))
})

