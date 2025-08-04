#' Get files after cloning a repo that uses box-lfs
#'
#' If you want to clone a Github repository that uses box-lfs, you'll need to manually download the tracked files from Box so
#' you have them in your repository. This code will prompt you to download the Box files, then place them in the correct files
#' in your repository using the .boxtracker files.
#'
#' @param dir the file path to the file directory
#' @param download the file path to the download directory
#'
#' @returns
#' Prompts user to download the files from Box and then places them in the correct location in the \code{dir} folder
#' @export
#'
#' @examples
#' tmp <- withr::local_tempdir()
#'
#' #move just tracker files in, similar to cloning a repo from github
#' file.copy(fs::path_package("extdata/box-lfs", package = "blfs"), tmp, recursive=TRUE)
#' download <- fs::path_package("extdata", package = "blfs") #example zip is here
#'
#' clone_repo_blfs(dir=tmp, download=download)
clone_repo_blfs <- function(dir=NULL, download=NULL){
  dir <- dir_check(dir)

  #check if lfs is needed
  if(check_blfs(dir)){
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
