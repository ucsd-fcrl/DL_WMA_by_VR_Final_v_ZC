function [Image_WMA_remove_dilate,Image_colored,WMA_patches_sizes] = Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed(Image_WMA_bw,Image_LV_bw,rows_of_Mitral_Valve,dilate_size,image_show)
% make sure Image_WMA_bw,Image_LV_bw are binary image with object =
% 1(white)
% remove the Mitral valve in the calculation

Image_WMA_remove = Image_WMA_bw;
count = 0; top_lines = [];
for i = 1: size(Image_LV_bw,1)
    row = Image_LV_bw(i,:);
    if size(find(row == 1),2) > 0
        top_lines = [top_lines,i];
        Image_WMA_remove(i,:) = zeros(size(Image_WMA_remove(i,:)));
        count = count + 1;
        if count == rows_of_Mitral_Valve
            break
        end
    end
end

Image_WMA_remove_dilate = imdilate(Image_WMA_remove,ones(dilate_size,dilate_size));
[Image_colored,WMA_patches_sizes] = Assign_Color_To_Different_Connectivities(Image_WMA_remove_dilate);

final_I = Image_WMA_remove_dilate;

lim = size(final_I,2);
if image_show == 1
    subplot(1,3,1)
    imagesc(Image_WMA_bw);
    xlim([0 lim]);ylim([0,lim]);
    axis equal
    
    subplot(1,3,2)
    imagesc(Image_WMA_remove);
    xlim([0 lim]);ylim([0,lim]);
    axis equal
    
    subplot(1,3,3)
    imagesc(Image_colored);
    xlim([0 lim]);ylim([0,lim]);
    axis equal
end