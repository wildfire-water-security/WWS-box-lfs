## Functions used to manage files for the box-large file storage system 
    #works similar to native lfs but clunkier because box, but helps store large files on box, while linking as easily
    #as possible to a cloned repository from github. 

import os
import sys
from pathlib import Path
import pandas as pd
import numpy as np
import zipfile

# Replace with the path to the folder containing your helper script (remove later??)
helpers_dir = Path(r"C:\Users\wampleka\Documents\Projects\WWS-box-lfs\python-exe\source_code").resolve()

# Add it to sys.path if not already there 
if str(helpers_dir) not in sys.path:
    sys.path.insert(0, str(helpers_dir))

import box_lfs_helpers



#start tracking new repo with box-lfs
def new_repo_blfs(dir=None, size=10):
    box_lfs_helpers.dir_check(dir)
    
    # Set up file structure
    box_lfs_helpers.init_blfs(dir)
    
    # Identify large files and track them
    files = box_lfs_helpers.check_files_blfs(dir, size=size)
    file_names = [box_lfs_helpers.track_blfs(file, dir) for file in files]
    
    # Print warning about files no longer tracked by git
    print("WARNING: The following files will no longer be tracked by git:\n" + "\n".join(file_names))
    
    # Message about uploading files
    box_lfs_helpers.upld_message(dir)

    # Ask user for Box link
    link = input("What is the box link to the folder where the data is now backed up? ")
    
    # Attach box link to the files
    box_lfs_helpers.add_box_loc(link, dir)
    
##test function does what we expect
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
new_repo_blfs(dir=dir)

#check files after a push 
def push_repo_blfs(dir=None, size=10):
    box_lfs_helpers.dir_check(dir)
    
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
        box_lfs_helpers.upld_message(dir)

##test function does what we expect
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
push_repo_blfs(dir=dir)

#get files after a clone 
def clone_repo_blfs(dir=None, download=None):
    dir =  box_lfs_helpers.dir_check(dir)
    repo_name = dir.name

    # Check if LFS is needed
    if  box_lfs_helpers.check_blfs(dir):
        box_lfs_helpers.dwld_message(dir)
        input("Hit any key once files have been downloaded to continue setting up the repo...")

        # Set download path
        if download is None:
            download = Path.home() / "Downloads"
        else:
            download = Path(download)

        # Find the newest matching zip file
        zip_files = sorted(
            download.glob("box-lfs*.zip"),
            key=lambda f: f.stat().st_mtime,
            reverse=True
        )

        if not zip_files:
            print(f"No zip file found in {download} for {repo_name}")
            return
        

        #give user to correct wrong guessed zip
        file = zip_files[0]
        guess = download / file
        replace = input(f"Zip file for downloaded data appears to be: {guess}\n" 
                        "Press enter to use this file or provide a different file path: ").strip()
       
        if replace: 
            replace = Path(replace)
            if replace.exists():
                file = replace 
            else: 
                raise FileNotFoundError("The specified file does not exist.")
        else: 
            file = file

        # Unzip it into Downloads folder
        with zipfile.ZipFile(file, 'r') as zip_ref:
            zip_ref.extractall(download)

        # Get unzipped folder contents
        extracted_folder = download / file.stem
        
        files = list(extracted_folder.iterdir())

        # Move files to box-lfs directory
        for file in files:
             box_lfs_helpers.move_file_blfs(file.name, dir=dir, download=download)
