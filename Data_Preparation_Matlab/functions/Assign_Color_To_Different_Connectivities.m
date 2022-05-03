function [new_I,numPixels] = Assign_Color_To_Different_Connectivities(I)
% this script can assign different colors to all connectivities in a
% logical image

CC = bwconncomp(I);
numPixels = cellfun(@numel,CC.PixelIdxList);
new_I = zeros(size(I));
value = 1;
for idx = 1:size(numPixels,2)
    new_I(CC.PixelIdxList{idx}) = value;
    value = value + 1;
end


