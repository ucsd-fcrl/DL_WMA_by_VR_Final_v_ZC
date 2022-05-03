function [p_list] = List_All_Points_In_Image(image_size)

p_list = [];
if size(image_size,2) == 2
    for i = 1:image_size(1)
        for j = 1:image_size(2)
            p_list = [p_list; i j];
        end
    end
elseif size(image_size,2) == 3
    for i = 1:image_size(1)
        for j = 1:image_size(2)
            for k = 1:image_size(3)
            p_list = [p_list; i j k];
        end
        end
    end
end
            