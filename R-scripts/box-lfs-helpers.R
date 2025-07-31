
## get file location or other data from tracker
  read.boxtracker <- function(tracker,dir=NULL, return="all"){
    dir <- dir_check(dir)
    
    tracker <- utils::read.csv(file.path(dir, "box-lfs", tracker),sep = ",")
    
    if(return == "all"){
      data <- tracker
    }else{
      data <- tracker[return]
    }
    return(data)
  }

## get and format info for tracker file (but don't write to file)
  get.boxtracker <- function(file, dir=NULL){
    dir <- dir_check(dir)
    
    tracker_name <- paste0(tools::file_path_sans_ext(basename(file)), ".boxtracker")
    
    #get info on file
    info <- file.info(file.path(dir, file))
    
    tracker <- data.frame(file_path=file, box_link = NA, size_MB =  info$size*10^-6, 
                          last_modified = strftime(info$mtime, "%Y-%m-%d %H:%M:%S"),
                          last_changed = strftime(info$ctime, "%Y-%m-%d %H:%M:%S"))
    return(tracker)
  }
  
## function to write tracker file
  write.boxtracker <- function(file, dir=NULL){
    dir <- dir_check(dir)
    tracker_name <- paste0(tools::file_path_sans_ext(basename(file)), ".boxtracker")
    
    tracker <- get.boxtracker(file, dir)
    
    # Get link if it exists in previous version
    if(file.exists(file.path(dir, "box-lfs", tracker_name))){
      link <- read.boxtracker(tracker, dir=dir, return="box_link")
      tracker$box_link <- link
    }
    
    utils::write.csv(tracker, file.path(dir,"box-lfs", tracker_name), row.names = FALSE, 
                     quote=FALSE)
    
  }

## function to add a single file to box lfs 
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
  
## function to set up box lfs 
  init_blfs <- function(dir=NULL){
    #guess on dir if not supplied
    dir <- dir_check(dir)
      
    #create file stucture 
      dir.create(file.path(dir, "box-lfs"), showWarnings = FALSE) 
      dir.create(file.path(dir, "box-lfs/upload"), showWarnings = FALSE)
      
    #set up .gitignore with upload folder
      ignore <- file.path(dir, ".gitignore")
      if(!file.exists(ignore)){file.create(ignore)} #create .gitignore if it doesn't exist 
      
      #check if already in gitignore 
      added <- any(grepl("^box-lfs/upload$", readLines(ignore, warn=FALSE)))
      if(!added){cat("\nbox-lfs/upload", file=ignore, append = T)} #only add if not already there
      
  }

## check for large files that should be tracked 
  check_files_blfs <- function(dir=NULL, size=10, new=FALSE){
    dir <- dir_check(dir)
    
    #flag files that should be stored on box 
    files <- list.files(dir, full.names=F, recursive = T)
    sizes <- file.size(file.path(dir, files)) / 10^6 #in MB
    large_files <- files[sizes > size] 
    
    #remove files living in box-lfs/upload 
    large_files <- large_files[!grepl("^box-lfs/upload/", large_files)]
    
    #built in to only get new large files
    if(new & dir.exists(file.path(dir, "box-lfs"))){
      #get all tracked files
      tracked <- list.files(file.path(dir, "box-lfs"))
      tracked <- tracked[tracked != "upload"]
      
      #check for new files
      curr_track <- sapply(tracked, read.boxtracker, dir=dir, return="file_path")
      large_files <- setdiff(large_files,curr_track)
    }
    
    return(large_files)
  }
  
## copy files from download to correct repo spots 
  move_file_blfs <- function(file, dir=NULL, download=NULL){
    if(is.null(download)){download <- file.path(fs::path_home(), "Downloads")}
    if(is.null(dir)){dir <- getwd()}
    
    stopifnot(dir.exists(dir), dir.exists(download))
    
    #get tracker to know where to put it 
    name <- tools::file_path_sans_ext(basename(file))
    tracker <- utils::read.csv(file.path(dir, "box-lfs", paste0(name, ".boxtracker")),sep = ",")
    
    location <- tracker$file_path
    
    #copy file to correct location 
    file.copy(file.path(downloads, basename(dir), file), file.path(dir,location))
  }

## check if box lfs is being used on repo (returns T/F)
  check_blfs <- function(dir){
    dir <- dir_check(dir)
    
    return <- dir.exists(file.path(dir, "box-lfs"))
    return(return)
  }

## update file tracked by blfs (check for differences return TRUE if it needs to be updated)
  update_blfs <- function(file, dir=NULL){
    dir <- dir_check(dir)
    
    #get file info
    tracker_name <- paste0(tools::file_path_sans_ext(basename(file)), ".boxtracker")
    
    old_tracker <- read.boxtracker(tracker_name, dir)
    new_tracker <- get.boxtracker(file, dir)

    diff_check <- !all.equal(old_tracker, new_tracker) #check if new file is different than tracked one, T means different
    
    #if so, updated tracked and move to upload for easy upload
    if(diff_check){
      file.copy(file.path(dir, file), file.path(dir, "box-lfs/upload/", basename(file)))
      write.boxtracker(file, dir) 
      return(file)
    }
    
  }
  
## add box file location to tracker 
  add_box_loc <- function(link, dir=NULL){
    dir <- dir_check(dir)
    
    for(x in list.files(file.path(dir, "box-lfs"), pattern="boxtracker")){
      tracker <- read.boxtracker(x, dir)
      tracker$box_link <- link
      
      utils::write.csv(tracker, file.path(dir,"box-lfs", x), row.names = FALSE, 
                       quote=FALSE)
    }
  }
  
## guess directory and make sure it exists 
  dir_check <- function(dir){
    #guess on dir if not supplied
    if(is.null(dir)){dir <- getwd()}
    stopifnot(dir.exists(dir))
    return(dir)
  }
  
## message about uploading data 
  upld_message <- function(dir){
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
  
## message about downloading data 
  dwld_message <- function(dir){
    #try to direct right to link
    trackers <- list.files(file.path(dir, "box-lfs"), pattern = ".boxtracker")
    link <- unlist(sapply(trackers,read.boxtracker, dir=dir, return="box_link"))
    link <- link[!is.na(link)]
    
    if(length(link) > 0){
      message(paste0("there are large files in this repository stored on box that need to be downloaded. Please download files, likely located here:\n",
                     paste(link, collapse="\n"),
                     "\nthey will be automatically moved to the correct locations from your downloads folder")))
      
    }else{
      message(paste0("Please download files from Box here:\n'Wildfire_Water_Security/02_Nodes/your node/Projects/", 
                     basename(dir), "/box-lfs", "'", "\nthey will be automatically moved to the correct locations from your downloads folder")))}
    
  }