#' Check for large files before pushing a Git repository
#'
#' Run BEFORE pushing to GitHub.
#'
#' If you try to push files larger than 100 MB to GitHub you will receive an error. This function will identify files
#' above the size threshold. If they are already tracked, they will be checked for updates. If there are new files they
#' will be tracked and the user prompted to upload to Box.
#'
#' @param dir the file path to the file directory
#' @param size the minimum file size in megabytes to track
#'
#' @returns
#' Identifies any new or modified files, updates the .boxtracker file and prompts user to upload to Box
#' @export
#'
#' @examples
#' push_repo_blfs(fs::path_package("extdata", package = "blfs"))
push_repo_blfs <- function(dir=NULL, size=10){
  #guess on dir if not supplied
  dir <- dir_check(dir)

  #identify large files (new and existing)
  lg_files <- check_files_blfs(dir, size=size)
  new_files <- check_files_blfs(dir, size=size, new=TRUE)

  #check if any of tracked files are modified
  tk_files <- setdiff(lg_files, new_files)
  print_upload_message <- FALSE #does message about uploading files need to be printed?

  #see if any existing files need to re-uploaded
  if(length(tk_files) > 0){
    updated <- unlist(sapply(tk_files, update_blfs, dir=dir))
    print_upload_message <- ifelse(length(updated) > 0, TRUE, FALSE)
  }

  #if there are new files to track [or modified]
  if(length(new_files) > 0){
    file_names <- unname(sapply(new_files, track_blfs, dir))

    warning("the following files will no longer be tracked by git:\n", paste(file_names, collapse="\n"))
    print_upload_message <- TRUE
  }

  #print upload message
  if(print_upload_message){
    upld_message(dir)}
}
