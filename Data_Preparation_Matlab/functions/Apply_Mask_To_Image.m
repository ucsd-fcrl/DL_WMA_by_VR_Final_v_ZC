function [new_image] = Apply_Mask_To_Image(image,seg,structure_num)

% structure_num is a list in which there are class number of the anatomical
% structures you want to keep in the final image.

min_val = min(image(:));
new_image = zeros(size(image))+min_val;

for j = 1:size(structure_num,2)
    structure = structure_num(:,j);
    [x,y,z] = ind2sub(size(seg),find(seg == structure));
    for i = 1 : size(x,1)
        new_image(x(i),y(i),z(i)) = image(x(i),y(i),z(i));
    end
end
    
    