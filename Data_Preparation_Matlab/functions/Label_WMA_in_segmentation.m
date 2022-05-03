function [seg_WMA,seg_WMA_multi] = Label_WMA_in_segmentation(seg_rot,Mesh,ed,es,threshold_RSct_severe,threshold_RSct_moderate,slice_show)
% this script assign a different pixel value to the binary segmentation of
% LV


% assign single class for WMA
rs_list = Mesh(es).RSct_vertex';
v_list = Mesh(ed).vertices;
low_strain_idx = find(rs_list >= threshold_RSct_moderate);
low_strain_p = v_list(low_strain_idx,:,:);

% pixel value assignment
seg_WMA = double(seg_rot == 1);

for i = 1: size(low_strain_p,1)
    p = low_strain_p(i,:);
    seg_WMA(p(2),p(1),p(3)) = 9; % background = 0, LV = 1, infarct = 9
end

if slice_show ~= 0
    figure()
    imagesc(seg_WMA(:,:,slice_show));
end

% assign two classes for wma
moderate_strain_idx = find(rs_list >= threshold_RSct_moderate & rs_list <= threshold_RSct_severe);
moderate_strain_p = v_list(moderate_strain_idx,:,:);

severe_strain_idx = find(rs_list > threshold_RSct_severe);
severe_strain_p = v_list(severe_strain_idx,:,:);
seg_WMA_multi = double(seg_rot == 1);
for i = 1: size(moderate_strain_p,1)
    p = moderate_strain_p(i,:);
    seg_WMA_multi(p(2),p(1),p(3)) = 9;  %moderate is 9
end
for i = 1: size(severe_strain_p,1)
    p = severe_strain_p(i,:); 
    seg_WMA_multi(p(2),p(1),p(3)) = 20; % severe is 20
end