function [output] = Transform_nii_to_dcm_coordinate(nii,z_flip)

% transform nii image (directly loaded from nii file) to dcm image
% coordinate system

output = permute(nii,[2 1 3]);
output = flip(output,1);
output = flip(output,2);
if z_flip == 1
    % only equal to 0 when do the SQUEEZ (Gabby and Ashish's default
    % setting)
output = flip(output,3);
end