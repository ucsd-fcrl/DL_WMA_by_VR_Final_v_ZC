function [WL] = Set_WindowLevel_Based_on_CenterIntensityProfile(image,seg,range,decrease)

% pick the middle slice
[lv_x,lv_y,lv_z] = ind2sub(size(seg),find(seg == 1));
z_range = [min(lv_z),max(lv_z)];
middle_slice = round(mean(z_range));
seg_slice = seg(:,:,middle_slice);
image_slice = image(:,:,middle_slice);

% find the center of mass
seg_slice_binary = seg_slice == 1;
[seg_slice_binary,~] = Find_Biggest_Component(seg_slice_binary,0);
CC = bwconncomp(seg_slice_binary);
centroid = round(regionprops(CC,'Centroid').Centroid);

% Find ROI around center of mass
%figure()
jj = seg_slice;
jj(centroid(2),centroid(1)) = 2; 
ROI = image([centroid(2)-range:centroid(2)+range],[centroid(1)-range:centroid(1)+range],[middle_slice-range:middle_slice+range]);
ROI = ROI(ROI>0);
WL = round(mean(ROI(:)));
jj([centroid(2)-range:centroid(2)+range],[centroid(1)-range:centroid(1)+range]) = 2;
imagesc(jj);

WL = WL - decrease;