function [R,M] = Find_Transformation_By_Images(image1,image2)
% the coordinate system in which we obtain MV plane axis (we save image data into mat file) 
% is not the same as the current system (we directly read the nii file)

% image1 = image saved in mat;
% image2 = nii_image;

edge1 = unique(image1);
counts1 = histc(image1(:),edge1);

n = 0; e_list =[ ];points = [];
for i = 1:size(counts1,1)
    if counts1(i,:) == 1
        e = edge1(i,:);e_list=[e_list;e];
        f = find(image1 == e);
        [x,y,z] = ind2sub(size(image1),f);
        points = [points;x y z];
        n = n + 1;
        if n == 50
        break
        end
    end
end

v1 = points(50,:) - points(1,:);

points2 = [];
for i = [1 50]
        e = e_list(i,:);
        f = find(image2 == e);
        if size(f,1) ~= 1
        error('not unique in image 2');
        end
        [x,y,z] = ind2sub(size(image2),f);
        points2 = [points2; x y z];
end
        
v2 = points2(2,:) - points2(1,:);

[r1,m1,~,~] = Find_Transform_Matrix_For_Two_Vectors(Normalize_Vector(v1),Normalize_Vector(v2));
R = m1;
M = [m1(1,1) m1(1,2) m1(1,3) 0 ;m1(2,1) m1(2,2) m1(2,3) 0;m1(3,1) m1(3,2) m1(3,3) 0;0 0 0 1];




    