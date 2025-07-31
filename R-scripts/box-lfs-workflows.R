# testing 
  #-push/pull when file has been updated 
  #-push/pull when file has been added
  #set up existing repo 
  #clone repo

#TODO: check for modified files not just new files 
source("R-scripts/box-lfs-helpers.R")

## setting up a new repo (existing)
 new_repo_blfs <- function(dir=NULL, size=10){
   #guess on dir if not supplied
   dir <- dir_check(dir)
   
   #set up file structure
   init_blfs(dir)
   
   #identify large files and track 
   files <- check_files_blfs(dir, size=size)
   file_names <- unname(sapply(files, track_blfs, dir))
   
   warning("the following files will no longer be tracked by git:\n", paste(file_names, collapse="\n"))
   
   upld_message(dir)
   
   #attach box link to the files
   link <- readline("what is the box link to the folder where the data is now backed up? ")
   add_box_loc(link, dir)
 }
 
## pushing repo (potential new/modified files that need to be tracked) run BEFORE pushing
 push_repo_blfs <- function(dir=NULL, size=10){
   #guess on dir if not supplied
   dir <- dir_check(dir)
   
   #identify large files (new and existing)
   lg_files <- check_files_blfs(dir, size=size)
   new_files <- check_files_blfs(dir, size=size, new=TRUE)
   
   #check if any of tracked files are modified 
   tk_files <- setdiff(lg_files, new_files)
   print_upload_message <- FALSE #does message about uploading files need to be printed?
     
     #see if any existing files need to re-uploaded 
      if(length(tk_files) > 0){
        updated <- unlist(sapply(tk_files, update_blfs, dir=dir))
        print_upload_message <- ifelse(length(updated) > 0, TRUE, FALSE)
        }
   
     #if there are new files to track [or modifed]
     if(length(new_files) > 0){
       file_names <- unname(sapply(new_files, track_blfs, dir))
       
       warning("the following files will no longer be tracked by git:\n", paste(file_names, collapse="\n"))
       print_upload_message <- TRUE
     }
   
   #print upload message 
   if(print_upload_message){
     upld_message(dir)}
   }
   
## cloning a repo with box-lfs 
 clone_repo_blfs <- function(dir=NULL, download=NULL){
   dir <- dir_check(dir)
   
   #check if lfs is needed 
   if(check_blfs(dir)){
       dwld_message(dir)
       
       uploaded <- readline("hit any key once files have been downloaded to continue setting up the repo")
       
       #unzip from downloads folder and put in the right spot 
       if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}
       
       #may have multiple copies, get the newest
       file <- list.files(downloads, pattern=paste0("^",basename(repo), "( \\(\\d+\\))?\\.zip$"))
       file_info <- file.info(file.path(downloads, file))
       file <- file[which(file_info$mtime == max(file_info$mtime))]
       
       #unzip
       utils::unzip(file.path(downloads, file),
                    exdir = downloads)
       
       #get file that need to be moved
       files <- list.files(file.path(downloads, basename(repo)))
       
       #move files to correct location
       place <- sapply(files, move_box_lfs, dir=dir, download=download)
     
   }
 }

## pull a repo with box-lfs (someone may have added box files that need to updated)
 pull_repo_blfs <- function(dir=NULL, download=NULL){
   dir <- dir_check(dir)
   
   #check if file need to be updated
   trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
   files <- sapply(trackers, read.boxtracker, dir=dir, return="file_path")
   updated <- sapply(files, update_blfs, dir=dir)
   updated <- updated[!is.na(updated)]
   
   if(length(updated) >0){
     dwld_message(dir)
     
     uploaded <- readline("hit any key once files have been downloaded to continue updating files")
     
     #unzip from downloads folder and put in the right spot 
     if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}
     
     #may have multiple copies, get the newest
     file <- list.files(downloads, pattern=paste0("^",basename(repo), "( \\(\\d+\\))?\\.zip$"))
     file_info <- file.info(file.path(downloads, file))
     file <- file[which(file_info$mtime == max(file_info$mtime))]
     
     #unzip
     utils::unzip(file.path(downloads, file),
                  exdir = downloads)
     
     #get file that need to be moved
     files <- file.path(download, basename(updated))
     
     #move files to correct location
     place <- sapply(files, move_box_lfs, dir=dir, download=download)
     
   }
 }
 