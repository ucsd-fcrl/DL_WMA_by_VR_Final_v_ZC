function [convert_p] = Convert_From_Bounding_Box_To_Raw_Image(point_list,box)
% point_list has Nx3 dimensions if for 3D object and Nx2 for 2D.
% this function is used in convex hull. The convex hull object returns as a
% bounding box, and we need to put it back into original image.

convert_p = [];

if size(point_list,2) == 2 && size(box,2) == 4
    x_ul = ceil(box(2)); y_ul = ceil(box(1));
        new_x = point_list(:,1) + x_ul - 1;
        new_y = point_list(:,2) + y_ul - 1;
        convert_p = [new_x, new_y];
    
elseif size(point_list,2) == 3 && size(box,2) == 6
    x_ul = ceil(box(2)); y_ul = ceil(box(1));z_ul = ceil(box(3));
    
        new_x = point_list(:,1) + x_ul - 1;
        new_y = point_list(:,2) + y_ul - 1;
        new_z = point_list(:,3) + z_ul - 1;
        convert_p = [new_x, new_y,new_z];
   
else
    m = 'Error! wrong dimension of point list according to boundingbox';
    error(m);
end