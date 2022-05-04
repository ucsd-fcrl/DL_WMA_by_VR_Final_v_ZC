%% Description:
% this script automatically makes the volume rendering movie from 4DCT
% (with LV segmented). The volume rendering parameters are pre-set.

clear all;
code_path = '/Users/zhennongchen/Documents/GitHub/DL_WMA_by_VR_Final_v_ZC/Data_Preparation_Matlab/';
addpath(genpath('/Users/zhennongchen/Documents/GitHub/Volume_Rendering_by_DL/'));
main_path = '/Volumes/Seagate MacOS/';

%% Define patient list
patient_list = Find_all_folders('/Volumes/Seagate MacOS/Patient_list/Retouched_Seg_Done/Normal/');
class_list = []; id_list = [];
for i = 1:size(patient_list,1)
    class = split(patient_list(i).folder,'/');
    class = class(end); class = class{1};
    class_list = [class_list;convertCharsToStrings(class)];
    id_list = [id_list;convertCharsToStrings(patient_list(i).name)];
end

%% Main script
for num = 1:size(class_list,1)
    clear Image Image_LV Seg angle_list angle_increment I J image_files seg_files seg_raw WL WW
    patient_class = convertStringsToChars(class_list(num,:));
    patient_id = convertStringsToChars(id_list(num));
    
    save_folder = [main_path,'Volume_Rendering_Movies_MATLAB/',patient_class,'/',patient_id];
    mkdir(save_folder)
    
 
    % load rotated segmentation & image (made by make_rotated_data.m)
    seg_folder = [main_path,'mat_data/',patient_class,'/',patient_id,'/seg_rotate_box/'];
    seg_files = Sort_time_frame(Find_all_files(seg_folder),'_');
    img_folder = [main_path,'mat_data/',patient_class,'/',patient_id,'/image_rotate_box/'];
    img_files = Sort_time_frame(Find_all_files(img_folder),'_');
    
    
    for t = 1:size(seg_files,1)
        load([seg_folder,convertStringsToChars(seg_files(t))]);
        Seg(t).seg = seg;
        load([img_folder,convertStringsToChars(img_files(t))]);
        Image(t).img = image;
        clear seg image   
    end
    
    %=================================================
    % Remove some background by applying a bounding box
    bounding_box = 1;
    buff = [20,20,20,20,30,30];
    if bounding_box == 1
        [box] = Bounding_box_new(Seg(1).seg,'LV',buff);
        for tt = 1:size(Image,2)
            a = Image(tt).img; 
            Image(tt).img = a(box(1):box(2),box(3):box(4),box(5):box(6));
            b = Seg(tt).seg;
            Seg(tt).seg = b(box(1):box(2),box(3):box(4),box(5):box(6));
        end     
    end
    
    %=================================================
    % Set Window-Level(WL) and Window-Width(WW) for volume rendering
    if isfile([save_folder,'/thresholding.mat']) == 1
        load([save_folder,'/thresholding.mat'])
    else
        WL = Set_WindowLevel_Based_on_CenterIntensityProfile(Image(1).img,Seg(1).seg,15,100);
        WW = 150;
        save([save_folder,'/thresholding.mat'],'WW','WL');
    end
    
    %=================================================
    % apply segmentation mask to the image
    for t = 1:size(Image,2)
        % mask for LV only
         I = Image(t).img;
         min_val = min(I(:));
         I(Seg(t).seg ~= 1)= min_val; 
         Image_LV(t).img = I;
    end
    
    
    %=================================================
    % make 6 volume rendering movies (w/ 6 different projection angles according to every 60 degree angle rotation around LV axis)
    % of deforming Left Ventricle across one cardiac cycle
    
    % load pre-defined rendering parameters
    load([code_path,'configuration_list/config_image.mat']); 
    position = config_image.CameraPosition';
    movie_save_folder = [save_folder,'/Volume_Rendering_Movies'];
    mkdir(movie_save_folder);
    
    angle_list = [0:60:300]; % six projections angles
    scale = [1.5,1.5,1.5]; % scale up the image
    figure_size = [10 10 300 300];
    
    for i = 1:size(angle_list,2)
        angle = angle_list(:,i);

        save_name = [movie_save_folder,'/',patient_id,'_volume_rendering_movie_',num2str(angle)];
        
        writerObj = VideoWriter(save_name,'Motion JPEG AVI');
        writeObj.Quality = 100;
        writerObj.FrameRate = 5;
    
        % open the video writer
        open(writerObj);

        % write the frames to the video
        for t = 1:size(Image,2)
            close all;
            I = Image_LV(t).img;
            J = Turn_data_into_greyscale(I,WL,WW); % normalize the image by WL and WW
        
            config_image_new = config_image;
            [rot_in_xy,~] = Rotation_Matrix_From_Three_Axis(0,0,angle,1);
            new_position = rot_in_xy * position;
            config_image_new.CameraPosition = new_position';
        
            h = figure('pos',figure_size);
            volshow(J,config_image_new,'ScaleFactor',scale); 
            frame = getframe(h);
            writeVideo(writerObj, getframe(gcf));
            close all
        end
   
        close(writerObj);
        close all
        disp(['Done making AVI smovie for degree ',num2str(angle)])
    end
    
