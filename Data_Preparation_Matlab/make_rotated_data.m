%% Description
% this script will generate rotated (based on pre-defined rotation angles) + cropped (crop the background to minimize the image size) 
% image and segmentation data for each case.

clear all;
code_path = '/Users/zhennongchen/Documents/GitHub/DL_WMA_by_VR_Final_v_ZC/Data_Preparation_Matlab/';
addpath(genpath(code_path));
%% Define patient list
patient_list = Find_all_folders('/Volumes/Seagate MacOS/Patient_list/Retouched_Seg_Done/Normal/');
class_list = []; id_list = [];
for i = 1:size(patient_list,1)
    class = split(patient_list(i).folder,'/');
    class = class(end); class = class{1};
    class_list = [class_list;convertCharsToStrings(class)];
    id_list = [id_list;convertCharsToStrings(patient_list(i).name)];
end
main_path = '/Volumes/Seagate MacOS/';
load([code_path,'configuration_list/config_default.mat'])
%% Main Script
for num = 1:size(class_list,1)
    clear info Image1 Image image_rot_box Seg seg_rot_box box box_for_all
     
    info.patient_class = convertStringsToChars(class_list(num,:));
    info.patient = convertStringsToChars(id_list(num));
    disp(info.patient)
    
        
    % load ore-defined rotation angle:
    rot_angle_file = [main_path,'/SQUEEZ_results/',info.patient_class,'/',info.patient,'/rot_angle_2mm.mat'];
    load(rot_angle_file,'rot')
    
    % define save folders
    savefolder = [main_path,'mat_data/',info.patient_class,'/',info.patient];mkdir(savefolder);
    imagesavefolder = [savefolder,'/image_rotate_box'];mkdir(imagesavefolder);
    segsavefolder = [savefolder,'/seg_rotate_box'];mkdir(segsavefolder);
    
    % find file list
    image_folder = [main_path,'upsampled-nii-images/',info.patient_class,'/',info.patient,'/img-nii-0.625'];
    image_file_list = Sort_time_frame(Find_all_files(image_folder),'no');
    seg_folder = [main_path,'predicted_seg/',info.patient_class,'/',info.patient,'/seg-pred-0.625-4classes-connected-retouch'];
    seg_file_list = Sort_time_frame(Find_all_files(seg_folder),'_');
    
    for t = 1: size(image_file_list,1)
        disp(['time frame ',num2str(t)])
        % load image
        image_path = [image_folder,'/',convertStringsToChars(image_file_list(t))];
        image_data = load_nii(image_path);
        image = Transform_nii_to_dcm_coordinate(double(image_data.img),0);
        
        % load LV segmentation
        seg_path = [seg_folder,'/',convertStringsToChars(seg_file_list(t))];
        seg_data = load_nii(seg_path);
        seg = Transform_nii_to_dcm_coordinate(double(seg_data.img),0);
          
        % crop in case image too large
        if size(image,1) > 500 || size(image,2) > 500
            image = image(100:size(image,1)-100,140:size(image,2)-40,:);
            seg = seg(100:size(seg,1)-100,140:size(seg,2)-40,:);    
        
        elseif (size(image,1) >= 450 && size(image,1) <= 500) || (size(image,2) >= 450 && size(image,2) <= 500)
            image = image(80:size(image,1)-50,100:size(image,2)-40,:);
            seg = seg(80:size(seg,1)-50,100:size(seg,2)-40,:);
        end
        
        if size(image,3)>300
            image = image(:,:,20:size(image,3)-20);
            seg = seg(:,:,20:size(seg,3)-20);
        end
    
        % rotate
        tic
        [image_rot] = Rotate_Volume_by_Rotation_Angles(image,rot,1,3);
        [seg_rot] = Rotate_Volume_by_Rotation_Angles(seg,rot,0,3);
        toc

        
        buff = [70,70,70,70,70,70];
        [box] = Bounding_box_new(seg_rot,'ALL',buff);
        image_rot_box = image_rot(box(1):box(2),box(3):box(4),box(5):box(6));
        Image1(t).image = image_rot_box;
        Image(t).box = box;
        seg_rot_box = seg_rot(box(1):box(2),box(3):box(4),box(5):box(6));
        Seg(t).seg_raw = seg_rot_box;
        Seg(t).box = box;
    end

    
    % apply bounding box uniform to all time frames
    box_list = [];
    for t = 1:size(image_file_list,1)
        box_list = [box_list; Image(t).box];
    end
    box_for_all = [max(box_list(:,1)),  min(box_list(:,2)), max(box_list(:,3)), min(box_list(:,4)), max(box_list(:,5)), min(box_list(:,6))]; 
    disp(box_for_all)
    
    for t = 1 : size(image_file_list,1)
        II = Image1(t).image;
        box_t = Image(t).box;
        Image(t).box_for_all = box_for_all;
        Image(t).image = II(1+box_for_all(1)-box_t(1):size(II,1)-(box_t(2)-box_for_all(2)),1+box_for_all(3)-box_t(3):size(II,2)-(box_t(4)-box_for_all(4)),1+box_for_all(5)-box_t(5):size(II,3)-(box_t(6)-box_for_all(6)));
        
        SS = Seg(t).seg_raw;
        box_t = Seg(t).box;
        Seg(t).box_for_all = box_for_all;
        Seg(t).seg = SS(1+box_for_all(1)-box_t(1):size(II,1)-(box_t(2)-box_for_all(2)),1+box_for_all(3)-box_t(3):size(II,2)-(box_t(4)-box_for_all(4)),1+box_for_all(5)-box_t(5):size(II,3)-(box_t(6)-box_for_all(6)));
        clear  II SS
    end
    
    % save
    for t = 1 : size(image_file_list,1)
        clear image box seg_raw seg
        image = Image(t).image;
        box = Image(t).box;
        save([imagesavefolder,'/img_',num2str(t-1),'.mat'],'image','box','box_for_all','-v7.3');
        
        seg_raw = Seg(t).seg_raw;
        seg = Seg(t).seg;
        save([segsavefolder,'/pred_s_',num2str(t-1),'.mat'],'seg_raw','seg','box','box_for_all','-v7.3');
    end
    
end
