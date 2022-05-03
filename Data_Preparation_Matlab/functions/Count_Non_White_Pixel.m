function [I_bw,count] = Count_Non_White_Pixel(I,image_show)
% this script can turn the image into a binary black and white image and
% count the number of black pixels

I_bw = im2bw(I);
if image_show == 1
    figure(1)
    imshow(I);
    figure(2)
    imshow(I_bw);
end
count = size(find(I_bw == 0),1);
