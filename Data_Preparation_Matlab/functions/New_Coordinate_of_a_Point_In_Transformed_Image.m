function [new_p] = New_Coordinate_of_a_Point_In_Transformed_Image(p,R,raw_image_size,new_image_size,point_not_vector)
% when we apply R (3x3 rotation matrix) to an image by imwarp, the image size will change and
% thus the coordiante system.
% This function can find the new position of a "point"/"vector" in the
% transformed coordinate system.
% point_not_vector = 1 for point, 0 for vector
% tips: be careful with R. if R is not automatically generated by matlab
% (but by rotation degree in three axis), we need to put transpose in the
% input (R')



center_raw = raw_image_size' / 2;
center_new= new_image_size'/2;

if point_not_vector == 1
    new_p = R * (p-center_raw)+center_new;
    %new_p = new_p';
else
    arbitary_p1 = center_raw + 2.5;
    arbitary_p2 = arbitary_p1 + p';
    new_p1 = R * (arbitary_p1-center_raw)+center_new;
    new_p2 = R * (arbitary_p2-center_raw)+center_new;
    new_p = (new_p2 - new_p1)';
end
    