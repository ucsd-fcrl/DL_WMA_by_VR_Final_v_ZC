#!/usr/bin/env python


# this script will predict a binary classification of WMA presence/absence for a new volume rendering video. 
# Input of the model should be the pre-extracted image feature sequence.
# Output of this script is a spreadsheet that shows per-video/per-study classification results.

# To run this script, type: ./DLWMA_main_4_predict.py

from keras.callbacks import TensorBoard, ModelCheckpoint, CSVLogger
from DLWMA_util_models import ResearchModels
from DLWMA_util_data import DataSet
import argparse
import pandas as pd
import os
import supplement
import numpy as np
import function_list_VR as ff
cg = supplement.Experiment() 


def test(data_type, data_file, batch_list, model, study_name, seq_length, saved_model=None,
             class_limit=None, image_shape=None, per_patient_analysis = True):
    
    final_result_list = []
    data = DataSet(
                data_file = data_file,
                validation_batch = None,
                seq_length=seq_length,
                architecture = 'InceptionV3',
                class_limit=class_limit
            )
            
    regression = 0
    sequence_len = seq_length

    test_data = data.data

    # get prediction by each model
    prediction_list = []
    for i in range(0,len(batch_list)):
        rm = ResearchModels(len(data.classes), model, sequence_len, 1e-5 ,1e-6,2048, saved_model[i])
        prediction_list_current_batch = []
        for sample in test_data:
            movie_id = sample['video_name']
            # get generator
            p_generator = data.predict_generator(sample, data_type,regression)

            # predict
            predict_output = rm.model.predict_generator(generator=p_generator,steps = 1)
            if np.argmax(predict_output[0]) == 0: # abnormal = [1,0], normal = [0,1]
                prediction_list_current_batch += [1] # abnormal
            else:
                prediction_list_current_batch += [0] # normal
        
        prediction_list.append(prediction_list_current_batch)

    # organize the predictions into a spreadsheet
    for t in range(0,len(test_data)):
        sample = test_data[t]

        case_result = [sample['video_name']]

        #  find the majority
        abnormal_predict_count = 0; normal_predict_count = 0
        for i in range(0,len(batch_list)):
            p = prediction_list[i][t]
            case_result += [p]
            if p == 1:
                abnormal_predict_count += 1
            else:
                normal_predict_count += 1
                
        if abnormal_predict_count >= normal_predict_count:
            case_result += [1]
        else:
            case_result += [0]
            
        case_result += [sample['Patient_Class'],sample['Patient_ID'],sample['angle']]
        final_result_list.append(case_result)
       

    # write into excel sheet
    column_list = ['video_name'] + ['predict_model_'+str(b) for b in batch_list] + ['predict_majority','Patient_Class','Patient_ID','angle']
    df = pd.DataFrame(final_result_list,columns = column_list)
    save_folder = os.path.join(cg.save_dir,'results')
    df.to_excel(os.path.join(save_folder,model + '_' + study_name +'-testing.xlsx'),index=False)

    # organize the per-video results into per-study analysis
    if per_patient_analysis == True:
        testing_file= pd.read_excel(os.path.join(cg.save_dir,'results', model+ '_' + study_name + '-testing.xlsx'))
        # find the patient_list by np.unique
        patient_list = np.unique(testing_file['Patient_ID'])

        per_patient_result_list = []
        for p in patient_list:
            data = testing_file.loc[testing_file['Patient_ID'] == p]
            assert data.shape[0] == 6

            patient_result = [data.iloc[0]['Patient_Class'], data.iloc[0]['Patient_ID']]
            abnormal_count_predict = 0
            for angle in [0,60,120,180,240,300]:
                angle_data = data.loc[data['angle'] == angle]
                
                predict = angle_data.iloc[0]['predict_majority']
                patient_result += [predict]
                if predict == 1:
                    abnormal_count_predict += 1
                
            patient_result += [abnormal_count_predict]
            per_patient_result_list.append(patient_result)
        
        per_patient_result_df = pd.DataFrame(per_patient_result_list,columns = ['Patient_Class', 'Patient_ID',
                'angle0_predict','angle60_predict','angle120_predict',
                'angle180_predict','angle240_predict','angle300_predict','abnormal_count_predict'])
        per_patient_result_df.to_excel(os.path.join(cg.save_dir,'results',model+ '_' + study_name +'-testing-per-study.xlsx'),index = False)

         
    
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