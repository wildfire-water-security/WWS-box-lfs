## Helper functions used to manage files for the box-large file storage system 
    #works similar to native lfs but clunkier because box, but helps store large files on box, while linking as easily
    #as possible to a cloned repository from github.

import os
import shutil
from pathlib import Path
import pandas as pd
import numpy as np
from datetime import datetime

#read a boxtracker
def read_boxtracker(tracker, dir=None, return_column="all"):
    #if dir not specified try to guess from wd
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)
    tracker = Path(tracker)

    #ensure directory exists, if not give error
    if not dir.is_dir():
        raise ValueError(f"The directory '{dir}' does not exist.")
    
    if not tracker.suffix == ".boxtracker":
        raise ValueError(f"tracker must have a '.boxtracker' extension")

    #get path of tracker and read in
    tracker_path = dir /  "box-lfs" / tracker
    tracker_df = pd.read_csv(tracker_path, sep=",")

    #get columns as needed
    if return_column == "all":
        data = tracker_df
    elif isinstance(return_column, list):
        data = tracker_df[return_column]
    else:
    # If there's only one column requested, return as a list of values (not a DataFrame)
        data = tracker_df[return_column].iloc[0]
    
    return data 

#get info for boxtracker based on a file
def get_boxtracker(file, dir=None): 
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.is_dir():
        raise ValueError(f"Directory '{dir}' does not exist.")

    file_path = dir / file

    if not file_path.exists():
        raise FileNotFoundError(f"File '{file_path}' does not exist.")

    # Get base name without extension and create .boxtracker name
    tracker_name = file_path.stem + ".boxtracker"

    # Get file info
    stat = file_path.stat()

    tracker = pd.DataFrame([{
        "file_path": file,
        "box_link": np.nan,
        "size_MB": stat.st_size / 1_000_000,
        "last_modified": datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S"),
        "last_changed": datetime.fromtimestamp(stat.st_ctime).strftime("%Y-%m-%d %H:%M:%S")
    }])

    return tracker 

#write boxtracker file to box-lfs
def write_boxtracker(file, dir=None):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.is_dir():
        raise ValueError(f"Directory '{dir}' does not exist.")

    file_path = dir / file
    if not file_path.exists():
        raise FileNotFoundError(f"File '{file_path}' does not exist.")

    # Generate tracker name
    tracker_name = file_path.stem + ".boxtracker"

    # Get tracker DataFrame
    tracker = get_boxtracker(file, dir)

    # Write to CSV (no row names, no quotes)
    output_path = dir / "box-lfs" / tracker_name
    output_path.parent.mkdir(parents=True, exist_ok=True)  # make sure folder exists

    tracker.to_csv(output_path, index=False, quoting=3)  # quoting=3 is csv.QUOTE_NONE

#add a single file to box lfs
def track_blfs(file, dir=None):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.is_dir():
        raise ValueError(f"Directory '{dir}' does not exist.")

    file_path = dir / file
    if not file_path.exists():
        raise FileNotFoundError(f"File '{file}' does not exist in '{dir}'.")

    # Step 1: create tracking file
    write_boxtracker(file, dir)

    # Step 2: add file to .gitignore
    gitignore_path = dir / ".gitignore"
    if not gitignore_path.exists():
        gitignore_path.touch()

    # Read existing lines and check if file already added
    ignore_lines = gitignore_path.read_text().splitlines()
    if not any(line.strip() == file for line in ignore_lines):
        with gitignore_path.open("a") as f:
            f.write(f"\n{file}")

    # Step 3: move file to box-lfs/upload
    upload_dir = dir / "box-lfs" / "upload"
    upload_dir.mkdir(parents=True, exist_ok=True)
    dest_file_path = upload_dir / file_path.name
    shutil.copy2(file_path, dest_file_path)

    # Step 4: return file name
    return file  

#set up box lfs 
def init_blfs(dir=None):
    # Use current working directory if none is provided
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.is_dir():
        raise ValueError(f"Directory '{dir}' does not exist.")

    # Step 1: Create folder structure
    (dir / "box-lfs").mkdir(parents=True, exist_ok=True)
    (dir / "box-lfs" / "upload").mkdir(parents=True, exist_ok=True)

    # Step 2: Update .gitignore with 'box-lfs/upload'
    gitignore_path = dir / ".gitignore"
    if not gitignore_path.exists():
        gitignore_path.touch()

    ignore_lines = gitignore_path.read_text().splitlines()
    if "box-lfs/upload" not in [line.strip() for line in ignore_lines]:
        with gitignore_path.open("a") as f:
            f.write("\nbox-lfs/upload")

