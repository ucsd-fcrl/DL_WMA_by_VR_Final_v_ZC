%% Description:
% this script finds the rotation angles that requires to orient the CT
% volume. so that LV long axis corresponds to z-axis of the image and LV
% anterior wall is at 12 o'clock.
% it will save angles as a mat file 
%% add functino path
clear all;
code_path = '/Users/zhennongchen/Documents/GitHub/DL_WMA_by_VR_Final_v_ZC/Data_Preparation_Matlab/';
addpath(genpath(code_path));
%% 
patient_list = Find_all_folders('/Volumes/Seagate MacOS/Patient_list/Retouched_Seg_Done/Normal/');
class_list = []; id_list = [];
for i = 1:size(patient_list,1)
    class = split(patient_list(i).folder,'/');
    class = class(end); class = class{1};
    class_list = [class_list;convertCharsToStrings(class)];
    id_list = [id_list;convertCharsToStrings(patient_list(i).name)];
end
main_path = '/Volumes/Seagate MacOS/';

%% Define patient and load data
for num = 1:size(id_list,1)
    patient_class = convertStringsToChars(class_list(num,:));
    patient_id = convertStringsToChars(id_list(num));
    disp(patient_id)
    save_file = [main_path,'/SQUEEZ_results/',patient_class,'/',patient_id,'/rot_angle_2mm.mat'];

    % image:
    image_path = [main_path1,'/downsample-nii-images-2mm/',patient_class,'/',patient_id,'/img-nii-2/0.nii.gz'];
  
    image_data = load_nii(image_path);
    image = Transform_nii_to_dcm_coordinate(double(image_data.img),0);
    
    % seg:
    seg_path = [main_path,'/predicted_seg/',patient_class,'/',patient_id,'/seg-pred-0.625-4classes-connected-retouch-downsample/pred_s_0.nii.gz'];
     if isfile(seg_path) == 0
        error('no seg, end the process');
    end
    seg_data = load_nii(seg_path);
    seg = Transform_nii_to_dcm_coordinate(double(seg_data.img),0);
    
    %
    [rot,Irot,segrot] = Obtain_Rotation_Angle_By_Clicking_Anatomical_Landmarks(image,seg);
    %
    
    [save_folder,~,~] = fileparts(save_file);
    mkdir(save_folder)
    save(save_file,'rot')
end