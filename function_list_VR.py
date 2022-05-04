#!/usr/bin/env python

# this script defined functions used in other scripts

import numpy as np
import math
import glob as gb
import glob
import os
from scipy.interpolate import RegularGridInterpolator
import nibabel as nib
from nibabel.affines import apply_affine
import math
import string
import matplotlib.pyplot as plt
import cv2
import pandas as pd

# function: read patient list from excel file
def get_patient_list_from_excel_file(excel_file,exclude_criteria = None):
    # exclude_criteria will be written as [[column_name,column_value],[column_name.column_value]]
    data = pd.read_excel(excel_file)
    data = data.fillna('')
    patient_list = []
    for i in range(0,data.shape[0]):
        case = data.iloc[i]
        if exclude_criteria != None:
            exclude = 0
            for e in exclude_criteria:
                if case[e[0]] == e[1]:
                    exclude += 1
            if exclude == len(exclude_criteria):
                continue
        
        patient_list.append([case['Patient_Class'],case['Patient_ID']])
    return patient_list
        

# function: make folders
def make_folder(folder_list):
    for i in folder_list:
        os.makedirs(i,exist_ok = True)

# function: find all files under the name * in the main folder, put them into a file list
def find_all_target_files(target_file_name,main_folder):
    F = np.array([])
    for i in target_file_name:
        f = np.array(sorted(gb.glob(os.path.join(main_folder, os.path.normpath(i)))))
        F = np.concatenate((F,f))
    return F

# function: pick the mid time frame
def pick_mid_time_frame(patient_path):
    image_list = find_all_target_files(['img-nii/*'],patient_path)
    return int(np.floor(len(image_list) / 2.0)) - 1


# function: multiple slice view
def show_slices(slices,colormap = "gray",origin_point = "lower"):
    """ Function to display row of image slices """
    fig, axes = plt.subplots(1, len(slices))
    for i, slice in enumerate(slices):
        axes[i].imshow(slice.T, cmap=colormap, origin=origin_point)


# function: get pixel dimensions
def get_voxel_size(nii_file_name):
    ii = nib.load(nii_file_name)
    h = ii.header
    return h.get_zooms()

    

# function: find ED (end-diastole) nd ES (end-systole)
def find_ED_ES(seg_file_list):       
    lv_volume_list = []
    for s in seg_file_list:
        data = nib.load(s).get_fdata()
        count,_ = count_pixel(data,1)
        lv_volume_list.append(count)
    min_val = min(lv_volume_list)
    lv_volume_list = np.asarray(lv_volume_list)
    ED = 0
    ES = np.where(lv_volume_list == min_val)[0]
    return ED,ES                   


# function: find four model input time frames
def find_model_input_frames(seg_file_list):
    ED,ES = find_ED_ES(seg_file_list)
    gap = (float(ES) - float(ED)) / 3
    interval1 = round(ED + gap)
    current_pick = [ED, interval1,ES]
    interval2 = round(ED + gap * 2)
    if interval2 in current_pick:
        if interval2 == interval1:
            interval2 += 1
        else:
            interval2 -= 1
    return ED, ES, interval1, interval2


# function: count pixel in the image/segmentatio that belongs to one label
def count_pixel(seg,target_val):
    index_list = np.where(seg == target_val)
    count = index_list[0].shape[0]
    pixels = []
    for i in range(0,count):
        p = []
        for j in range(0,len(index_list)):
            p.append(index_list[j][i])
        pixels.append(p)
    return count,pixels

# function: DICE calculation
def DICE(seg1,seg2,target_val):
    p1_n,p1 = count_pixel(seg1,target_val)
    p2_n,p2 = count_pixel(seg2,target_val)
    p1_set = set([tuple(x) for x in p1])
    p2_set = set([tuple(x) for x in p2])
    I_set = np.array([x for x in p1_set & p2_set])
    I = I_set.shape[0] 
    DSC = (2 * I)/ (p1_n+p2_n)
    return DSC


# function: find time frame of a file
def find_timeframe(file,num_of_end_signal,start_signal = '/',end_signal = '.'):
    k = list(file)
    num_of_dots = num_of_end_signal

    if num_of_dots == 1: #.png
        num1 = [i for i, e in enumerate(k) if e == end_signal][-1]
    else:
        num1 = [i for i, e in enumerate(k) if e == end_signal][-2]
    num2 = [i for i,e in enumerate(k) if e== start_signal][-1]
    kk=k[num2+1:num1]
    total = 0
    for i in range(0,len(kk)):
        total += int(kk[i]) * (10 ** (len(kk) - 1 -i))
    return total

# function: sort files based on their time frames
def sort_timeframe(files,num_of_end_signal,start_signal = '/',end_signal = '.'):
    time=[]
    time_s=[]
    num_of_dots = num_of_end_signal

    for i in files:
        a = find_timeframe(i,num_of_dots,start_signal,end_signal)
        time.append(a)
        time_s.append(a)
    time_s.sort()
    new_files=[]
    for i in range(0,len(time_s)):
        j = time.index(time_s[i])
        new_files.append(files[j])
    new_files = np.asarray(new_files)
    return new_files


# function: set window level and width
def set_window(image,level,width):
    if len(image.shape) == 3:
        image = image.reshape(image.shape[0],image.shape[1])
    new = np.copy(image)
    high = level + width
    low = level - width
    # normalize
    unit = (1-0) / (width*2)
    for i in range(0,image.shape[0]):
        for j in range(0,image.shape[1]):
            if image[i,j] > high:
                image[i,j] = high
            if image[i,j] < low:
                image[i,j] = low
            norm = (image[i,j] - (low)) * unit
            new[i,j] = norm
    return new

# function: make movies of several .png files
def make_movies(save_path,pngs,fps):
    mpr_array=[]
    i = cv2.imread(pngs[0])
    h,w,l = i.shape
    
    for j in pngs:
        img = cv2.imread(j)
        mpr_array.append(img)

    # save movies
    out = cv2.VideoWriter(save_path,cv2.VideoWriter_fourcc(*'mp4v'),fps,(w,h))
    for j in range(len(mpr_array)):
        out.write(mpr_array[j])
    out.release()


# function: read DicomDataset to obtain parameter values (not image)
def read_DicomDataset(dataset,elements):
    result = []
    for i in elements:
        if i in dataset:
            result.append(dataset[i].value)
        else:
            result.append('')
    return result


    


    