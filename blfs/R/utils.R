#' Add Box file location to the boxtracker file
#'
#' Allows the efficent addition of a link to the Box directory to the .boxtracker files to track where a file lives on Box. This function
#' will add the link to all .boxtracker files within the directory, so ensure the link supplied is the folder housing all the tracked files.
#'
#' @param link the link to the Box directory housing the stored files
#' @param dir the file path to the file directory
#' @export
#' @returns Modifies all the .boxtracker files to include the supplied link
#'
#' @examples
#' add_box_loc("https://oregonstate.box.com/s/h9g8q6n8lj3u2bwhaalepb0lc28te4n5",
#' fs::path_package("extdata", package = "blfs"))
add_box_loc <- function(link, dir=NULL){
  dir <- dir_check(dir)

  for(x in list.files(file.path(dir, "box-lfs"), pattern="boxtracker")){
    tracker <- read.boxtracker(x, dir)
    tracker$box_link <- link

    utils::write.csv(tracker, file.path(dir,"box-lfs", x), row.names = FALSE,
                     quote=FALSE)
  }
}

#' Guess the project directory and ensure it exists
#'
#' If directory is not supplied, it will default to the current working directory determined with \link[base]{getwd}
#'
#' @param dir the file path to the file directory or NULL to use current working directory
#'
#' @returns the file path to the working directory
#' @export
#'
#' @examples
#' dir_check(fs::path_package("extdata", package = "blfs"))
dir_check <- function(dir=NULL){
  #guess on dir if not supplied
  if(is.null(dir)){dir <- getwd()}
  stopifnot(dir.exists(dir))
  return(dir)
}


#' Check if box-lfs is being used on the project directory
#'
#' @param dir the file path to the file directory
#'
#' @returns A value of TRUE if box-lfs is being used or FALSE if it is not
#' @export
#' @examples
#' check_blfs(fs::path_package("extdata", package = "blfs"))
check_blfs <- function(dir=NULL){
  dir <- dir_check(dir)

  return <- dir.exists(file.path(dir, "box-lfs"))
  return(return)
}


#' Print message prompting user to upload files
#'
#' Due to security limitations, we can't currently automatically upload files to Box via R. Thus this function prompts the user to
#' upload the files to Box, providing the location of the files on the local computer and the location to place the files on Box.
#'
#' @param dir the file path to the file directory
#'
#' @returns A message prompting user to upload data
#' @export
#' @examples
#' upld_message(fs::path_package("extdata", package = "blfs"))
upld_message <- function(dir=NULL){
  dir <- dir_check(dir)

  #get folder link to go directly
  trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
  link <- unlist(sapply(trackers,read.boxtracker, dir=dir, return="box_link"))
  link <- link[!is.na(link)]

  if(length(link) > 0){
    message(paste0("Please upload files from '", basename(dir),
                   "/box-lfs/upload' to Box here:\n", link[1]))

  }else{
    message(paste0("Please upload files from '", basename(dir),
                   "/box-lfs/upload' to Box here:\n'Wildfire_Water_Security/02_Nodes/your node/Projects/",
                   basename(dir), "/box-lfs", "'"))

  }
}

#' Print message prompting user to download files
#'
#' Due to security limitations, we can't currently automatically download files from Box via R. Thus this function prompts the user to
#' download the files to Box, providing the location to get the files on Box.
#'
#' @param dir the file path to the file directory
#'
#' @returns A message prompting user to download data
#' @export
#' @examples
#' dwld_message(fs::path_package("extdata", package = "blfs"))
dwld_message <- function(dir=NULL){
  dir <- dir_check(dir)

  #try to direct right to link
  trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
  link <- unlist(sapply(trackers,read.boxtracker, dir=dir, return="box_link"))
  link <- link[!is.na(link)]

  if(length(link) > 0){
    message(paste0("there are large files in this repository stored on box that need to be downloaded. Please download files, likely located here:\n",
                   paste(unique(link), collapse="\n"),
                   "\nthey will be automatically moved to the correct locations from your downloads folder"))

  }else{
    message(paste0("Please download files from Box here:\n'Wildfire_Water_Security/02_Nodes/your node/Projects/",
                   basename(dir), "/box-lfs", "'", "\nthey will be automatically moved to the correct locations from your downloads folder"))}

}

#' Creates a unique file name for each boxtracker
#'
#' Uses the \link[digest]{digest} function to generate a unique serialized hash code for each file being tracked.
#'
#' @param file the file to be tracked
#'
#' @returns the tracker name as a unique hash based on the file name with the extension ".boxtracker"
#' @export
#'
#' @examples
#' get_tracker_name("test-file1.txt")
#' get_tracker_name("another-folder/another_file.txt")
get_tracker_name <- function(file){
  clean_path <- fs::path_norm(file)
  hash <- digest::digest(clean_path)
  tracker_name <- paste0(digest::digest(hash), ".boxtracker")
  return(tracker_name)
}

#' Get the file path associated with a boxtracker
#'
#' @param tracker the name of the file with the .boxtracker extension (should be a hash)
#'
#' @returns the file path associated with a hash based .boxtracker file.
#' @export
#'
#' @examples
#' get_file_name("1678f723cb201eb3f9996c01a481dd0e.boxtracker",
#' dir=fs::path_package("extdata", package = "blfs"))
get_file_name <- function(dir=NULL, tracker){
  dir <- dir_check(dir)

  #read path-hash
  link <- read.csv(file.path(dir, "box-lfs/path-hash.csv"))

  #find file name that matches tracker
  file <- link$path[link$hash == tracker]

  return(file)
}
