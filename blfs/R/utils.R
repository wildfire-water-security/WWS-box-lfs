#' Add Box file location to the boxtracker file
#'
#' Allows the efficient addition of a link or file path to the Box directory to the .boxtracker files to track where a file lives on Box. This function
#' will add the link to all .boxtracker files within the directory, so ensure the link supplied is the folder housing all the tracked files.
#'
#' @param link the link or path to the Box directory housing the stored files (either web or drive)
#' @param dir the file path to the file directory
#' @param type either "path" for the box_path or "link" fo rthe box_link
#' @returns Modifies all the .boxtracker files to include the supplied link
#' @noRd
#' @examples
#' blfs:::add_box_loc("https://oregonstate.box.com/s/h9g8q6n8lj3u2bwhaalepb0lc28te4n5",
#' fs::path_package("extdata", package = "blfs"), type="link")
add_box_loc <- function(link, dir=NULL, type="path"){
  dir <- dir_check(dir)

  for(x in list.files(file.path(dir, "box-lfs"), pattern="boxtracker")){
    tracker <- read.boxtracker(x, dir)

    if(type == "path"){
      #remove head with username, start after Box
      link <- gsub(boxrdrive::box_drive(), "", fs::fs_path(link))
      tracker$box_path <- link
    }

    if(type == "link"){
      tracker$box_link <- link

    }

    utils::write.csv(tracker, file.path(dir,"box-lfs", x), row.names = FALSE,
                     quote=FALSE)
  }
}

#' Guess the project directory and ensure it exists
#'
#' If directory is not supplied, it will default to the current working directory determined with \link[base]{getwd}
#'
#' @param dir the file path to the file directory or NULL to use current working directory
#' @noRd
#' @returns the file path to the working directory
#'
#' @examples
#' blfs:::dir_check(fs::path_package("extdata", package = "blfs"))
dir_check <- function(dir=NULL){
  #guess on dir if not supplied
  if(is.null(dir)){dir <- getwd()}
  stopifnot(dir.exists(dir))
  return(dir)
}


#' Check if Box LFS is being used on the project directory
#'
#' @param dir the file path to the file directory
#' @noRd
#' @returns A value of TRUE if Box LFS is being used or FALSE if it is not
#' @examples
#' blfs:::check_blfs(fs::path_package("extdata", package = "blfs"))
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
#' @noRd
#' @returns A message prompting user to upload data
#' @examples
#' blfs:::upld_message(fs::path_package("extdata", package = "blfs"))
upld_message <- function(dir=NULL){
  dir <- dir_check(dir)

  #get folder link to go directly
  trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
  link <- unlist(sapply(trackers,read.boxtracker, dir=dir, return="box_link"))
  link <- link[!is.na(link)]

  if(length(link) > 0){
    cli::cli_alert_info(paste0("Please upload files from '", basename(dir),
                               "/box-lfs/upload' to Box here:\n", link[1]))

  }else{
    cli::cli_alert_info(paste0("Please upload files from '", basename(dir),
                               "/box-lfs/upload' to Box here:\n'Wildfire_Water_Security/02_Nodes/your node/Projects/",
                               prj_name(dir), "/box-lfs", "'"))
  }
}

#' Get project name from a github repository
#'
#' Removes the WWS-Node#- from the repo name as it's not needed on Box
#'
#' @param dir the file path to the file directory
#' @noRd
#' @returns a character giving the project name based on a GitHub repository name
#' @examples
#' blfs:::prj_name("~/Documents/WWS-TEST-example-repo")

prj_name <- function(dir){
  name <- gsub("WWS-Node[1-9]-|WWS-", "", basename(dir))
  return(name)
}
#' Print message prompting user to download files
#'
#' Due to security limitations, we can't currently automatically download files from Box via R. Thus this function prompts the user to
#' download the files to Box, providing the location to get the files on Box.
#'
#' @param dir the file path to the file directory
#' @noRd
#' @returns A message prompting user to download data
#' @examples
#' blfs:::dwld_message(fs::path_package("extdata", package = "blfs"))
dwld_message <- function(dir=NULL){
  dir <- dir_check(dir)

  #try to direct right to link
  trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
  link <- unlist(sapply(trackers,read.boxtracker, dir=dir, return="box_link"))
  link <- link[!is.na(link)]

  if(length(link) > 0){
    cli::cli_alert_info(paste0("Please download files from Box here:\n",
                               paste(unique(link), collapse="\n"),
                               "\nthey will be automatically moved to the correct locations from your downloads folder"))

  }else{
    cli::cli_alert_info(paste0("Please download files from Box here:\n'Wildfire_Water_Security/02_Nodes/your node/Projects/",
                               prj_name(dir), "/box-lfs", "'", "\nthey will be automatically moved to the correct locations from your downloads folder"))
    }

}

