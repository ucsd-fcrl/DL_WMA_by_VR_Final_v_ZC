function [config_new] = Get_New_Config_After_Rotation(config,angle)

camera_position = config.CameraPosition';
config_new = config;
[rot_in_xy,~] = Rotation_Matrix_From_Three_Axis(0,0,angle,1);
new_position = rot_in_xy * camera_position;
config_new.CameraPosition = new_position';