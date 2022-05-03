#!/usr/bin/env python

# this script extracts time frames of a video into jpg images

import csv
import cv2
import os
import pandas as pd
import math
from subprocess import call
import supplement
import function_list_VR as ff
cg = supplement.Experiment() 

def extract_timeframes(main_path,movie_path,excel_file):
    """After we have all of our videos split between train and test, and
    all nested within folders representing their classes, we need to
    make a data file that we can reference when training our RNN(s).
    This will let us keep track of image sequences and other parts
    of the training process.

    We'll first need to extract images from each of the videos. We'll
    need to record the following data in the file:

    [train|test] or batch, class, filename, nb frames

    Extracting can be done with ffmpeg:
    `ffmpeg -i video.mpg image-%04d.jpg`
    """

    # create image folder
    image_folder = os.path.join(main_path,'images')
    ff.make_folder([image_folder])

    # find all the movies
    excel_file = pd.read_excel(excel_file)

    # extract time frames from each movie:
    for i in range(0,excel_file.shape[0]):
        case = excel_file.iloc[i]
        print(i, case['video_name'])

        # set the file name for images
        save_folder = os.path.join(image_folder,case['Patient_Class'],case['Patient_ID'], case['video_name_no_ext'])
        ff.make_folder([os.path.dirname(os.path.dirname(save_folder)), os.path.dirname(save_folder), save_folder])

        src = os.path.join(movie_path,case['Patient_Class'],case['Patient_ID'], 'Volume_Rendering_Movies',case['video_name'])
        if os.path.isfile(src) == 0:
            ValueError('no movie file')

        if os.path.isfile(os.path.join(save_folder,case['video_name_no_ext']+'-0001.jpg')) == 0:
            cap = cv2.VideoCapture(src)
            count = 1
            frameRate = 1
            while(cap.isOpened()):
                frameId = cap.get(1) # current frame number
                ret, frame = cap.read()
                            
                if (ret != True):
                    break
                if (frameId % math.floor(frameRate) == 0):
                    if count < 10:
                        number = '000'+str(count)
                    if count >=10:
                        number = '00'+str(count)

                dest = os.path.join(save_folder,case['video_name_no_ext']+'-'+number+'.jpg')
                cv2.imwrite(dest,frame)
                count += 1
            cap.release()
            

def main():
    
    main_path = cg.local_dir
    movie_path = os.path.join(main_path,'original_movie')
    excel_file = os.path.join(cg.fc_main_dir,'Patient_List/movie_list_w_walls_w_picked_timeframes_test.xlsx')
    extract_timeframes(main_path,movie_path,excel_file)

if __name__ == '__main__':
    main()