#' Creates a unique file name for each boxtracker
#'
#' Uses the \link[digest]{digest} function to generate a unique serialized hash code for each file being tracked.
#'
#' @param file the file to be tracked
#' @param ext if TRUE, keeps the original file extension, if FALSE uses .boxtracker
#' @noRd
#' @returns the tracker name as a unique hash based on the file name with the extension ".boxtracker"
#'
#' @examples
#' blfs:::get_tracker_name("test-file1.txt")
#' blfs:::get_tracker_name("another-folder/another_file.txt")
get_tracker_name <- function(file, ext=FALSE){
  clean_path <- fs::path_norm(file)
  hash <- digest::digest(clean_path)
  if(ext){
    tracker_name <- paste0(digest::digest(hash), ".", tools::file_ext(file))

  }else{
    tracker_name <- paste0(digest::digest(hash), ".boxtracker")

  }
  return(tracker_name)
}

#' Get the file path associated with a boxtracker
#'
#' @param tracker the name of the file with the .boxtracker extension (should be a hash)
#' @param dir the file path to the file directory
#'
#' @returns the file path associated with a hash based .boxtracker file.
#' @noRd
#' @examples
#' blfs:::get_file_name("1678f723cb201eb3f9996c01a481dd0e.boxtracker",
#' dir=fs::path_package("extdata", package = "blfs"))
get_file_name <- function(dir=NULL, tracker){
  dir <- dir_check(dir)

  #read path-hash
  link <- read.csv(file.path(dir, "box-lfs/path-hash.csv"))

  #find file name that matches tracker
  file <- link$path[link$hash == tracker]

  return(file)
}

#' Helper to write message about Box LFS to README.md
#'
#' @returns
#' Lines to add to the readme file informing user that Box LFS is being used
#' @noRd
readme_msg <- function(){
  msg <- c("\n## Box LFS\n",
           "This repository is using Box large file storage (LFS) to maintain large files.",
           "Please see <https://github.com/wildfire-water-security/WWS-box-lfs/tree/main/blfs> for instructions on how to get the tracked files.\n")
  return(paste(msg, collapse="\n"))
}

#' Check if Box Drive is installed
#'
#' Uses \link[boxrdrive]{box_drive} to safely either get the path to Box Drive or return
#' FALSE and provide a warning that files will need to be moved manually
#'
#' @returns Either the path to Box Drive or FALSE if Box Drive isn't installed.
#' @noRd
#'
get_box_drive <- function(){
  box_path <- tryCatch(boxrdrive::box_drive(),
                       error=function(e){return(FALSE)})

  if(box_path == FALSE){
    warning("Box Drive not installed, files will need to be manually moved until Box Drive is installed")
  }

  return(box_path)
}


#' Safely get the Box file path from .boxtracker
#'
#' Reads all the .boxtrackers in the directory and returns a single path (or error) for the location
#' in Box Drive where files are housed.
#'
#' @param dir the file path to the file directory
#'
#' @returns Box drive path
#' @noRd
#'
get_box_path <- function(dir){
  #get box path
  hash <- tools::file_path_sans_ext(list.files(file.path(dir, "box-lfs"), pattern=".boxtracker"))
  box_path <- unique(sapply(hash, read.boxtracker, dir=dir, return="box_path"))
  box_path <- box_path[!is.na(box_path)]

  #ensure there's only one
  if(length(box_path) > 1){
    stop("More than one Box Path found in .boxtrackers, please check")
  }
  return(file.path(get_box_drive(),box_path))

}


#' Moves a file to the upload folder
#'
#' If the file is a multifile, it will zip it and place the zip into the upload instead. The name of the zip will be the file without the extension
#' converted to a hash.
#'
#' @param file the relative path to the file to track
#' @param dir the file path to the file directory
#' @noRd
#'
move_to_upload <- function(file, dir) {
  upload_dir <- file.path(dir, "box-lfs", "upload")
  dir.create(upload_dir, showWarnings = FALSE, recursive = TRUE)

  path <- file.path(dir, file)

  if(is.multifile(path)) {
    # multifile zip and rename
    file_path <- zip_multifile(path)
    base <- tools::file_path_sans_ext(file)
    save_name <- paste0(get_tracker_name(base, ext = TRUE), "zip")
  }else{
    # single file just rename
    file_path <- path
    base <- file
    save_name <- get_tracker_name(base, ext = TRUE)
  }

  file.copy(file_path, file.path(upload_dir, save_name), overwrite = TRUE)
}
