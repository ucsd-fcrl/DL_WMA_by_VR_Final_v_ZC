#!/usr/bin/env python

# this script partition the dataset into N subsamples for n-fold cross_validation.
# the partition is based on patient.
# the output is a excel spreadsheet listing all subsamples.


import os
import numpy as np
import supplement
import random
import function_list_VR as ff
import pandas as pd
from sklearn.model_selection import train_test_split
cg = supplement.Experiment() 


excel_file = pd.read_excel(os.path.join(cg.save_dir,'Patient_List/movie_list_w_classes_w_picked_timeframes_train.xlsx'))
# get patient_list
patient_list = [excel_file.iloc[i]['Patient_ID'] for i in range(excel_file.shape[0])]
patient_list = np.unique(np.asarray(patient_list))

# if partition not done
# randomly partition while ensuring the class ratio in each subsample is close to the populational class ratio

# calculate the populational ratio for each view angle
populational_ratio = []
for angle in [0,60,120,180,240,300]:
    data_list = excel_file.loc[excel_file['angle'] == angle]
    abnormal_list = data_list.loc[data_list['class'] == 'abnormal']
    populational_ratio.append(abnormal_list.shape[0] / data_list.shape[0])
all_angle_populational_ratio = sum(populational_ratio) / len(populational_ratio)
print(populational_ratio,all_angle_populational_ratio)

# random shuffle until criterias are satisfied
std = 0.06
while 1:
    satisfy = 0
    seed = np.random.randint(100000)
    np.random.seed(seed)
    np.random.shuffle(patient_list)
    patient_list_split = np.array_split(patient_list,cg.num_partitions)

    Ratio = []; ALL_ANGLE_RATIO = []
    for ii in range(0,len(patient_list_split)):
        patient_group = patient_list_split[ii]
        group_ratio = []
        for angle in [0,60,120,180,240,300]:
            abnormal_count = 0
            for p in patient_group:
                case = excel_file.loc[(excel_file['Patient_ID'] == p) & (excel_file['angle'] == angle)]
                    
                if case.iloc[0]['class'] == 'abnormal':
                        abnormal_count += 1
            group_ratio.append(abnormal_count / patient_group.shape[0])

        all_angle_group_ratio = sum(group_ratio) / len(group_ratio)
        Ratio.append(group_ratio)
        ALL_ANGLE_RATIO.append(all_angle_group_ratio)

    # check whether satisfy    
    check_all_angle = []
    # check all_angle first
    for ii in range(0,len(patient_list_split)):
        a = ALL_ANGLE_RATIO[ii]
        if (a <= (all_angle_populational_ratio + std)) and  (a >= (all_angle_populational_ratio - std)):
            check_all_angle.append(1)
        else:
            check_all_angle.append(0)

    # check per_angle
    check_per_angle = []
    for ii in range(0,len(patient_list_split)):
        for jj in range(0,6): # 6 angles
            a = Ratio[ii][jj]
            if (a <= (populational_ratio[jj] + std)) and (a >= (populational_ratio[jj] - std)):
                check_per_angle.append(1)
            else:
                check_per_angle.append(0)

    print(check_all_angle,np.where(np.asarray(check_per_angle) == 0)[0].shape[0] )
        
    # satisfication criteria
    if (np.all(np.asarray(check_all_angle)) == True) and np.where(np.asarray(check_per_angle) == 0)[0].shape[0] <= 3:
        satisfy = 1
                
    if satisfy == 1:
        print('seed is ', seed, ' ratios are: ', Ratio, ALL_ANGLE_RATIO)
        break
  

# save the partition results into numpy files
np_save_folder = os.path.join(cg.save_dir,'partitions/angle_all')
ff.make_folder([os.path.basename(np_save_folder),np_save_folder])
batch_list = []
for i in range(cg.num_partitions):
    batch_list.append(patient_list_split[i])
    print(batch_list[i].shape)
    np.save(os.path.join(np_save_folder,'batch_'+str(i)+'.npy'), batch_list[i])

# save the partition results into data_file.xlsx
batch_file = []
for i in range(0,excel_file.shape[0]):
    case = excel_file.iloc[i]
    for batch in range(cg.num_partitions):
        if np.isin(case['Patient_ID'],patient_list_split[batch]) == 1:
            B = batch
    batch_file.append([B, case['video_name']])

batch_file = pd.DataFrame(batch_file,columns = ['batch','video_name'])
df = pd.merge(batch_file,excel_file,on = 'video_name')
df.to_excel(os.path.join(cg.save_dir,'Patient_List/data_file_angle_all_train.xlsx'),index=False)


# if already have partitions done:
# numpy_files = ff.find_all_target_files(['*.npy'],os.path.join(cg.save_dir,'partitions/angle_all'))
# patient_list_split = []
# for b in range(0,5):
#     numpy_file = ff.find_all_target_files(['batch_'+str(b)+'.npy'],os.path.join(cg.save_dir,'partitions/angle_all'))
#     bb = np.load(numpy_file[0])
#     patient_list_split.append(bb)
# print(patient_list_split)

# # save into data_file.xlsx
# batch_file = []
# for i in range(0,excel_file.shape[0]):
#     case = excel_file.iloc[i]
#     #print(case['video_name'])
#     for batch in range(cg.num_partitions):
#         if np.isin(case['Patient_ID'],patient_list_split[batch]) == 1:
#             B = batch
                
#     batch_file.append([B, case['video_name']])

# batch_file = pd.DataFrame(batch_file,columns = ['batch','video_name'])
# df = pd.merge(batch_file,excel_file,on = 'video_name')
# df.to_excel(os.path.join(cg.save__dir,'Patient_List/data_file_classes_train.xlsx'),index=False)
    
