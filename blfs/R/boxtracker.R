#' Get file location or other data from boxtracker
#'
#' The .boxtracker files stores the relative location of the file, the box link, and file info (size, dates last modified and changed).
#' This function is used to easily read and extract data from those files.
#'
#' @param tracker the name of the file with the .boxtracker extension (should be a hash)
#' @param dir the file path to the file directory
#' @param return the column to return. options are: file_path, box_link, size_MB, last_modified, last_changed
#' @md
#' @returns
#' - if \code{return} is "all" will return a data.frame
#' - otherwise will return a vector of length one with the column value
#' @export
#' @examples
#' read.boxtracker("1678f723cb201eb3f9996c01a481dd0e",
#' fs::path_package("extdata", package = "blfs"))
#' read.boxtracker("1678f723cb201eb3f9996c01a481dd0e",
#' fs::path_package("extdata", package = "blfs"), return = "size_MB")
#'
read.boxtracker <- function(tracker,dir=NULL, return="all"){
  stopifnot(length(return) == 1)
  dir <- dir_check(dir)

  #add extension if forgotten
  if(!grepl(".boxtracker$", tracker)){
    tracker <- paste0(tracker, ".boxtracker")
  }

  #read file
  tracker <- utils::read.csv(file.path(dir, "box-lfs", tracker),sep = ",")

  #return data
  if(return == "all"){
    data <- tracker
  }else{
    data <- tracker[[return]]
  }
  return(data)
}


#' Get and format info for boxtracker file
#'
#' Pulls and formats the data from a file for the boxtracker file, but does not write to the file (see \link[blfs]{write.boxtracker})
#'
#' @param file the relative path to the file to track
#' @param dir the file path to the file directory
#' @md
#' @returns a data.frame with 1 row and 5 columns:
#' - file_path: the relative path to the file being tracked
#' - box_link: the web link to the folder containing the file
#' - size_MB: the size of the file in megabytes
#' - last_modified: the date and time the file was last modified
#' - last_changed: the date and time the file was last changed
#' @export
#' @examples
#' get.boxtracker("example-files/large-file1.txt", fs::path_package("extdata", package = "blfs"))
get.boxtracker <- function(file, dir=NULL){
  dir <- dir_check(dir)

  #get info on file
  info <- file.info(file.path(dir, file))

  tracker <- data.frame(file_path=file, box_link = NA, size_MB =  info$size*10^-6,
                        last_modified = strftime(info$mtime, "%Y-%m-%d %H:%M:%S"),
                        last_changed = strftime(info$ctime, "%Y-%m-%d %H:%M:%S"))
  return(tracker)
}

#' Write boxtracker file
#'
#' Creates the boxtracker file with a .boxtracker extension to track a file with blfs. If the file is being created for the first time,
#' it will create a new line in the path-hash.csv file which links the hash names to the file paths.
#'
#' @param file the relative path to the file to track
#' @param dir the file path to the file directory
#' @md
#' @returns Saves a boxtracker file to dir/box-lfs with the form file.boxtracker. See \link[blfs]{get.boxtracker} for details on the file structure.
#' @export
#' @examples
#' write.boxtracker("example-files/large-file1.txt", fs::path_package("extdata", package = "blfs"))
write.boxtracker <- function(file, dir=NULL){
  dir <- dir_check(dir)

  tracker_name <- get_tracker_name(file)

  tracker <- get.boxtracker(file, dir)

  # Get link if it exists in previous version, if not write to tracker file
  if(file.exists(file.path(dir, "box-lfs", tracker_name))){
    link <- read.boxtracker(tracker_name, dir=dir, return="box_link")
    tracker$box_link <- link
  }else{
    cat(paste0("\n", paste(file, tracker_name, sep = ",")), file=file.path(dir, "box-lfs/path-hash.csv"), append=TRUE)
  }

  utils::write.csv(tracker, file.path(dir,"box-lfs", tracker_name), row.names = FALSE,
                   quote=FALSE)

}
