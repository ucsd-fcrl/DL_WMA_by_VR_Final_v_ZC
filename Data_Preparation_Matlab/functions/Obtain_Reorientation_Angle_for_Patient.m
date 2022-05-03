function [rot_angle] = Obtain_Reorientation_Angle_for_Patient(image,seg,rotinfo_known,previous_rot)

seg_binary = zeros(size(seg));
seg_binary(seg == 1) = 1;
% rotate the image
[rot_angle] = Rotate_LV_Correct_Orientation(image,seg_binary,rotinfo_known,previous_rot);



