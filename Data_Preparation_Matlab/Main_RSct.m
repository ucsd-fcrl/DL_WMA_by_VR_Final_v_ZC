%% Description:
% This script calculates the RSct values of each image voxel in each 4DCT
% study using a surface feature tracking technique called SQUEEZ
% (https://www.ahajournals.org/doi/full/10.1161/CIRCIMAGING.111.970061)

clear all; close all; clc;
main_path ='/Volumes/Seagate MacOS';
code_path = '/Users/zhennongchen/Documents/GitHub/DL_WMA_by_VR_Final_v_ZC/Data_Preparation_Matlab/';
addpath(genpath(code_path));
%% Deine your patient list 
patient_list = Find_all_folders('/Volumes/Seagate MacOS/Patient_list/Retouched_Seg_Done/Normal/');
class_list = []; id_list = [];
for i = 1:size(patient_list,1)
    class = split(patient_list(i).folder,'/');
    class = class(end); class = class{1};
    class_list = [class_list;convertCharsToStrings(class)];
    id_list = [id_list;convertCharsToStrings(patient_list(i).name)];
end
%% Main Script
for num = 1:size(id_list,1)
    clear info Data Mesh
    
    info.patient_class = convertStringsToChars(class_list(num,:));
    info.patient = convertStringsToChars(id_list(num));
    disp(info.patient)
    
    % Define save paths
    info.save_path = [main_path,'/SQUEEZ_results/',info.patient_class,'/',info.patient,'/'];
    mkdir(info.save_path)
    info.save_num_path = [info.save_path,'results/'];mkdir(info.save_num_path);
    info.save_image_path =[info.save_path,'plots/']; mkdir(info.save_image_path);
    info.save_movie_path =[info.save_path,'movies/']; mkdir(info.save_movie_path);
    
    % load pre-defined rotation matrix (to rotate the LV so LV long axis is
    % the z-axis of the image)
    load([main_path,'/SQUEEZ_results/',info.patient_class,'/',info.patient,'/rot_angle_2mm.mat'],'rot')

    % load the prepared segmentation of LV
    seg_folder = [main_path,'/predicted_seg/',info.patient_class,'/',info.patient,'/seg-pred-0.625-4classes-connected-retouch-downsample'];
    seg_files = Sort_time_frame(Find_all_files(seg_folder),'_');
    for i = 1:size(seg_files,1)
        seg_data = load_nii([seg_folder,'/',convertStringsToChars(seg_files(i))]);
        Data(i).image_hdr = seg_data.hdr;
        seg = Transform_nii_to_dcm_coordinate(double(seg_data.img),0);
        [Data(i).seg_rot] = Rotate_Volume_by_Rotation_Angles(seg,rot,0,3);
    end
    
    
    %%%%%%%%%% Define parameters%%%%%%%%%%%%%%
    info.matlab = 0;   

    % whether the Data already has rotated image and seg
    info.already_rotated = 1;           % the Data already have rotated image and seg in the pre-processing step

    % Image preparation parmeters
    info.pixel_size = Data(1).image_hdr.dime.pixdim(2:4);
    info.iso_res = info.pixel_size(1);
    info.desired_res = 2;   % Desired pixel resolution
    
    info.averaging_threshold = 0.5;     %Threshold for voxels post averaging
    info.fill_paps = 0;                 %Flag for filling in pap muscles using 3D convex hull

    % Segmentation labels
    info.lv_label = 1;
    info.la_label = 2;
    info.lvot_label = 4;

    % Time frame list
    info.timeframes = linspace(1,size(Data,2),size(Data,2));           %Desired time frames for analysis
    info.template = 1;                  %Used as template mesh for CPD warping
    info.reference = 1 ;                 %Used as reference phase for RSct calculation

    % volume curve parameter list
    info.percent_rr = round(linspace(0,100,size(Data,2)));
    info.time_ms = round(linspace(0,740,size(Data,2))); 

    full_cycle = 1; % whether have full cardiac cycle
    if full_cycle == 1
        info.smooth_verts = 1; %Flag for temporally smoothing CPD vertices using Fourier decomposition. Use only when there is one complete period (1 full periodic cycle)
    else
        info.smooth_verts = 0;
    end

    disp('xxxxxxxxx - Analysis Parameters Saved - xxxxxxxxx')


    %%%%%%%%%% Step 1:Image Processing and Mesh Extraction %%%%%%%%%%

    [Mesh,info] = Mesh_Extraction_modified(info,Data);
    disp('xxxxxxxxx - Meshes Extracted - xxxxxxxxx')

    %%%%%%%%%% Step 2: Registration - by SQUEEZ %%%%%%%%%%

    % CPD Parameters
    opts.corresp = 1;
    opts.normalize = 1;
    opts.max_it = 1500;
    opts.tol = 1e-5;
    opts.viz = 0;
    opts.method = 'nonrigid_lowrank';
    opts.fgt = 0;
    opts.eigfgt = 0;
    opts.numeig = 100;
    opts.outliers = 0.05;
    opts.beta = 2;
    opts.lambda = 3;

    Mesh = Registration(Mesh,info,opts);

    disp('xxxxxxxxx - Registration done - xxxxxxxxx')
    clear opts
    close all

   %%%%%%%%%% Step 3: Calculating RSct %%%%%%%%%%

    Mesh = RSCT(Mesh,info);
    disp('xxxxxxxxx - Strain calculations done - xxxxxxxxx')
    
   %%%%%%%%%% Step 4: Save  %%%%%%%%%%%%%
   save([info.save_num_path,'SQUEEZ_data.mat'],'Mesh','info') 
