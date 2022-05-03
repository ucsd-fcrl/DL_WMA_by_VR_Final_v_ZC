function [box] = Bounding_box_new(seg_rot,LV_or_all_chamber, buff)

if LV_or_all_chamber(1:2) ~= 'LV'
   
    [x,y,z] = ind2sub(size(seg_rot),find(seg_rot ~= 0));
else
 
    [x,y,z] = ind2sub(size(seg_rot),find(seg_rot == 1));
end

x_min = min(x(:));
if x_min - buff(1) > 0
    x_min = x_min - buff(1);
else
    x_min = 1;
end


x_max = max(x(:));
if x_max + buff(2) < size(seg_rot,1)
    x_max = x_max + buff(2);
else
    x_max = size(seg_rot,1);
end
    
y_min = min(y(:));
if y_min - buff(3) > 0
    y_min = y_min - buff(3);
else
    y_min = 1;
end


y_max = max(y(:));
if y_max + buff(4) < size(seg_rot,2)
    y_max = y_max + buff(4);
else
    y_max = size(seg_rot,2);
end


z_min = min(z(:));
if z_min - buff(5) > 0
    z_min = z_min - buff(5);
else
    z_min = 1;
end


z_max = max(z(:));
if z_max + buff(6) < size(seg_rot,3)
    z_max = z_max + buff(6);
else
    z_max = size(seg_rot,3);
end


box = [x_min,x_max,y_min,y_max,z_min,z_max];
