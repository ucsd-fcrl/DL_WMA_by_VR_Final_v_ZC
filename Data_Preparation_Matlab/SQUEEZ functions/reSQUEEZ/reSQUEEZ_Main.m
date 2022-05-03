%% Preparation: Data Organization
clear all; close all; clc;

%%% Segmentation files should be named as follows 'seg_xx' starting the count from '00'. They should be located under the "patient folder" in 'seg-nii' %%%
%%% Need one img-nii file in 'img-nii' folder (under "patient folder") labeled as 'img_xx', where 'xx' corresponds to info.template %%%

% addpath('/Users/ashish/Google_Drive/PhD/nii_reading')                               %NII Toolbox
% addpath(genpath('/Users/ashish/Google_Drive/PhD/Mesh_Fun/iso2mesh_mac'))            %Mesh Processsing toolbox
% addpath(genpath('/Users/ashish/Documents/PhD/aws_repo/squeez/tools/cpd2/'));        %CPD path

repo_path = '/Users/zhennongchen/Documents/GitHub/SQUEEZ/squeez-code/';
addpath(genpath(repo_path));

mesh_path = '/Users/zhennongchen/Documents/GitHub/SQUEEZ/reSQUEEZ/iso2mesh/';
addpath(genpath(mesh_path));

load_path = '/Users/zhennongchen/Documents/GitHub/SQUEEZ/reSQUEEZ/nii_image_load/';
addpath(genpath(load_path));

