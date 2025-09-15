#' Stop tracking a file with Box-LFS
#'
#' Removes the boxtracker file, adds to .blfsignore, and optionally removes it from
#' .gitignore so that git will start tracking it again.
#'
#' @param dir the file path to the file directory
#' @param file the relative file path to the file to stop tracking
#' @param git logical, should the file be tracked by git again?
#'
#' @returns a message indicating that the file has been successfully untracked
#' @export
#'
#' @examples
#' #create temp dir to modify files cleanly
#'   tmp <- blfs:::create_test_repo(box_lfs=TRUE, examples = TRUE,
#'   source_dir = system.file("extdata", package = "blfs"))
#'
#'   rm_tracking(tmp, "example-files/large-file1.txt")
#'   rm_tracking(tmp, "example-files/example-shp.shp", git=FALSE)
#'
#'   #remove temp dirs
#'   unlink(tmp, recursive = TRUE)
rm_tracking <- function(dir, file, git=TRUE){
  #check if multifile
    multi <- is.multifile(file.path(dir, file))
    if(multi){
      file <- tools::file_path_sans_ext(file)
      ignore_name <- paste0(file, ".*")
    }else{
      ignore_name <- file
    }

  #get file hash
    hash <- get_tracker_name(file)

  #remove box tracker
    unlink(file.path(dir, "box-lfs", hash))

  #remove from hash-path.csv
    link <- read.csv(file.path(dir, "box-lfs/path-hash.csv"))
    link <- link[link$path != file,]
    write.csv(link, file.path(dir, "box-lfs/path-hash.csv"), quote=FALSE, row.names = FALSE)

  #remove from .gitignore
    if(git){
      ignore <- readLines(file.path(dir, ".gitignore"), warn=FALSE)
      ignore <- ignore[ignore != ignore_name]
      cat(paste(ignore, collapse = "\n"), file=file.path(dir, ".gitignore"), append = FALSE)
    }else{
      cli::cli_alert_warning(paste0(file, " will no longer be tracked by Git or Box-LFS"))
    }

  #add to .blfsignore
    cat(paste0("\n", file), file=file.path(dir, ".blfsignore"), append = TRUE)

  #return a message
    cli::cli_alert_success(paste0(file, " has been successfully untracked with Box-LFS"))
}
