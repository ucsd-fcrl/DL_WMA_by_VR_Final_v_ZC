#!/usr/bin/env python


# this script will predict a binary classification of WMA presence/absence for a new volume rendering video. 
# Input of the model should be the pre-extracted image feature sequence.
# Output of this script is a spreadsheet that shows per-video/per-study classification results.

# To run this script, type: ./DLWMA_main_4_predict.py

from DLWMA_util_make_result_spreadsheet import Build_Spreadsheet
from keras.callbacks import TensorBoard, ModelCheckpoint, CSVLogger
from DLWMA_util_models import ResearchModels
from DLWMA_util_data import DataSet
from DLWMA_util_make_result_spreadsheet import *
import argparse
import pandas as pd
import os
import supplement
import numpy as np
import function_list_VR as ff
cg = supplement.Experiment() 


def test(data_type, data_file, batch_list, model, study_name, seq_length, saved_model=None,
             class_limit=None, image_shape=None, per_patient_analysis = True):
    
    data = DataSet(
                data_file = data_file,
                validation_batch = None,
                seq_length=seq_length,
                architecture = 'InceptionV3',
                class_limit=class_limit
            )

    test_data = data.data

    # get prediction by each model
    prediction_list = []
    for i in range(0,len(batch_list)):
        rm = ResearchModels(len(data.classes), model, seq_length, 1e-5 ,1e-6,2048, saved_model[i])
        prediction_list_current_batch = []
        for sample in test_data:
            movie_id = sample['video_name']
            # get generator
            p_generator = data.predict_generator(sample, data_type,0)

            # predict
            predict_output = rm.model.predict_generator(generator=p_generator,steps = 1)
            if np.argmax(predict_output[0]) == 0: # abnormal = [1,0], normal = [0,1]
                prediction_list_current_batch += [1] # abnormal
            else:
                prediction_list_current_batch += [0] # normal
        
        prediction_list.append(prediction_list_current_batch)

    # organize the predictions into a spreadsheet
    build_sheet = Build_Spreadsheet(test_data,prediction_list,batch_list, model, study_name)
    # make per-video result spreadsheet:
    build_sheet.make_per_video_spreadsheet()
    # make per-study result spreadsheet based on per-video result sheet:
    if per_patient_analysis == True:
        per_video_file= pd.read_excel(os.path.join(cg.save_dir,'results', model+ '_' + study_name + '-testing.xlsx'))
        build_sheet.make_per_study_spreadsheet(per_video_file)

         
def main():
    data_file = os.path.join(cg.save_dir,'Patient_List/movie_list_w_classes_w_picked_timeframes_test.xlsx')

    # define study name
    study_name = 'trial_1'
    
    # define model architectures
    model = 'lstm'

    # define trained models
    # since we did 5-fold cross-validation, we have 5 models. We apply all 5 and take the majority vote.
    batch_list = [0,1,2,3,4]
    epoch_list = ['001','001','001','001','001'] # pick your epochs with highest validation accuracy
    saved_model = []
    for i in range(0,len(batch_list)):
        batch = batch_list[i]
        epoch = epoch_list[batch]
        saved_model.append(os.path.join(cg.save_dir,'models', model + '_'+study_name, 'batch_'+str(batch), model+'-batch'+str(batch)+'-'+epoch+'.hdf5'))
      
    seq_len = 4
    data_type = 'features'
    image_shape = None

    test(data_type, data_file,batch_list, model, study_name, seq_length = seq_len,saved_model=saved_model,
             image_shape=image_shape, class_limit=None, per_patient_analysis =True)

if __name__ == '__main__':
  main()