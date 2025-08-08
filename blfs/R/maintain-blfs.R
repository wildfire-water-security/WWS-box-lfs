#' Identify large files that should be tracked with Box LFS
#'
#' @param dir the file path to the file directory
#' @param size the minimum file size in megabytes to track
#' @param new logical, if TRUE will only return untracked files, if FALSE will return all files above the size limit
#' @export
#' @returns A vector of relative file paths to the large files
#'
#' @examples
#' #testing files are quite small and don't show up
#' check_files_blfs(fs::path_package("extdata", package = "blfs"))
#'
#' #but they do if we change the size
#' check_files_blfs(fs::path_package("extdata", package = "blfs"), size=0.0002)
#'
#' #they're already tracked, so if we set new to TRUE we don't see them
#' check_files_blfs(fs::path_package("extdata", package = "blfs"), size=0.0002, new=TRUE)

check_files_blfs <- function(dir=NULL, size=10, new=FALSE){
  dir <- dir_check(dir)

  #flag files that should be stored on box
  files <- list.files(dir, full.names=F, recursive = T)
  sizes <- file.size(file.path(dir, files)) / 10^6 #in MB
  large_files <- files[sizes > size]

  #remove files living in box-lfs/upload
  large_files <- large_files[!grepl("^box-lfs/upload/", large_files)]
  large_files <- large_files[!grepl("boxtracker$", large_files)]


  #built in to only get new large files
  if(new & dir.exists(file.path(dir, "box-lfs"))){
    #get all tracked files
    tracked <- list.files(file.path(dir, "box-lfs"), pattern = "boxtracker")
    tracked <- tracked[tracked != "upload"]

    #check for new files
    curr_track <- sapply(tracked, read.boxtracker, dir=dir, return="file_path")
    large_files <- setdiff(large_files,curr_track)
  }

  return(large_files)
}

## copy files from download to correct repo spots
#' Moved downloaded files to the correct file path in the project
#'
#' @param hash_file the file to track, should match the same hash name as the tracker associated with the file
#' @param dir the file path to the file directory
#' @param download the file path to the download directory
#' @export
#' @note
#' If download is not supplied function assumes it is \code{file.path(fs::path_home(), "Downloads")}
#' @returns
#' Copies files from the download folder to the project directory in the correct subfolder location based on the .boxtracker file.
#'
#' @examples
#' #returns false because file doesn't exist in downloads folder
#' move_file_blfs("1678f723cb201eb3f9996c01a481dd0e.txt",
#' fs::path_package("extdata", package = "blfs"))
#'
move_file_blfs <- function(hash_file, dir=NULL, download=NULL){
  if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}
  if(is.null(dir)){dir <- getwd()}

  stopifnot(dir.exists(dir), dir.exists(download))

  #get tracker to know where to put it
  tracker_name <- tools::file_path_sans_ext(basename(hash_file))
  location <- read.boxtracker(tracker_name, dir=dir, return="file_path")

  destination_dir <- dirname(file.path(dir,location))

  # Create the directory if it doesn't exist, including parent directories
  if (!dir.exists(destination_dir)) {
    dir.create(destination_dir, recursive = TRUE, showWarnings = FALSE)
  }

  #copy file to correct location
  file.copy(file.path(download, hash_file), file.path(dir,location), overwrite = TRUE)
}

## update file tracked by blfs (check for differences return TRUE if it needs to be updated) [going from local to repo/box]
#' Update files that are tracked by Box LFS
#'
#' Checks for differences in the time modified between the boxtracker and the file.
#'
#' @param file the relative path to the file to track
#' @param dir the file path to the file directory
#' @md
#' @returns
#' - If the boxtracker shows a newer file, it returns "download"
#' - If the file shows a newer file, it returns "upload"
#' - If the boxtracker and file are up to date with each other it will return nothing
#' @export
#' @examples
#' update_blfs("example-files/large-file1.txt", fs::path_package("extdata", package = "blfs"))
update_blfs <- function(file, dir=NULL){
  dir <- dir_check(dir)

  #get file info
  tracker_name <- get_tracker_name(file)

  boxtracker <- read.boxtracker(tracker_name, dir)
  file_tracker <- get.boxtracker(file, dir)

  #check status of file, does it need to be downloaded or uploaded?
  box_mtime <- as.POSIXct(boxtracker$last_modified)
  file_mtime <- as.POSIXct(file_tracker$last_modified)
  if(box_mtime < file_mtime){
    #file has been changed since last upload to box, need to upload
    #copy to upload folder for easy upload
    file.copy(file.path(dir, file), file.path(dir, "box-lfs/upload/", get_tracker_name(file, ext=TRUE)), overwrite = TRUE)

    #update boxtracker
    write.boxtracker(file, dir)

    return("upload")
  }else if(box_mtime > file_mtime){
    #boxtracker shows new version is on box, need to download
    return("download")
  }else{
    #file is the same in local and on box (according to boxtracker)
    #don't return file, return NA so we know that file is fine
    return(NA)
  }

}

