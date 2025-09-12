#' Get files after cloning a repo that uses Box LFS
#'
#' If you want to clone a Github repository that uses Box LFS, you'll need to manually download the tracked files from Box so
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
#'  #create temp dir to modify files cleanly
#'   tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = FALSE,
#'   source_dir = system.file("extdata", package = "blfs"))
#'
#'   box_tmp <- blfs:::create_test_boxdrive(source_dir = system.file("extdata", package = "blfs"))
#'
#'   #put in new file path to "box"
#'    blfs:::add_box_loc(box_tmp, dir=tmp, type="path")
#'
#'   clone_repo_blfs(dir=tmp, download=box_tmp)
#'
#'   #remove temp dirs
#'   unlink(box_tmp, recursive = TRUE)
#'   unlink(tmp, recursive = TRUE)
clone_repo_blfs <- function(dir=NULL, download=NULL){
  dir <- dir_check(dir)

  #check if lfs is needed
  if(check_blfs(dir)){

    #see if box drive is working
    box_path <- get_box_drive()

    if(box_path == FALSE){
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

      #set download path
      file_loc <- file.path(temp_dir)
    }else{
      #get box path and set location of download folder
      file_loc <- get_box_path(dir)

    }

    #get file that need to be moved
      files <- list.files(file.path(file_loc), recursive = TRUE)

    #move files to correct location
      place <- sapply(files, move_file_blfs, dir=dir, download=file_loc)

  }

  cli::cli_alert_success("Large files have been fetched from Box and put in repository.")

  }
