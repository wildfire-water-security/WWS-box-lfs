#' Determines if a file is a multifile
#'
#' @param file the path to the multifile
#' @param names if TRUE, provides names and ext of the files within multifile
#'
#' @returns TRUE if multifile, otherwise FALSE
#' @examples
#' file <- "inst/extdata/example-files/example-shp.shp"
#' blfs:::is.multifile(file)
#'
#' file <- "inst/extdata/example-files/large-file1.txt"
#' blfs:::is.multifile(file)
#'
is.multifile <- function(file, names=FALSE){
  #get file info
  path <- dirname(file)
  name <- tools::file_path_sans_ext(basename(file))

  files <- list.files(path, pattern = name)

  #get only files with exactly the same name
  files <- files[tools::file_path_sans_ext(basename(file)) == name]

  if(length(files) == 1){return(FALSE)}
  if(names){return(file.path(path, files))}
  if(!names){return(TRUE)}

}

#' Zips objects with multiple files together
#'
#' Certain files, especially geospatial objects, are stored in multiple files that need to be
#' kept together. Because of this, these types of files are generally shared as .zip files with
#' containing all the individual files.
#'
#' @param file the path to the file
#'
#' @returns
#' -  if it is a multifile: the path to the .zip file, stored in the temp folder
#' -  otherwise returns the path to the file
#'
#' @md
#' @noRd
#'
#' @examples
#' file <- "inst/extdata/example-files/example-shp.shp"
#' blfs:::zip_multifile(file)
#'
#' file <- "inst/extdata/example-files/large-file1.txt"
#' blfs:::zip_multifile(file)
zip_multifile <- function(file){
  #see if multifile
  multi <- is.multifile(file)

  #if not a multifile, return the path to the file
  if(!multi){
    return(file)
  }

  #create zip
  path <- dirname(file)
  files <- is.multifile(file, names=TRUE)
  name <- tools::file_path_sans_ext(basename(file))
  zip_file <- file.path(tempdir(), paste0(name, ".zip"))
  zip(zip_file, files, flags="-j")

  #return path of zip for moving to upload
  return(zip_file)
}
