# LV Wall Motion Abnormality Detection By Deep learning and Dynamic Volume_Rendering

This repo is for the paper: <br />
"Detection of Left Ventricular Wall Motion Abnormalities from Volume Rendering of 4DCT Cardiac angiograms Using Deep Learning" <br />
Authors: Zhennong Chen, Francisco Contijoch, Elliot McVeigh<br />


## Description
The clinical problem we tackle is to screen 4DCT cases for LV wall motion abnormality (WMA) in a simple and automatic way. We hypothesize that the deep learning (DL) technique can be useful to fulfill this mission. 

4DCT data size is usually too large to fit into the current GPU. We solve this problem by leveraging the dynamic volume rendering technique. We convert 4DCT into 6 videos of volume-rendered left ventricle beating across one cardiac cycle. 6 videos have 6 different projection angles corresponding to every 60 degree rotation around the LV axis. Such volume rendering videos can accurately represent the high-resolution 4DCT data using highly-compressed data memory.

We then develope a deep learning framework with a pre-trained [Inception V3](https://www.tensorflow.org/api_docs/python/tf/keras/applications/inception_v3/InceptionV3) to extract image features from multiple frames of the volume rendering video, a **LSTM** to incorporate the temporal information and fully-connected layers to regress a binary classification of the WMA presence/absense in the volume rendering video.

**In conclusion**, this github repo enables the users to prepare 4DCT data into volume rendering videos and train the DL model to detect WMA from the videos.


## User Guideline
### Environment Setup
The entire code is [containerized](https://www.docker.com/resources/what-container). This makes setting up environment swift and easy. Make sure you have nvidia-docker and Docker CE [installed](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) on your machine before going further. <br />
- You can build your own docker from provided dockerfile ```Dockerfile_DL_WMA.txt```. 

### Volume Rendering Video Preparation
To start the experiment, you should have your 4DCT data with the LV blood-pool segmentation ready. We highly recommend you to prepare the segmenation automatically by U-Net. (you can use the github repo here: https://github.com/zhennongchen/2DUNet_CT_Seg_Final_v_ZC). <br />
The scripts in ```Data_Preparation_Matlab``` includes:
1. **Image rotation**: rotate CT volume so LV long axis correspond to image z-axis. This is done by ```find_rotation_angle.m``` (by clicking anatomical landmarks) and ``make_rotated_data.m``` (rotate the image and segmentation data with pre-defined rotaiton angles)
2. **Volume Rendering Generation**: Generate 6 volume rendering videos for 6 different view angles. This is done by ```Main_Volume_Rendering.m``` automatically with pre-defined rendering parameters.
3. **RSct Map**: The "ground-truth" WMA presence/absence of the video is labeled by quantitatively measuring regional shortening (RSct) of the endocardium using validated [surface feature tracking techniques](https://www.ahajournals.org/doi/full/10.1161/CIRCIMAGING.111.970061). Run ```Main_RSct.m``` to obtain the RSct map. Then project the RSct map onto each projection angle using the method introduced in paper supplemental material. *A video is labeled as abnormal if >35% voxels with projected RSct > -0.20.* You should record the labels into a spreadsheet.


### Deep Learning WMA Detection:
Use a deep learning framework to detect WMA from prepared volume rendering videos. Follow the steps indicated by file names to run the deep learning framework:

- step 0A: define default parameters by running ```./defaults.sh```.<br />
- step 0B: make the spreadsheet available for deep learning experiments by running ```DLWMA_pre1.py``` (organize the spreadsheet) and ```DLWMA_pre2.py``` (select input frames).<br />
- step 0C: partition the data if you need to do the n-fold cross-validation by running ```DLWMA_pre3.py```.<br />
- step 1: obtain frames of the video by running ```DLWMA_main_1_extract_video_frame_images.py```.<br />
- step 2: extract image features by running ```python DLWMA_main_2_extract_features.py```.<br />
- step 3: train the model (n-fold cross_validation) by running ```./DLWMA_main_3_train.py --batch N```.<br />
- step 4: predict WMA on new data by ```./DLWMA_main_4_predict.py```.<br />


### Additional guidelines
see comments in the script

Please contact zhc043@eng.ucsd.edu or chenzhennong@gmail.com for any further questions.