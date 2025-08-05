#' Check for updated files when pulling a GitHub repository
#'
#' Run AFTER pulling files from GitHub.
#'
#' When you pull the updates from a GitHub repository that has large files tracked with box-lfs you also
#' may need to update those files. This function will check the status of the tracked files in your local
#' repository and determine if there are any files that uploaded or downloaded to maintain the current version.
#'
#' @param dir the file path to the file directory
#' @param download the file path to the download directory
#'
#' @returns
#' Checks for:
#' - tracked files in the local directory that are newer than the tracker and prompts upload
#' - tracked files that are new or newer on Box than the local directory and prompts download
#'
#' @export
#' @md
#' @examples
#' tmp <- withr::local_tempdir()
#'
#' #move just sample repo files in
#' file.copy(fs::path_package("extdata/", package = "blfs"), tmp, recursive=TRUE)
#' download <- fs::path_package("extdata", package = "blfs") #example zip is here
#'
#' pull_repo_blfs(dir=tmp, download=download)
pull_repo_blfs <- function(dir=NULL, download=NULL){
  dir <- dir_check(dir)
  if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}

  #check if file need to be updated
  trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
  files <- unlist(sapply(trackers, read.boxtracker, dir=dir, return="file_path"))
  updated <- unlist(sapply(files, update_blfs, dir=dir))

  #see what files need to be uploaded/downloaded
    down <- names(updated[updated == "download"])
    up <- names(updated[updated == "upload"])


  #upload any files
  if(length(up[!is.na(up)]) > 0){
    #files that need to be uploaded should already have boxtracker updated and moved to upload folder from update_blfs
    upld_message(dir)
  }

  #download any files
  if(length(down[!is.na(down)]) >0){
    dwld_message(dir)

    #only do if interactive to prevent errors
    if(rlang::is_interactive()){
      uploaded <- readline("hit any key once files have been downloaded to continue setting up the repo")}

    #get downloads folder, if not specified guess
    if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}

    #may have multiple copies, get the newest
    file <- list.files(download, pattern=paste0("^","box-lfs", ".*\\.zip$"))
    file_info <- file.info(file.path(download, file))
    file <- file[which(file_info$mtime == max(file_info$mtime))]

    if(rlang::is_interactive()){
      #give user to correct wrong guessed zip
      replace <- readline(paste0("Zip file for downloaded data appears to be: ", file.path(download, file),
                                 "\nPress enter to use this file or provide a different file path."))
    }else{
      replace <- ""}

    file <- ifelse(replace == "", file, replace)

    #unzip to temp dir
    temp_dir <- withr::local_tempdir()
    utils::unzip(file.path(download, file),
                 exdir = temp_dir)

    #get file that need to be moved
    files <- list.files(file.path(temp_dir), recursive = TRUE)

    #move files to correct location
    place <- sapply(files, move_file_blfs, dir=dir, download=file.path(temp_dir))


  }


}
