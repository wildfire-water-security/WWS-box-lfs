# testing
  #-push/pull when file has been updated
  #-push/pull when file has been added
  #set up existing repo
  #clone repo


#what if file have the same name??

## pull a repo with box-lfs (someone may have added box files that need to updated)
 pull_repo_blfs <- function(dir=NULL, download=NULL){
   dir <- dir_check(dir)
   if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}

   #check if file need to be updated
   trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
   files <- unlist(sapply(trackers, read.boxtracker, dir=dir, return="file_path"))
   updated <- unlist(sapply(files, update_blfs, dir=dir))
   updated <- updated[!is.null(updated)]

   #see what files need to be uploaded/downloaded
   download <- names(updated == "download")
   upload <- names(updated == "upload")
   if(length(download) >0){
     dwld_message(dir)

     uploaded <- readline("hit any key once files have been downloaded to continue setting up the repo")

     #unzip from downloads folder and put in the right spot
     if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}

     #may have multiple copies, get the newest
     file <- list.files(download, pattern=paste0("^","box-lfs", ".*\\.zip$"))
     file_info <- file.info(file.path(download, file))
     file <- file[which(file_info$mtime == max(file_info$mtime))]

     #give user to correct wrong guessed zip
     replace <- readline(paste0("Zip file for downloaded data appears to be: ", file.path(download, file),
                                "\nPress enter to use this file or provide a different file path."))

     file <- ifelse(replace == "", replace, file)

     #unzip
     utils::unzip(file.path(downloads, file),
                  exdir = download)

     #get file that need to be moved
     files <- list.files(file.path(download, basename(repo)))

     #move files to correct location
     place <- sapply(files, move_file_blfs, dir=dir, download=download)


   }

   if(length(upload) > 0){
     #files that need to be uploaded should already have boxtracker updated and moved to upload folder from update_blfs
     upld_message(dir)
   }
 }
