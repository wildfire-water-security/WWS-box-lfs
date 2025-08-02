#' Get file location or other data from boxtracker
#'
#' The .boxtracker files stores the relative location of the file, the box link, and file info (size, dates last modified and changed).
#' This function is used to easily read and extract data from those files.
#'
#' @param tracker the name of the file with the .boxtracker extension
#' @param dir the file path to the file directory
#' @param return the column to return. options are: file_path, box_link, size_MB, last_modified, last_changed
#' @md
#' @returns
#' - if \code{return} is "all" will return a data.frame
#' - otherwise will return a vector of length one with the column value
#'
#' @export
#'
#' @examples
#' read.boxtracker("large-file1", dir="data-raw")
#' read.boxtracker("large-file1", dir="data-raw", return = "size_MB")
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
    data <- as.character(tracker[return])
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
#'
#' @examples
#' get.boxtracker("data-raw/subfolder/large-file1.txt")
get.boxtracker <- function(file, dir=NULL){
  dir <- dir_check(dir)

  #get info on file
  info <- file.info(file.path(dir, file))

  tracker <- data.frame(file_path=file, box_link = NA, size_MB =  info$size*10^-6,
                        last_modified = strftime(info$mtime, "%Y-%m-%d %H:%M:%S"),
                        last_changed = strftime(info$ctime, "%Y-%m-%d %H:%M:%S"))
  return(tracker)
}
