function [new_position_list] = Make_Volshow_all_Angle(seg,view_angle,config)


position = config.CameraPosition';
scale = [2,2,2];
new_position_list = [];
for i = 1:size(view_angle,2)
    angle = view_angle(:,i);
    
    config_new = config;
    [rot_in_xy,~] = Rotation_Matrix_From_Three_Axis(0,0,angle,1);
    new_position = rot_in_xy * position;
    config_new.CameraPosition = new_position';
    new_position_list = [new_position_list;new_position'];
    figure()
    volshow(seg,config_new,'ScaleFactor',scale); 
end