#!/usr/bin/env python

# this script uses a pre-trained CNN ("Inception v3") to extract image feature from the image of each time frame
# then combine the features into a feature sequence.

"""
This script generates extracted features for each video, which other
models make use of.

You can change you sequence length and limit to a set number of classes
below.

class_limit is an integer that denotes the first N classes you want to
extract features from. This is useful is you don't want to wait to
extract all 101 classes. For instance, set class_limit = 8 to just
extract features for the first 8 (alphabetical) classes in the dataset.
Then set the same number when training models.
"""

'''
for each time frame, (2048,0) is the dimension of features extracted.
'''

import numpy as np
import os
from DLWMA_util_data import DataSet
from DLWMA_util_extractor import Extractor
from tqdm import tqdm
import supplement
import function_list_VR as ff
import time
cg = supplement.Experiment() 
main_path = cg.local_dir
architecture = 'InceptionV3'

# Set defaults.
class_limit = None  # Number of classes to extract. Can be 1-101 or None for all.
data_file = os.path.join(cg.save_dir,'Patient_List/movie_list_w_walls_w_picked_timeframes_test.xlsx')

# Get the dataset.
data = DataSet(data_file = data_file,validation_batch = 0, seq_length = 0,  class_limit=class_limit)

# get the model.
model = Extractor(architecture)

# get a folder for sequence save
safe_folder = 'sequences_'+architecture
ff.make_folder([os.path.join(main_path,safe_folder)])


for i in range(0,len(data.data)):
    case = data.data[i]
    file_name = case['video_name']
    file_name_no_ext = case['video_name_no_ext']
    # print(file_name)

    # Get the path to the sequence for this video.
    path = os.path.join(main_path, safe_folder, case['Patient_Class'],case['Patient_ID'],file_name_no_ext + 
        '-features.npy')  
    
    ff.make_folder([os.path.join(main_path,safe_folder),os.path.join(main_path,safe_folder,case['Patient_Class']),os.path.join(main_path, safe_folder, case['Patient_Class'],case['Patient_ID'])])

    # Check if we already have it.
    if os.path.isfile(path):
        print('done')
        continue

    # Get the frames for this video.
    frames = data.get_frames_for_sample(case)
  
    # Now loop through and extract features to build the sequence.
    sequence = []
    for image in frames:
        features = model.extract(image)
        sequence.append(features)
    sequence = np.asarray(sequence)
    print(sequence.shape)

    # Save the sequence.
    np.save(path, sequence)
