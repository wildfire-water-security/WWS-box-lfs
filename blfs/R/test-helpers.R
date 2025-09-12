#functions to make my test files cleaner

#' Creates a fake project repo with optional files for testing
#'
#' @param git logical, should project be a git repo?
#' @param examples logical, should examples from /example-files be copied into project?
#'
#' @returns the file path to the fake project repo
#' @noRd
create_test_repo <- function(git=TRUE, examples=TRUE, box_lfs = FALSE){
  #create temp repo that persists for test
  tmp <- tempfile("repo-")
  dir.create(tmp)

  #turn into git repo
  if(git){git2r::init(tmp)}

  #put gitignore in repo
  file.copy(file.path(test_path(), "testdata/test.gitignore"), file.path(tmp, ".gitignore"))

  #put example files in repo
  if(examples){
    data_path <- file.path(test_path(), "testdata/example-files")
    file.copy(data_path, tmp, recursive = TRUE)}

  #put existing box_lfs into repo
  if(box_lfs){
    data_path <- file.path(test_path(), "testdata/box-lfs")
    file.copy(data_path, tmp, recursive = TRUE)}

  return(tmp)
}

#' Creates a fake boxdrive with the files for testing
#' @param files logical, should example files be added?
#' @returns the file path to the fake boxdrive
#' @noRd
create_test_boxdrive <- function(files = TRUE){
  box_tmp <- tempfile("boxdrive-")
  dir.create(box_tmp)

  if(files){
    box_files <- list.files(file.path(test_path(), "testdata/box-lfs/upload"), full.names = TRUE)
    file.copy(box_files, file.path(box_tmp))
  }

  return(box_tmp)
}

#' Creates a fake download folder with the files for testing
#'
#' @returns the file path to the fake download folder
#' @noRd
create_test_download <- function(){
  tmp <- tempfile("download-")
  dir.create(tmp)

  data_path <- file.path(test_path(), "testdata/box-lfs-zip.zip")
  file.copy(data_path, tmp, recursive = TRUE)
  return(tmp)
}
#' Fake a file that needs to be updated
#'
#' @param name the relative file path to the file to fake update
#' @param dir the fake project repository
#'
#' @returns saves the updated box tracker file in the fake project
create_updated_file <- function(name, dir){
  hashname <- get_tracker_name(name)
  tracker <- read.boxtracker(hashname, dir)
  tracker$last_modified <- Sys.time() - 6000
  write.csv(tracker, file.path(dir, "box-lfs", get_tracker_name(name)), row.names=FALSE, quote=FALSE)

}

#' Fake a file that needs to be downloaded
#'
#' @param name the relative file path to the file to fake download
#' @param dir the fake project repository
#'
#' @returns saves the updated box tracker file in the fake project
create_download_file <- function(name, dir){
  hashname <- get_tracker_name(name)
  tracker <- read.boxtracker(hashname, dir)
  tracker$last_modified <- Sys.time() + 6000
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
  #browser()
  output <- capture_messages(code)

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
