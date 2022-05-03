function [output] = Transform_between_nii_and_mat_coordinate(image,method)

% transform  mat image (use python to save image data from nii file to mat file) to nii image
% coordinate system or inversly

% method = 1 for non-toshiba, =2 for toshiba

if method == 1
    output = flip(image,1);
else
    output = flip(image,1);
    output = flip(output,2);
    output = flip(output,1);
end

