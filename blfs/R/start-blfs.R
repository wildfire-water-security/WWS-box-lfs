
## function to set up box lfs
#' Set up the structure for box-lfs
#'
#' Creates the file structure for tracking large files with box. Adds the upload folder to .gitignore.
#' If used on a folder that already has the file stucture set up it will run without errors.
#'
#' @param dir the file path to the file directory
#' @md
#' @returns
#' Creates a box-lfs in the directory, with:
#' - a upload folder nested inside.
#' - a .gitignore file (if it doesn't already exist) and adds the upload folder to it
#' - a file called path-hash.csv which links the tracker names to the file paths
#' @export
#' @examples
#' init_blfs(fs::path_package("extdata", package = "blfs"))
init_blfs <- function(dir=NULL){
  #guess on dir if not supplied
  dir <- dir_check(dir)

  #create file stucture
  dir.create(file.path(dir, "box-lfs"), showWarnings = FALSE)
  dir.create(file.path(dir, "box-lfs/upload"), showWarnings = FALSE)

  #create csv to track the hash vs file paths
  write.csv(data.frame(path="", hash=""), file.path(dir, "box-lfs/path-hash.csv"), quote = FALSE, row.names=FALSE)

  #set up .gitignore with upload folder
  ignore <- file.path(dir, ".gitignore")
  if(!file.exists(ignore)){file.create(ignore)} #create .gitignore if it doesn't exist

  #check if already in gitignore
  added <- any(grepl("^box-lfs/upload$", readLines(ignore, warn=FALSE)))
  if(!added){cat("\nbox-lfs/upload", file=ignore, append = T)} #only add if not already there

}



#' Start tracking a file with box-lfs
#'
#' Creates a .boxtracker file with the file information, adds the file to .gitignore, and copy to upload folder so it's easy to but on Box.
#'
#' @param file the relative path to the file to track
#' @param dir the file path to the file directory
#'
#' @returns the name of the file being tracked to use in a warning message
#' @export
#' @examples
#' track_blfs("example-files/large-file1.txt", fs::path_package("extdata", package = "blfs"))
track_blfs <- function(file, dir=NULL){
  dir <- dir_check(dir)

  #create tracking file
  write.boxtracker(file, dir)

  #add to .gitignore
  ignore <- file.path(dir, ".gitignore")
  if(!file.exists(ignore)){file.create(ignore)} #create .gitignore if it doesn't exist

  #check if already in gitignore
  added <- any(grepl(paste0(file, "$"), readLines(ignore, warn=FALSE)))
  if(!added){cat(paste0("\n", file), file=ignore, append=T)} #only add if not already there

  #move to upload folder for upload
  file.copy(file.path(dir, file), file.path(dir, "box-lfs/upload/", basename(file)))

  #return file name for warning message
  return(file)
}

