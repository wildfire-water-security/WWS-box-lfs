## Functions used to manage files for the box-large file storage system 
    #works similar to native lfs but clunkier because box, but helps store large files on box, while linking as easily
    #as possible to a cloned repository from github. 

import box_lfs_helpers
import os
from pathlib import Path

def new_repo_blfs(dir=None, size=10):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)
    
    if not dir.exists():
        raise FileNotFoundError(f"Directory does not exist: {dir}")
    
    # Set up file structure
    init_blfs(dir)
    
    # Identify large files and track them
    files = check_files_blfs(dir, size=size)
    file_names = [track_blfs(file, dir) for file in files]
    
    # Print warning about files no longer tracked by git
    print("WARNING: The following files will no longer be tracked by git:\n" + "\n".join(file_names))
    
    # Message about uploading files
    print(f"Please upload files from '{dir.name}/box-lfs/upload' to Box here:\n"
          f"'Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects-large-file-backup/{dir.name}'")
    
    # Ask user for Box link
    link = input("What is the box link to the folder where the data is now backed up? ")
    
    # Attach box link to the files
    add_box_loc(link, dir)
    
##test function does what we expect
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
new_repo_blfs(dir=dir)
