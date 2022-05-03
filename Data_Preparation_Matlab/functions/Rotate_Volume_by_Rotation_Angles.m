function [v] = Rotate_Volume_by_Rotation_Angles(volume,rot_angle,is_image,steps)

% this script rotates the volume by known rotation angles (three steps)
% Be careful that this script may not optimal for high resolution image due to memory issue
% is_image = 1 for image, = 0 for seg

if is_image == 1
    interp = 'linear';
    min_val = min(volume(:));
else
    interp = 'nearest';
    min_val = 0;
end


if steps >= 1
    [~,M_z] = Rotation_Matrix_From_Three_Axis(0,0,-rot_angle.first_z,0);
    tform_z = affine3d(M_z);
    v = imwarp(volume,tform_z,'FillValue',min_val,'interp',interp);
end

if steps >= 2
    [~,M_x] = Rotation_Matrix_From_Three_Axis(-rot_angle.second_x,0,0,0);
    tform_x = affine3d(M_x);
    v = imwarp(v,tform_x,'FillValue',min_val,'interp',interp);
end

if steps >= 3
    [~,M_y] = Rotation_Matrix_From_Three_Axis(0,0,rot_angle.third_z,0);
    tform_y = affine3d(M_y');
    v = imwarp(v,tform_y,'FillValue',min_val,'interp',interp);
end

