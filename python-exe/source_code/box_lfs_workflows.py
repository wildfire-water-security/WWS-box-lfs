## Functions used to manage files for the box-large file storage system 
    #works similar to native lfs but clunkier because box, but helps store large files on box, while linking as easily
    #as possible to a cloned repository from github. 

import os
import sys
from pathlib import Path
import pandas as pd


# Replace with the path to the folder containing your helper script (remove later??)
helpers_dir = Path(r"C:\Users\wampleka\Documents\Projects\WWS-box-lfs\python-exe\source_code").resolve()

# Add it to sys.path if not already there 
if str(helpers_dir) not in sys.path:
    sys.path.insert(0, str(helpers_dir))

import box_lfs_helpers

#start tracking new repo with box-lfs
def new_repo_blfs(dir=None, size=10):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)
    
    if not dir.exists():
        raise FileNotFoundError(f"Directory does not exist: {dir}")
    
    # Set up file structure
    box_lfs_helpers.init_blfs(dir)
    
    # Identify large files and track them
    files = box_lfs_helpers.check_files_blfs(dir, size=size)
    file_names = [box_lfs_helpers.track_blfs(file, dir) for file in files]
    
    # Print warning about files no longer tracked by git
    print("WARNING: The following files will no longer be tracked by git:\n" + "\n".join(file_names))
    
    # Message about uploading files
    print(f"Please upload files from '{dir.name}/box-lfs/upload' to Box here:\n"
          f"'Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects-large-file-backup/{dir.name}'")
    
    # Ask user for Box link
    link = input("What is the box link to the folder where the data is now backed up? ")
    
    # Attach box link to the files
    box_lfs_helpers.add_box_loc(link, dir)
    
##test function does what we expect
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
new_repo_blfs(dir=dir)

#check files after a push 
def push_repo_blfs(dir=None, size=10):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)
    
    if not dir.exists():
        raise FileNotFoundError(f"Directory does not exist: {dir}")
    
    # Identify new large files to track
    files = box_lfs_helpers.check_files_blfs(dir, size=size, new=True)
    
    if files:  # if list is not empty
        file_names = [box_lfs_helpers.track_blfs(file, dir) for file in files]
        
        print("WARNING: The following files will no longer be tracked by git:\n" + "\n".join(file_names))
        
        # Get list of tracker files
        trackers = list((dir / "box-lfs").glob("*.boxtracker"))
        
        # Read box_link from each tracker
        links = []
        for tracker in trackers:
            df = box_lfs_helpers.read_boxtracker(tracker.name, dir=dir, return_column="box_link")
            if not df.empty:
                val = df.iloc[0]
                if pd.notna(val):
                    links.append(val)
        
        if links:
            print(f"Please upload files from '{dir.name}/box-lfs/upload' to Box here:\n{links[0]}")
        else:
            print(
                f"Please upload files from '{dir.name}/box-lfs/upload' to Box here:\n"
                f"'Wildfire_Water_Security/02_Nodes/01_Empirical/06_Projects-large-file-backup/{dir.name}'"
            ) 

##test function does what we expect
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
push_repo_blfs(dir=dir)
