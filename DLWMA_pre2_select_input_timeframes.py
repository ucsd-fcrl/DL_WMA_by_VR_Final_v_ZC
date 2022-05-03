#!/usr/bin/env python

# this script defines 4 systolic timeframes that will be input into the model and put these frames number into the spreadsheet

import os
import numpy as np
import supplement
import pandas as pd
import nibabel as nb
import function_list_VR as ff
cg = supplement.Experiment() 

excel_file = pd.read_excel(os.path.join(cg.save_dir,'Patient_List/movie_list_w_classes_train.xlsx'))
# get patient_list:
patient_id_list = np.unique(excel_file['Patient_ID'])
patient_list = []
for p in patient_id_list:
    d = excel_file[excel_file['Patient_ID'] == p].iloc[0]
    patient_list.append([d['Patient_Class'],p])

# get their segmentations and find the ES
timeframe_pick = []
for p in patient_list:
    patient_class = p[0]
    patient_id = p[1]

    # find frames
    segmentations = ff.sort_timeframe(ff.find_all_target_files(['pred_*.nii.gz'],os.path.join(cg.nas_main_dir,'predicted_seg',patient_class,patient_id,'seg-pred-0.625-4classes-connected-retouch-downsample')),2,'_')
    ED,ES,interval1, interval2 = ff.find_model_input_frames(segmentations)
        

    video_list = excel_file[excel_file['Patient_ID'] == patient_id]
    for ii in range(0,video_list.shape[0]):
        timeframe_pick.append([video_list.iloc[ii]['video_name'],ED,ES,interval1,interval2])


column_list = ['video_name','ED','ES','interval1','interval2']
timeframe_pick_df = pd.DataFrame(timeframe_pick, columns = column_list)
df = pd.merge(excel_file, timeframe_pick_df, on = "video_name")
df.to_excel(os.path.join(cg.save_dir,'Patient_List/movie_list_w_classes_w_picked_timeframes_train.xlsx'),index = False)
    


    



    



        



