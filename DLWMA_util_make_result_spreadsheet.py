from keras.callbacks import TensorBoard, ModelCheckpoint, CSVLogger
import pandas as pd
import os
import supplement
import numpy as np
import function_list_VR as ff
cg = supplement.Experiment() 

class Build_Spreadsheet():
    def __init__(self,test_data,prediction_list,batch_list, model, study_name):
        self.test_data = test_data
        self.prediction_list = prediction_list
        self.batch_list = batch_list
        self.model = model
        self.study_name = study_name


    def make_per_video_spreadsheet(self):
        final_result_list = []
        for t in range(0,len(self.test_data)):
            sample = self.test_data[t]
            case_result = [self.test_data[t]['video_name']]

            abnormal_predict_count = 0; normal_predict_count = 0
            for i in range(0,len(self.batch_list)):
                DL_prediction = self.prediction_list[i][t] 
                case_result += [DL_prediction]
                if DL_prediction == 1:
                    abnormal_predict_count += 1
                else:
                    normal_predict_count += 1
            # add majority vote       
            if abnormal_predict_count >= normal_predict_count:
                case_result += [1]
            else:
                case_result += [0]
            
            case_result += [sample['Patient_Class'],sample['Patient_ID'],sample['angle']]
            final_result_list.append(case_result)

        # write into excel sheet
        column_list = ['video_name'] + ['predict_model_'+str(b) for b in self.batch_list] + ['predict_majority','Patient_Class','Patient_ID','angle']
        df = pd.DataFrame(final_result_list,columns = column_list)
        save_folder = os.path.join(cg.save_dir,'results')
        df.to_excel(os.path.join(save_folder,self.model + '_' + self.study_name +'-testing.xlsx'),index=False)


    def make_per_study_spreadsheet(self,per_video_result_file):
        # based on per-video spreadsheet
        patient_list = np.unique(per_video_result_file['Patient_ID'])

        final_result_list = []
        for p in patient_list:
            data = per_video_result_file.loc[per_video_result_file['Patient_ID'] == p]
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
            final_result_list.append(patient_result)
        
        per_patient_result_df = pd.DataFrame(final_result_list,columns = ['Patient_Class', 'Patient_ID',
                'angle0_predict','angle60_predict','angle120_predict',
                'angle180_predict','angle240_predict','angle300_predict','abnormal_count_predict'])
        per_patient_result_df.to_excel(os.path.join(cg.save_dir,'results',self.model+ '_' + self.study_name +'-testing-per-study.xlsx'),index = False)

