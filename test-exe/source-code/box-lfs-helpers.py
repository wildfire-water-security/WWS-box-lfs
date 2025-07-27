import os
from pathlib import Path
import pandas as pd
import numpy as np
from datetime import datetime


def read_boxtracker(tracker, dir=None, return_column="all"):
    #if dir not specified try to guess from wd
    if dir is None:
        dir = os.getcwd()

    #make into pathlib objects 
    dir = Path(dir)
    tracker = Path(tracker)

    #ensure directory exists, if not give error
    if not os.path.isdir():
        raise ValueError(f"The directory '{dir}' does not exist.")
    
    if not tracker.suffix == ".boxtracker":
        raise ValueError(f"tracker must have a '.boxtracker' extension")

    #get path of tracker and read in
    tracker_path = os.path.join(dir, "box-lfs", tracker)
    tracker_df = pd.read_csv(tracker_path, sep=",")

    #get columns as needed
    if return_column == "all":
        data = tracker_df
    else:
        # Support for returning a single column or list of columns
        if isinstance(return_column, list):
            data = tracker_df[return_column]
        else:
            data = tracker_df[[return_column]]
    
    return data 

#test function does what we expect
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
output = read_boxtracker("B07B08.boxtracker", dir=dir)
print(output)

def get_boxtracker(file, dir=None): 
    if dir is None:
        dir = os.getcwd()

    if not os.path.isdir(dir):
        raise ValueError(f"Directory '{dir}' does not exist.")

    file_path = Path(dir) / file

    if not file_path.exists():
        raise FileNotFoundError(f"File '{file_path}' does not exist.")

    # Get base name without extension and create .boxtracker name
    tracker_name = file_path.stem + ".boxtracker"

    # Get file info
    stat = file_path.stat()

    tracker = pd.DataFrame([{
        "file_path": str(os.path.relpath(file_path, start=dir)),
        "box_link": np.nan,
        "size_MB": stat.st_size / 1_000_000,
        "last_modified": datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S"),
        "last_changed": datetime.fromtimestamp(stat.st_ctime).strftime("%Y-%m-%d %H:%M:%S")
    }])

    return tracker 

#test function does what we expect
file = "Site_selected_20250521/B07B08.kmz" 
dir = "C:/Users/wampleka/Documents/Projects/testing-lfs"
output = get_boxtracker(file=file, dir=dir)

#file path is full path, not relative