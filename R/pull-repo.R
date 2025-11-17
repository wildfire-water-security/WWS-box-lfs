#' Check for updated Box LFS files when pulling a GitHub repository
#'
#' Run AFTER pulling files from GitHub.
#'
#' When you pull the updates from a GitHub repository that has large files tracked with Box LFS you also
#' may need to update those files. This function will check the status of the tracked files in your local
#' repository and determine if there are any files that uploaded or downloaded to maintain the current version.
#'
#' @param dir the file path to the file directory
#' @param download the file path to the download directory (if NULL will default to the Box Drive path)
#' @param boxdrive logical, should Box drive be used?
#'
#' @returns
#' Checks for:
#' - tracked files in the local directory that are newer than the tracker and prompts upload
#' - tracked files that are new or newer on Box than the local directory and prompts download
#'
#' @export
#' @md
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
#' pull_repo_blfs(dir=tmp, download=box_tmp)
#'
#'  unlink(box_tmp, recursive = TRUE)
#'  unlink(tmp, recursive = TRUE)
pull_repo_blfs <- function(dir=NULL, download=NULL, boxdrive=TRUE){
  dir <- dir_check(dir)

  #clear upload folder so we only upload new files
    upld_files <- list.files(file.path(dir, "box-lfs/upload"), full.names = TRUE)
    unlink(upld_files)

  #check if file need to be updated
    cli::cli_alert_info("Checking for large files that need to be updated by Box-LFS...")
    
    trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
    files <- unlist(sapply(trackers, read.boxtracker, dir=dir, return="file_path"))
    updated <- unlist(pbsapply(files, update_blfs, dir=dir)) #files to upload are moved to /upload

  #see what files need to be uploaded/downloaded
    down <- na.omit(names(updated[updated == "download"]))
    up <- na.omit(names(updated[updated == "upload"]))

  #check if we can run automatically
    box_path <- get_box_drive()

  #upload any files
  if(length(up[!is.na(up)]) > 0){
    #files that need to be uploaded should already have boxtracker updated and moved to upload folder from update_blfs
    if(box_path == FALSE){
      upld_message(dir)
    }else{
      cli::cli_alert_info("Copying updated files to Box...")
      
      upload_box_drive(dir=dir, box_dir=box_path)
    }

    cli::cli_alert_success("Large files are now backed up in Box.")

  }

  #download any files
  if(length(down[!is.na(down)]) >0){
    if(box_path == FALSE | boxdrive == FALSE){
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

      file_loc <- temp_dir
    }else{
      loc <- get_box_path(dir)

      if(is.null(download)){
        #get box path and set location of download folder
        file_loc <- file.path(get_box_drive(), loc)
      }else{
        download <- file.path(fs::path_home(), "Downloads")
        file_loc <- file.path(download, loc)
      }

    }

    #get files that need to be moved (only copy changed files)
    hashes <- sub("\\.boxtracker$", "", down)
    hashes <- hashes[!is.na(hashes)]

    zip_files <- list.files(file.path(file_loc), recursive = TRUE)
    copy_files <- zip_files[grepl(paste0("^(", paste(hashes, collapse = "|"), ")"), basename(zip_files))]

    #move files to correct location
    cli::cli_alert_info("Downloading files from Box...")
    
    place <- pbapply::pbsapply(copy_files, move_file_blfs, dir=dir, download=file.path(file_loc))

    cli::cli_alert_success("Large files have been fetched from Box and put in repository.")

  }

  cli::cli_alert_success("Large files have been synced with Box.")

}
