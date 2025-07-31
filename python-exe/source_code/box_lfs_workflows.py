## Functions used to manage files for the box-large file storage system 
    #works similar to native lfs but clunkier because box, but helps store large files on box, while linking as easily
    #as possible to a cloned repository from github. 

import os
import sys
from pathlib import Path
import pandas as pd
import numpy as np


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
    
    # identify large files (new and existing)
    lg_files = box_lfs_helpers.check_files_blfs(dir, size=size)
    new_files = box_lfs_helpers.check_files_blfs(dir, size=size, new=True)

    # check if any of the tracked files are modified
    tk_files = list(set(lg_files) - set(new_files))
    print_upload_message = False

    # see if any existing files need to be re-uploaded
    if tk_files:
        updated = []
        for f in tk_files:
            result = box_lfs_helpers.update_blfs(f, dir=dir)
            if isinstance(result, list):
                updated.extend(result)
            elif result:
                updated.append(result)
        if updated:
            print_upload_message = True

    # if there are new files to track
    if new_files:
        file_names = []
        for f in new_files:
            result = box_lfs_helpers.track_blfs(f, dir=dir)
            if result:
                file_names.append(result)
        
        if file_names:
            print("\nWARNING: the following files will no longer be tracked by git:\n")
            for name in file_names:
                print(name)
            print_upload_message = True

    # print upload message
    if print_upload_message:
        tracker_dir = dir / "box-lfs"
        trackers = list(tracker_dir.glob("*.boxtracker"))

    #try to pull link from trackers
        links = []
        for tracker in trackers:
            tracker_name = tracker.name
            val = box_lfs_helpers.read_boxtracker(tracker_name, dir=dir, return_column="box_link")
            if isinstance(val, str):
                links.append(val)

        folder_name = dir.name
        if links:
            print(f"\nPlease upload files from '{folder_name}/box-lfs/upload' to Box here:\n{links[0]}")
        else:
            print(f"\nPlease upload files from '{folder_name}/box-lfs/upload' to Box here:\n"
                  f"'Wildfire_Water_Security/02_Nodes/your node/Projects/{folder_name}/box-lfs'")

##test function does what we expect
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
push_repo_blfs(dir=dir)
