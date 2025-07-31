# testing 
  #-push/pull when file has been updated 
  #-push/pull when file has been added
  #set up existing repo 
  #clone repo

## setting up a new repo (existing)
 new_repo_blfs <- function(dir=NULL, size=10){
   #guess on dir if not supplied
   if(is.null(dir)){dir <- getwd()}
   stopifnot(dir.exists(dir))
   
   #set up file structure
   init_blfs(dir)
   
   #identify large files and track 
   files <- check_files_blfs(dir, size=size)
   file_names <- unname(sapply(files, track_blfs, dir))
   
   warning("the following files will no longer be tracked by git:\n", paste(file_names, collapse="\n"))
   
   message(paste0("Please upload files from '", basename(dir), 
                  "/box-lfs/upload' to Box here:\n'Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects-large-file-backup/", basename(dir), "'"))
   
   #attach box link to the files
   link <- readline("what is the box link to the folder where the data is now backed up? ")
   add_box_loc(link, dir)
 }
 
## pushing repo (potential new files that need to be tracked)
 push_repo_blfs <- function(dir=NULL, size=10){
   #guess on dir if not supplied
   if(is.null(dir)){dir <- getwd()}
   stopifnot(dir.exists(dir))
   
   #identify large files and track 
   files <- check_files_blfs(dir, size=size, new=TRUE)
   
   #if there are new files to track [or modifed]
   if(length(files) > 0){
     file_names <- unname(sapply(files, track_blfs, dir))
     
     warning("the following files will no longer be tracked by git:\n", paste(file_names, collapse="\n"))
     
     #get folder link to go directly 
     trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
     link <- sapply(trackers,read.boxtracker, dir=dir, return="box_link")
     link <- link[!is.na(link)]
     
     if(length(link) > 0){
       message(paste0("Please upload files from '", basename(dir), 
                      "/box-lfs/upload' to Box here:\n", link[1]))
       
     }else{
       message(paste0("Please upload files from '", basename(dir), 
                      "/box-lfs/upload' to Box here:\n'Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects-large-file-backup/", 
                      basename(dir), "'"))
       
     }}}
   
## cloning a repo with box-lfs 
 clone_repo_blfs <- function(dir=NULL, download=NULL){
   #guess on dir if not supplied
   if(is.null(dir)){dir <- getwd()}
   stopifnot(dir.exists(dir))
   
   #check if lfs is needed 
   if(check_blfs(dir)){
     #try to direct right to link
       trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
       link <- sapply(trackers,read.boxtracker, dir=dir, return="box_link")
       link <- link[!is.na(link)]
     
      #tell user to download data
       if(length(link) > 0){
         message(paste0("there are large files in this repository stored on box, please download files, likely located here:\n",
                        paste(link, collapse="\n"),
                        "\nand place here:\n",
                        file.path(dir, "box-lfs/upload")))
         
       }else{
         message(paste0("Please upload files from '", basename(dir), 
                        "/box-lfs/upload' to Box here:\n'Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects-large-file-backup/", 
                        basename(dir), "'"))}
       
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
   #guess on dir if not supplied
   if(is.null(dir)){dir <- getwd()}
   stopifnot(dir.exists(dir))
   
   #check if file need to be updated
   trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
   files <- sapply(trackers, read.boxtracker, dir=dir, return="file_path")
   updated <- sapply(files, update_blfs, dir=dir)
   updated <- updated[!is.na(updated)]
   
   if(length(updated) >0){
     #try to direct right to link
     trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
     link <- sapply(trackers,read.boxtracker, dir=dir, return="box_link")
     link <- link[!is.na(link)]
     
     #tell user to download data
     if(length(link) > 0){
       message(paste0("there are large files in this repository stored on box that need to be updated, please download files, likely located here:\n",
                      paste(link, collapse="\n"),
                      "\nand place here:\n",
                      file.path(dir, "box-lfs/upload")))
       
     }else{
       message(paste0("Please upload files from '", basename(dir), 
                      "/box-lfs/upload' to Box here:\n'Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects-large-file-backup/", 
                      basename(dir), "'"))}
     
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
 