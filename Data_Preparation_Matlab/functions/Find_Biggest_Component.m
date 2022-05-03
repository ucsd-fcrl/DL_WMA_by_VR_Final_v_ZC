function [new_I,numPixels] = Find_Biggest_Component(I,inverse)
% I must be logical.
% if inverse = 1, it means the object in the image  = 0 and background = 1

if inverse == 1
    I_inverse = ~I;
else
    I_inverse = I;
end

CC = bwconncomp(I_inverse);
numPixels = cellfun(@numel,CC.PixelIdxList);
if size(numPixels,2) == 1
    new_I = I;
else
    [~,idx]= max(numPixels);
    
    if inverse == 1
        new_I = ones(size(I));
        new_I(CC.PixelIdxList{idx}) = 0;
    else
        new_I = zeros(size(I));
        new_I(CC.PixelIdxList{idx}) = 1;
    end
end

new_I = logical(new_I);