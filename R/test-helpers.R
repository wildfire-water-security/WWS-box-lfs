#functions to make my test files cleaner

#' Creates a fake project repo with optional files for testing/examples
#'
#' @param git logical, should project be a git repo?
#' @param examples logical, should examples from /example-files be copied into project?
#' @param box_lfs logical, should box-lfs example files be copied?
#' @param source_dir character, base dir containing example files (defaults to test directory)
#'
#' @returns the file path to the fake project repo
#' @noRd
create_test_repo <- function(git = TRUE, examples = TRUE, box_lfs = FALSE,
                                source_dir = file.path(testthat::test_path(), "testdata")) {
  # temp repo
  tmp <- tempfile("repo-")
  dir.create(tmp)
  
  #create readme
  cat("", file=file.path(tmp, "README.md"))
  
  # turn into git repo
  if (git) git2r::init(tmp)

  # copy .gitignore
  file.copy(file.path(source_dir, "test.gitignore"), file.path(tmp, ".gitignore"))
  file.copy(file.path(source_dir, "test.blfsignore"), file.path(tmp, ".blfsignore"))

  # copy example files
  if (examples) {
    data_path <- file.path(source_dir, "example-files")
    file.copy(data_path, tmp, recursive = TRUE)
  }

  # copy box-lfs
  if (box_lfs) {
    data_path <- file.path(source_dir, "box-lfs")
    file.copy(data_path, tmp, recursive = TRUE)
  }

  tmp
}

#' Creates a fake boxdrive for testing/examples
#'
#' @param files logical, should example files be added?
#' @param source_dir character, base dir containing example files (defaults to test directory)
#'
#' @returns the file path to the fake boxdrive
#' @noRd
create_test_boxdrive <- function(files = TRUE,
                                    source_dir = file.path(testthat::test_path(), "testdata")) {
  box_tmp <- tempfile("boxdrive-")
  dir.create(box_tmp)

  if (files) {
    box_files <- list.files(file.path(source_dir, "box-lfs", "upload"), full.names = TRUE)
    file.copy(box_files, box_tmp)
  }

  box_tmp
}
#' Creates a fake download folder with the files for testing
#'
#' @returns the file path to the fake download folder
#' @param source_dir character, base dir containing example files (defaults to test directory)
#' @noRd
create_test_download <- function(source_dir = file.path(testthat::test_path(), "testdata")){
  tmp <- tempfile("download-")
  dir.create(tmp)

  data_path <- file.path(source_dir, "box-lfs-zip.zip")
  file.copy(data_path, tmp, recursive = TRUE)
  return(tmp)
}
#' Fake a file that needs to be updated
#'
#' @param name the relative file path to the file to fake update
#' @param dir the fake project repository
#' @noRd
#' @returns saves the updated box tracker file in the fake project
create_updated_file <- function(name, dir){
  hashname <- get_tracker_name(name)
  tracker <- read.boxtracker(hashname, dir)
  tracker$last_modified <- Sys.time() - 6000
  tracker$size_MB <- tracker$size_MB -0.000001
  write.csv(tracker, file.path(dir, "box-lfs", get_tracker_name(name)), row.names=FALSE, quote=FALSE)

}

#' Fake a file that needs to be downloaded
#'
#' @param name the relative file path to the file to fake download
#' @param dir the fake project repository
#' @noRd
#' @returns saves the updated box tracker file in the fake project
create_download_file <- function(name, dir){
  hashname <- get_tracker_name(name)
  tracker <- read.boxtracker(hashname, dir)
  tracker$last_modified <- Sys.time() + 6000
  tracker$size_MB <- tracker$size_MB -0.000001
  write.csv(tracker, file.path(dir, "box-lfs", get_tracker_name(name)), row.names=FALSE, quote=FALSE)

}

#' Check cli messages to ensure they're expected
#'
#' Using cli package for nicer error messages, but these are harder to test for.
#' This will capture messages and see if they're the same as msg.
#'
#' @param msg a vector of expected messages, doesn't have to be exact, uses grepl to see if they match
#' @param code the code to get the messages from
#'
#' @returns if msg match the outputs from code, TRUE, otherwise returns the messages that don't match
#' @noRd
expect_cli_msg <- function(code, msg){
  output <- testthat::capture_messages(code)

  #check all outputs
  same <- vector()
  for(x in 1:length(msg)){
    check <- grepl(msg[x], output[x])
    same <- c(same, check)
  }

  #return TRUE if all match, or messages that don't match
  if(all(same)){
    return(TRUE)
  }else{
    return(msg[!same])
  }

}


