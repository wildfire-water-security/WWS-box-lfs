##NOTE BOX_DIR is specified by user, so we don't have to guess

#' Start using Box LFS on a new project
#'
#' Use if you have an existing directory that you want to start tracking with git and put on GitHub. It will set up the
#' file structure, identify files that should be tracked, and prompt user to upload those files to Box.
#'
#' @details
#' Box LFS works similar to git lfs where large files are tracked using a tracking file (.boxtracker) which keeps track of the file location and
#' it's version. Any files larger than the specified size (default is 10 MB) will be added to .gitignore and the user will be prompted to upload those files
#' to Box and supply the Box link to those files.
#'
#'
#' @param dir the file path to the file directory
#' @param size the minimum file size in megabytes to track
#' @param box_dir the file path to the project within Box
#' @md
#' @returns
#' Creates the following files in \code{dir}:
#' - box-lfs: to store the .boxtracker files
#'  - upload: put copies of tracked files for easy uploading to Box
#'  - *.boxtracker: the tracker files for each large file
#'
#' Also adds the tracked files and the /box-lfs/upload file to .gitignore.
#'
#' @export
#'
#' @examples
#' tmp <- withr::local_tempdir()
#' new_repo_blfs(tmp)
new_repo_blfs <- function(dir=NULL, size=10, box_dir=NULL){
  #guess on dir if not supplied
  dir <- dir_check(dir)

  #set up file structure
  init_blfs(dir)

  #identify large files and track
  files <- check_files_blfs(dir, size=size)
  file_names <- unname(sapply(files, track_blfs, dir))

  cli::cli_alert_info(paste0("the following files will no longer be tracked by git:\n", paste(file_names, collapse="\n")))

  #see if box drive is working
  box_path <- get_box_drive()

  #if no, keep manual method
  if(box_path == FALSE){
    upld_message(dir)

    #attach box link to the files
    if(!rlang::is_interactive()){
      link <- NA
    }else{
      link <- readline("what is the Box link to the folder where the data is now backed up? ")
    }

    add_box_loc(link, dir, type="link")

  }else{
    upload_box_drive(dir=dir, box_dir=box_dir)
  }

  cli::cli_alert_success("Large files are now backed up in Box.")

}
