#' Move files from upload folder to Box via Box Drive
#'
#' If user has Box Drive and Box Tools installed, R can move the files to Box without requiring the user to move them automatically.
#'
#' @param dir the file path to the file directory
#' @param box_dir the file path to the project within Box
#' @md
#' @returns Copies any files in upload to the path specified by `box_dir`
#' @noRd 
upload_box_drive <- function(dir, box_dir=NULL){
  #if box dir isn't supplied and it's using box drive ask
    if(is.null(box_dir)){
      if(!rlang::is_interactive()){
        box_dir <- NA
      }else{
        box_dir <- readline("what is the Box path to the project folder? ")
      }}
  

  #remove box-lfs if added (need to make folder exists first)
    box_dir <- gsub("*/box-lfs$", "", box_dir)

  #see if front box path is added, if not add [skip in pkgdown or non interactive]
    if(!identical(Sys.getenv("IN_PKGDOWN"), "true")|rlang::is_interactive()){
      if(!grepl(fs::path_home(), fs::fs_path(box_dir))){
        box_dir <- file.path(get_box_drive(), box_dir)
      }
    }

  #ensure path exists
    exist <- dir.exists(box_dir)
    if(!exist){
      stopifnot(dir.exists(dirname(box_dir)))
      dir.create(box_dir, showWarnings = FALSE)
    }
    stopifnot(dir.exists(dirname(box_dir)))
    
  #add box-lfs to directory
    box_dir <- file.path(box_dir,"box-lfs")

  #create folder for files if it doesn't exist
    dir.create(box_dir, showWarnings = FALSE)

  #copy files from upload to project folder
    upload <- list.files(file.path(dir, "box-lfs/upload"), full.names = TRUE)
    file.copy(upload, box_dir)

  #store file location in box drive
    add_box_loc(box_dir, dir, type="path")
}
