%% Run this script to obtain ITK threshold used for LV segmentation %%

clear all; close all; clc;
addpath('/Users/zhennongchen/Documents/GitHub/Volume_Rendering_by_DL/matlab/functions');
addpath('/Users/zhennongchen/Documents/GitHub/Volume_Rendering_by_DL/matlab/nii_image_load');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% CHANGE TO PATH WHERE MID-AXIAL SLICE IS LOCATED %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Folder where image is stored %
main_PATH = '/Users/zhennongchen/Documents/Zhennong_CT_Data/AUH';
patient = '/62/62pre/img-nii';
% Name of mid axial slice - must be a dicom file %
%DCMname = 'IM-0599-0387.dcm';
%info = dicominfo([PATH,'/',DCMname]);

nii_file = [main_PATH,patient,'/0.nii.gz'];
data = load_nii(nii_file);
image = Transform_nii_image(data.img);
IM = double(image(:,:,round(size(image,3)/2)));
[x,y]=size(IM);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%slope = info.RescaleSlope;
%int = info.RescaleIntercept;

%IM = squeeze((dicomread(info)*slope)+int);
%[x,y,z] = size(IM);
%%
%%%%%%%%%%%% Draw boundary around Myocardium + LV blood pool %%%%%%%%%%%%

figure;
imagesc(IM); axis equal; colormap(gray)
title('Draw Boundary Around Myocardium & LV Blood pool')

h=drawpolyline;
bw = poly2mask(h.Position(:,1),h.Position(:,2),x,y);


MASK = bw.*double(IM);
imagesc(MASK);

THRESH = multithresh(MASK,1);

figure;

x = zeros(size(IM));
idx = MASK >= THRESH;
x(idx) = 1;

imagesc(x)

THRESH = round(THRESH,-1);

%%%%%%%%%%%% DISPLAY THRESHOLD VALUE TO USER %%%%%%%%%%%%

disp('Your threshold is:')
disp(THRESH)