% MATLAB version
info.matlab = 0;    % 1 - if you have R2018b and later, else 0 (Not yet developed: DON'T USE!!!)

% Data set name
info.patient = 'toshiba_000';

% Paths
info.home_path = '/Users/zhennongchen/Documents/GitHub/SQUEEZ/reSQUEEZ/'; % Home folder containing function scripts
addpath(info.home_path)
info.save_path = ['/Users/zhennongchen/Documents/GitHub/SQUEEZ/',info.patient,'/Results/']; % Folder path to save results
mkdir(info.save_path)
info.save_image_path =['/Users/zhennongchen/Documents/GitHub/SQUEEZ/',info.patient,'/Results/plots/']; 
mkdir(info.save_image_path)
info.save_movie_path =['/Users/zhennongchen/Documents/GitHub/SQUEEZ/',info.patient,'/Results/movies/']; 
mkdir(info.save_movie_path)
info.seg_path = ['/Users/zhennongchen/Documents/Zhennong_CT_Data/AI_dataset/',info.patient,'/seg-nii-sm/']; %folder path containing the segmentations to read
info.img_path = ['/Users/zhennongchen/Documents/Zhennong_CT_Data/AI_dataset/',info.patient,'/img-nii-sm/']; %folder path containing the images to read for rotations

% Image preparation parmeters
info.iso_res = 0.5;                 %Standardized starting resolution in mm
info.desired_res = 2;               %Desired operating resolution in mm (multiples of 0.5)
info.averaging_threshold = 0.5;     %Threshold for voxels post averaging
info.fill_paps = 0;                 %Flag for filling in pap muscles using 3D convex hull: Need MATLAB 2017b or above

% Segmentation labels
info.lv_label = 1;
info.la_label = 2;
info.lvot_label = 4;

% Time frame list
info.timeframes = [1,7];           %Desired time frames for analysis
info.template = 1;                  %Used as template mesh for CPD warping
info.reference = 1 ;                 %Used as reference phase for strain calculations

% volume curve parameter list
%info.percent_rr = round(linspace(-3,93,14),0);                     %Enter %R-R values corresponding to time frame numbers
%info.percent_rr = [0:10:90];
info.percent_rr = [0,30];
%info.time_ms =linspace(0,740,10); %0043,101e in the metadata
info.time_ms = [0,75];


full_cycle = 0; % whether have full cardiac cycle
if full_cycle == 1
    info.smooth_verts = 1; %Flag for temporally smoothing CPD vertices using Fourier decomposition. Use only when there is one complete period (1 full periodic cycle)
else
    info.smooth_verts = 0;
end

info.resqueez = 0;                  %Flag for resqueez

if info.smooth_verts == 1 && length(info.timeframes) <= 5
    error('Please check temporal smoothing flag for periodicity of entered time frames')
% elseif info.smooth_verts == 0 && length(info.timeframes) >= 5
%     error('Temporal smoothing switched off')
end    
    

% Axes limits for plotting
%When plotting just use 'xlim([info.xlim]); ylim([info.ylim]); zlim([info.zlim])' for non-rotated LV
%When plotting just use 'xlim([info.rot_xlim]); ylim([info.rot_ylim]); %zlim([info.rot_zlim])' for rotated LV
%When plotting just use 'xlim([info.high_xlim]); ylim([info.high_ylim]); %zlim([info.high_zlim])' for Hi-Res rotated LV

disp('xxxxxxxxx - Analysis Parameters Saved - xxxxxxxxx')


%% Step 1:Image Processing and Mesh Extraction 

[Mesh,info] = Mesh_Extraction_PapFilling(info);

save([info.save_path,info.patient,'_step1_MeshExtraction.mat'],'Mesh','info')

disp('xxxxxxxxx - Meshes Extracted - xxxxxxxxx')

%% Step 1b: Volume Curves
close all;

EF = round(((info.vol(info.reference)-min(info.vol(info.timeframes)))/info.vol(info.reference))*100,1);
save([info.save_path,info.patient,'_EF.mat'],'EF')

figV = figure(1); plot(info.percent_rr,info.vol(info.timeframes),'LineWidth',4);
grid on; grid minor
title(['Ejection Fraction: ' num2str(EF),'%'])
set(gca,'FontSize',50)
axis([-10 110 0 200])
xlabel('R-R interval (%)'); ylabel('Volume (mL)')

figV.Units='normalized';
figV.Position=[0 0 0.8 1]; 
figV.PaperPositionMode='auto';

savefig([info.save_image_path,info.patient,'_VolvsRRper.fig'])
close all
figs = openfig([info.save_image_path,info.patient,'_VolvsRRper.fig']);
saveas(figs,[info.save_image_path,info.patient,'_VolvsRRper.jpg']);

%% Step 2: Registration - SQUEEZ

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
% Mesh(info.timeframes(j)).CPD always has the dimension as (N of vertices in template,3) 
% it shows that each vertex in Y (template) correspond to which vertex
% (expressed by coordinate) in X (time frame)
% Mesh(info.timeframes(j)).Correspondance shows the same thing but just
% express by indexes.

save([info.save_path,info.patient,'_step2_SQUEEZRegistration.mat'],'Mesh','info')

disp('xxxxxxxxx - Registration done - xxxxxxxxx')

clear opts

%% Step 2b: reSQUEEZ

if info.resqueez
    
    info.error_tol = 2/info.desired_res;        %Euclidean distance tolerance for reSQUEEZ in mm
    info.resqueez_beta = 1;                     %Beta value for CPD re-registration
    info.resqueez_lambda = 11;                  %Lambda value for CPD re-registration 
    info.area_tol = 100;                        %Minimum area of patches for re-registration in mm^2

    Mesh = reSQUEEZ(Mesh,info);
    
    save([info.save_path,info.patient,'_step2b_reSQUEEZ.mat'],'Mesh','info')
    
    disp('xxxxxxxxx - reSQUEEZ done - xxxxxxxxx')
else
    disp('xxxxxxxxx - NO reSQUEEZ - xxxxxxxxx')
end


%% Step 3: Calculating RSct

Mesh = RSCT(Mesh,info);
% Mesh.RSct saves the regional strain for each face in template
% Mesh.RSctvertices saves the RS for each vertex in template.

save([info.save_path,info.patient,'_step3_RSctCalculation.mat'],'Mesh','info')

disp('xxxxxxxxx - Strain calculations done - xxxxxxxxx')

%% Step 4: Mesh Rotation

[Mesh, info] = Rotation(Mesh,info);

save([info.save_path,info.patient,'_step4_MeshRotation.mat'],'Mesh','info')

disp('xxxxxxxxx - Meshes rotated - xxxxxxxxx')


%% Step 5: Polar Sampling of RSct
% Creating raw data set of "high resolution" sampling of RSct values as a function of theta and z

info.rawdata_slicethickness = 5/info.desired_res;           %Enter slice thickness for raw data sampling in mm. Has to be >2*info.desired_res
info.apical_basal_threshold = [0.1 0.1];                    %Apical and basal percentage tolerance in that order

if info.rawdata_slicethickness <= 2
    error('Slice thickness too small')
else
    [Mesh, info] = Data_Sampling(Mesh,info);
    
    save([info.save_path,info.patient,'_step5_PolarSamplingOfRSct.mat'],'Mesh','info')
    
    disp('xxxxxxxxx - Polar data sampled - xxxxxxxxx')
end


%% Step 6: AHA Plotting
% Hard coded 16 AHA segments

info.RSct_limits = [-0.5 0.1];
info.err_limits = [-0.1 10];

Mesh = AHA(Mesh,info);

save([info.save_path,info.patient,'_step6_AHA.mat'],'Mesh','info')

disp('xxxxxxxxx - AHA plots generated - xxxxxxxxx')

%% Step 7: Bullseye Plotting

info.polar_res = [36 10];                       %Enter desired number of points in bullseye plots in the format number [azimuthal radial]
info.polar_NoOfCols = 5;                        %Number of columns in bullseye plot subplot
info.RSct_limits = [-0.3 0.1];

Mesh = Bullseye_Plots(Mesh,info);

save([info.save_path,info.patient,'_step7_bullseye.mat'],'Mesh','info')

disp('xxxxxxxxx - Bullseye plots generated - xxxxxxxxx')

savefig([info.save_image_path,info.patient,'_Bullseye.fig'])
close all
figs = openfig([info.save_image_path,info.patient,'_Bullseye.fig']);
saveas(figs,[info.save_image_path,info.patient,'_Bullseye.jpg']);
%% Step 8: 4D SQUEEZ

[Mesh,info] = squeez_4D_movie(Mesh,info);

 save([info.save_path,info.patient,'_step8_4DSQUEEZ.mat'],'Mesh','info') 
 
%% High resolution meshes for 3D visual display

% [Mesh, info] = HiRes(Mesh,info);
% 
% disp('xxxxxxxxx - Hi-res Meshes Extracted - xxxxxxxxx')

% lims = [1.405311336948222e+02,3.834645172773082e+02,37.149991427191020,3.296969852916519e+02,-87.914932320198390,2.950851201563467e+02];
% 
% [Mesh,info] = squeez_4D_movie_hires(Mesh,info,lims);

%% Saving variables

% save([info.save_path,info.patient,'.mat'],'Mesh','info')
