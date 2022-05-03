function [box] = Bounding_box(I,buff)

% z direction
i = 1;
min_val = min(I(:)); min_z = -10; max_z = -10;
while 1 == 1
    slice = I(:,:,i);
    if min_z<0 && (size(find(slice <=0),1)  ~= size(slice,1) * size(slice,2))
        min_z = i;
    end
    if min_z>=0 && max_z<0 && (size(find(slice <=0),1)  == size(slice,1) * size(slice,2))
        max_z = i;
        break
    end
    if i == size(I,3)
        if max_z <0
            max_z = size(I,3);
        end
        break
    end
    i = i + 1;
end

if min_z - buff <= 0
    min_z = 0;
else
    min_z = min_z - buff;
end
if max_z + buff >= size(I,3)
    max_z = size(I,3);
else
    max_z = max_z + buff;
end
% x direction
i = 1;
min_x = -10; max_x = -10;
while 1 == 1
    slice = permute(I(i,:,:),[2 3 1]);
    if min_x<0 && (size(find(slice <=0),1)  ~= size(slice,1) * size(slice,2))
        min_x = i;
    end
    if min_x>=0 && max_x<0 && (size(find(slice <=0),1)  == size(slice,1) * size(slice,2))
        max_x = i;
        break
    end
    if i == size(I,1)
        if max_x <0
            max_x = size(I,3);
        end
        break
    end
    i = i + 1;
end

if min_x - buff <= 0
    min_x = 0;
else
    min_x = min_x - buff;
end
if max_x + buff >= size(I,1)
    max_x = size(I,1);
else
    max_x = max_x + buff;
end
% y direction    
i = 1;
min_y = -10; max_y = -10;
while 1 == 1
    slice = permute(I(:,i,:),[1 3 2]);
    if min_y<0 && (size(find(slice <=0),1)  ~= size(slice,1) * size(slice,2))
        min_y = i;
    end
    if min_y>=0 && max_y<0 && (size(find(slice <=0),1)  == size(slice,1) * size(slice,2))
        max_y = i;
        break
    end
    if i == size(I,2)
        if max_y <0
            max_y = size(I,3);
        end
        break
    end
    i = i + 1;
end

if min_y - buff <= 0
    min_y = 0;
else
    min_y = min_y - buff;
end
if max_y + buff >= size(I,2)
    max_y = size(I,2);
else
    max_y = max_y + buff;
end

box = [min_x max_x min_y max_y min_z max_z];
    
    