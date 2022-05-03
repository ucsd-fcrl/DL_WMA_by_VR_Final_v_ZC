function [output] = Tranform_mat_to_dcm_coordinate(image,method)

% transform mat image (use python to save image data from nii file to mat file) to dcm image
% coordinate system

% method = 1 for non-toshiba, =2 for toshiba

if method == 1  % for cases that are not toshiba
    output = flip(image,3);
    output = permute(output,[2 1 3]);
    output = flip(output,1);
elseif method == 2
    output = permute(image,[2 1 3]);
else
    error('wrong method input');
end
   


