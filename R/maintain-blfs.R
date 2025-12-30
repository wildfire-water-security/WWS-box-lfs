#' Identify large files that should be tracked with Box LFS
#'
#' @param dir the file path to the file directory
#' @param size the minimum file size in megabytes to track
#' @param new logical, if TRUE will only return untracked files, if FALSE will return all files above the size limit
#' @noRd
#' @returns A vector of relative file paths to the large files
#'
#' @examples
#' tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = FALSE,
#'   source_dir = system.file("extdata", package = "blfs"))
#'
#' #testing files are quite small and don't show up
#' check_files_blfs(tmp)
#'
#' #but they do if we change the size
#' check_files_blfs(tmp, size=0.0002)
#'
#' #they're already tracked, so if we set new to TRUE we don't see them
#' check_files_blfs(tmp, size=0.0002, new=TRUE)
#'
#' unlink(tmp, recursive = TRUE)

check_files_blfs <- function(dir=NULL, size=10, new=FALSE){
  dir <- dir_check(dir)

  #flag files that should be stored on box
  files <- list.files(dir, full.names=F, recursive = T)
  sizes <- file.size(file.path(dir, files)) / 10^6 #in MB
  large_files <- files[sizes > size]

  #identify truely large files and provide a warning, add to .blfsignore 
    massive_files <- files[sizes > 4000]
    if(length(massive_files) > 0){
      cli_alert_warning(paste0("the following file(s) are very large (>5 GB):\n", paste0(massive_files, collapse="\n"), 
                              "\nthese will not be tracked by Box-LFS. Please subset the dataset to use with Box-LFS."))
      
      #remove from files to track
      large_files <- files[sizes > size & sizes <= 4000]
      
      #add to .blfsignore 
        ignore <- readLines(file.path(dir, ".blfsignore"), warn=FALSE)
        
        #get name if multifile
        add <- sapply(massive_files, function(x){
          if(is.multifile(file.path(dir, x))){
            name <- file_path_sans_ext(x)
          }else{name <- x}
          
          #only add if not already there 
          if(!any(grepl(name, ignore))){
            cat(paste0("\n", name), file=file.path(dir, ".blfsignore"), append = TRUE)
          }
        })
        
        
    
    }
  
  #remove files we know we don't want to track with box-lfs (mainly for examples, these likely won't be above 10 MB)
    #read .blfsignore
      ignore <- readLines(file.path(dir, ".blfsignore"), warn=FALSE)
      large_files <- large_files[!grepl(paste(ignore,collapse="|"),large_files)]

  #return only one of multifiles
  unique_files <- vector()
  for(x in large_files){
    multi <- is.multifile(file.path(dir, x))
    if(multi){
      base <- tools::file_path_sans_ext(x)
      unique_files <- c(unique_files, base)
    }else{unique_files <- c(unique_files, x)}
  }

  large_files <- unique(unique_files)

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
#' @noRd
#' @note
#' If download is not supplied function assumes it is \code{file.path(fs::path_home(), "Downloads")}
#' @returns
#' Copies files from the download folder to the project directory in the correct subfolder location based on the .boxtracker file.
#'
#' @examples
#' #create temp dir to modify files cleanly
#'   tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = FALSE,
#'   source_dir = system.file("extdata", package = "blfs"))
#'   download <- blfs:::create_test_boxdrive(source_dir = system.file("extdata", package = "blfs"))
#'
#' #move file from download
#'   move_file_blfs("1678f723cb201eb3f9996c01a481dd0e.txt",
#'   dir=tmp, download=download)
#'
#'   move_file_blfs("3f80f3c380f48192c6fcd63a08813c49.zip",
#'   dir=tmp, download=download)
#'
#'   unlink(download, recursive = TRUE)
#'   unlink(tmp, recursive = TRUE)
move_file_blfs <- function(hash_file, dir=NULL, download=NULL){
  if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}
  if(is.null(dir)){dir <- getwd()}

  stopifnot(dir.exists(dir), dir.exists(download))

  #get tracker to know where to put it
  tracker_name <- tools::file_path_sans_ext(basename(hash_file))
  location <- read.boxtracker(tracker_name, dir=dir, return="file_path")

  #if multifile unzip and put those in the right spot
  if(tools::file_ext(location) == ""){
    contents <- unzip(file.path(download, hash_file), list = TRUE, exdir=tempdir())$Name
    stems <- stringr::str_split_i(basename(contents), "[.]", i=1)
    is_multifile <- any(duplicated(stems))   # check for duplicates (multifile if TRUE)

    start_loc <- fs::fs_path(unzip(file.path(download, hash_file), exdir=file.path(tempdir(), stems[1])))
    destination_dir <- fs::fs_path(dirname(file.path(dir,location)))
    
  }else{
    start_loc <- fs::fs_path(file.path(download, hash_file))
    destination_dir <- fs::fs_path(file.path(dirname(file.path(dir,location)), basename(location)))

  }

  # Create the directory if it doesn't exist, including parent directories
  if (!dir.exists(dirname(destination_dir))) {
    dir.create(dirname(destination_dir), recursive = TRUE, showWarnings = FALSE)
  }

  #copy file to correct location
  file.copy(start_loc, destination_dir, overwrite = TRUE)
}

## update file tracked by blfs (check for differences return TRUE if it needs to be updated) [going from local to repo/box]
#' Update files that are tracked by Box LFS
#'
#' Checks for differences in the time modified between the boxtracker and the file. If it's a multifile, it will check for differences across any of the files.
#'
#' @param file the relative path to the file to track
#' @param dir the file path to the file directory
#' @md
#' @returns
#' - If the boxtracker shows a newer file, it returns "download"
#' - If the file shows a newer file, it returns "upload"
#' - If the boxtracker and file are up to date with each other it will return nothing
#' @noRd
#' @examples
#' update_blfs("example-files/large-file1.txt", fs::path_package("extdata", package = "blfs"))
#' update_blfs("example-files/example-shp.shp", fs::path_package("extdata", package = "blfs"))

update_blfs <- function(file, dir=NULL){
  #browser()
  dir <- dir_check(dir)

  #see if multifile
  multi <- is.multifile(file.path(dir, file))

  if(multi){
    #get file info
    tracker_name <- get_tracker_name(tools::file_path_sans_ext(file))
  }else{
    #get file info
    tracker_name <- get_tracker_name(file)
  }


  boxtracker <- read.boxtracker(tracker_name, dir)
  file_tracker <- get.boxtracker(file, dir)

  #check status of file, does it need to be downloaded or uploaded?
  box_size <- boxtracker$size_MB
  file_size <- file_tracker$size_MB

  #first checks to see if the size is different, if yes then see's if it should be uploaded or downloaded
  if(!isTRUE(all.equal(file_size, box_size))){
    box_mtime <- as.POSIXct(boxtracker$last_modified)
    file_mtime <- as.POSIXct(file_tracker$last_modified)
    if(box_mtime < file_mtime){
      #file has been changed since last upload to box, need to upload

      #move to upload folder for upload, use hash name
      move_to_upload(file, dir)

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
  }else{
    return(NA)
  }


}