#check for files that should be tracked 
def check_files_blfs(dir=None, size=10, new=False):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.is_dir():
        raise ValueError(f"Directory '{dir}' does not exist.")

    # Step 1: Get all files recursively
    all_files = [f for f in dir.rglob("*") if f.is_file()]
    relative_files = [f.relative_to(dir).as_posix() for f in all_files]

    # Step 2: Get file sizes in MB
    sizes = [f.stat().st_size / 1e6 for f in all_files]
    large_files = [rel for rel, sz in zip(relative_files, sizes) if sz > size]

    # Step 3: Remove files already in box-lfs/upload or .git
    large_files = [f for f in large_files if not f.startswith("box-lfs/upload/")]
    large_files = [f for f in large_files if not f.startswith(".git/objects")]
    
    # Step 4: Remove tracked files if `new=True`
    if new and (dir / "box-lfs").exists():
        tracked_files = [f.name for f in (dir / "box-lfs").iterdir() if f.name != "upload"]
        current_tracked = [read_boxtracker(tracker, dir=dir, return_column="file_path")  for tracker in tracked_files]

        large_files = list(set(large_files) - set(current_tracked))

    return large_files 

#copy files from download to correct repo spots 
def move_file_blfs(file, dir=None, download=None):
    # Set default paths
    if download is None:
        download = Path(os.path.expanduser("~")) / "Downloads"
    else: 
        download = Path(download)

    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    # Safety checks
    if not dir.is_dir():
        raise FileNotFoundError(f"Directory does not exist: {dir}")
    if not download.is_dir():
        raise FileNotFoundError(f"Download folder does not exist: {download}")
    
    # Get tracker info
    name = Path(file).stem  # removes file extension
    tracker_path = dir / "box-lfs" / f"{name}.boxtracker"
    tracker_df = pd.read_csv(tracker_path)

    # Get destination relative path from tracker
    location = tracker_df["file_path"].iloc[0]
    dest_path = dir / location

    # Copy the file
    src_file = download / dir.name / Path(file).name
    shutil.copy2(src_file, dest_path)

#check if box lfs is being used on repo (returns T/F)
def check_blfs(dir=None):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.exists():
        raise FileNotFoundError(f"Directory does not exist: {dir}")

    return (dir / "box-lfs").exists() 

#update file tracked by blfs (check for differences return TRUE if it needs to be updated) 
def update_blfs(file, dir=None):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.exists():
        raise FileNotFoundError(f"Directory does not exist: {dir}")

    # Build tracker filename
    tracker_name = file.stem + ".boxtracker" if isinstance(file, Path) else Path(file).stem + ".boxtracker"

    # Read old tracker
    old_tracker = read_boxtracker(tracker_name, dir)

    # Get new tracker info
    new_tracker = get_boxtracker(file, dir)

    # Compare dataframes (assuming old_tracker and new_tracker are pandas DataFrames)
    diff_check = not old_tracker.equals(new_tracker)

    if diff_check:
        # Copy file to upload folder
        upload_dir = dir / "box-lfs" / "upload"
        upload_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(dir / file, upload_dir / Path(file).name)

        # Rewrite tracker
        write_boxtracker(file, dir)

        return file
    else:
        return None 

#add box file location to tracker 
def add_box_loc(link, dir=None):
    if dir is None:
        dir = Path.cwd()
    else:
        dir = Path(dir)

    if not dir.exists():
        raise FileNotFoundError(f"Directory does not exist: {dir}")

    box_lfs_dir = dir / "box-lfs"
    if not box_lfs_dir.exists():
        raise FileNotFoundError(f"'box-lfs' directory does not exist in {dir}")

    # Iterate over all .boxtracker files in box-lfs
    for tracker_file in box_lfs_dir.glob("*boxtracker"):
        tracker_df = pd.read_csv(tracker_file)

        # Update box_link column
        tracker_df["box_link"] = link

        # Write back to CSV without row names and without quotes
        tracker_df.to_csv(tracker_file, index=False, quoting=3)  # quoting=3 => csv.QUOTE_NONE
