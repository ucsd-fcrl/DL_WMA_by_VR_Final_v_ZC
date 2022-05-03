function [BW,image,change] = Find_largest_connected_component_3d(BW,image,assign_value,connectivities)

% assign value for disconnected object in the image: default = 0
% connectivities for 3d: https://www.mathworks.com/help/images/ref/bwconncomp.html
% default = 6 , 18 , 26

CC = bwconncomp(BW,connectivities);
numPixels = cellfun(@numel,CC.PixelIdxList);

if size(numPixels,2) > 1
    change = 1;
else
    change = 0;
end

if size(CC.PixelIdxList,2) ~= 0
    [biggest,idx] = max(numPixels);
    for i = 1:size(CC.PixelIdxList,2)
        if i ~= idx
            BW(CC.PixelIdxList{i}) = 0;
            image(CC.PixelIdxList{i}) = assign_value;
        end
    end
end
