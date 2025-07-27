import os
from pathlib import Path
import pandas as pd

def read_boxtracker(tracker, dir=None, return_column="all"):
    #if dir not specified try to guess from wd
    if dir is None:
        dir = os.getcwd()

    #make into pathlib objects 
    dir = Path(dir)
    tracker = Path(tracker)

    #ensure directory exists, if not give error
    if not dir.is_dir():
        raise ValueError(f"The directory '{dir}' does not exist.")
    
    if not tracker.suffix == ".boxtracker":
        raise ValueError(f"tracker must have a '.boxtracker' extension")

    tracker_path = os.path.join(dir, "box-lfs", tracker)
    tracker_df = pd.read_csv(tracker_path, sep=",")

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
output = read_boxtracker("B07B08.boxtracker", dir=dir)
print(output)